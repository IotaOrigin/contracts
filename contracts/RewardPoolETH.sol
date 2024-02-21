// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import "./ICollectionswap.sol";
import "./ILSSVMPair.sol";

contract RewardPoolETH is IERC721Receiver {
    using SafeERC20 for IERC20;

    struct LPTokenInfo {
        uint256 amount0;
        uint256 amount1;
        uint256 amount;
        address owner;
    }

    uint128 private reserve0; // uses single storage slot, accessible via getReserves
    uint128 private reserve1; // uses single storage slot, accessible via getReserves

    address protocolOwner;
    address deployer;
    ICollectionswap public lpToken;
    IERC20 tokenAddress;
    IERC721 nft;
    address bondingCurve;
    uint128 delta;
    uint96 fee;


    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(uint256 => LPTokenInfo) public lpTokenInfo;

    IERC20 public rewardToken;
    uint256 public rewardRate;

    uint256 public periodFinish;
    uint256 public rewardSweepTime;
    uint256 public lastUpdateTime;
    uint256 public rewardStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 tokenId, uint256 amount);
    event Withdrawn(address indexed user, uint256 tokenId, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardSwept();
    event RewardPoolRecharged(uint256 reward, uint256 startTime, uint256 endTime);

    modifier updateReward(address account) {
        // skip update after rewards program starts
        // cannot include equality because 
        // multiple accounts can perform actions in the same block
        // and we have to update account's rewards and userRewardPerTokenPaid values
        if (block.timestamp < lastUpdateTime) {
            _;
            return;
        }

        // lastUpdateTime is set to startTime in constructor
        if (block.timestamp > lastUpdateTime) {
            rewardStored = rewardPerToken();
            lastUpdateTime = lastTimeRewardApplicable();
        }
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardStored;
        }
        _;
    }

    constructor(
        address _protocolOwner,
        address _deployer,
        ICollectionswap _lpToken,
        IERC20 _tokenAddress,
        IERC721 _nft,
        address _bondingCurve,
        uint128 _delta,
        uint96 _fee,
        IERC20 _rewardToken,
        uint256 _rewardRate,
        uint256 _startTime,
        uint256 _periodFinish
    ) {
        protocolOwner = _protocolOwner;
        require(_nft.supportsInterface(0x80ac58cd), "NFT should be ERC721"); // check if it supports ERC721
        deployer = _deployer;
        lpToken = _lpToken;
        tokenAddress = _tokenAddress;
        nft = _nft;
        bondingCurve = _bondingCurve;
        delta = _delta;
        fee = _fee;
        rewardToken = _rewardToken;
        rewardRate = _rewardRate;

        lastUpdateTime = _startTime;
        periodFinish = _periodFinish;
        rewardSweepTime = _periodFinish + 180 days;
    }

    function rechargeRewardPool(        
        uint256 inputRewardAmount,
        uint256 _newPeriodFinish
        ) external updateReward(address(0)) {
        
        require(msg.sender == deployer || msg.sender == protocolOwner , "Not authorized");
        require(_newPeriodFinish > block.timestamp, "Invalid period finish");
        require(block.timestamp > periodFinish, "Cannot recharge before period finish");

        rewardToken.safeTransferFrom(msg.sender, address(this), inputRewardAmount);
        rewardRate = inputRewardAmount / (_newPeriodFinish - block.timestamp);
        require(rewardRate != 0, "0 reward rate");

        lastUpdateTime = block.timestamp;
        periodFinish = _newPeriodFinish;
        rewardSweepTime = _newPeriodFinish + 180 days;

        emit RewardPoolRecharged(inputRewardAmount, block.timestamp, _newPeriodFinish);
    }

    function sweepRewards() external {
        require(msg.sender == deployer, "Not authorized");
        require(block.timestamp >= rewardSweepTime, "Too early");
        emit RewardSwept();
        rewardToken.safeTransfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    function mint(uint256 tokenId) private returns (uint256 amount) {
        ICollectionswap _lpToken = lpToken;
        require(_lpToken.ownerOf(tokenId) == msg.sender, "Not owner");

        IERC721 _nft = nft;
        IERC20 _tokenAddress = tokenAddress;
        require(_lpToken.validatePoolParamsLte(tokenId, address(_tokenAddress), address(_nft), bondingCurve, fee, delta), "Wrong pool");

        ICollectionswap.LPTokenParams721ETH memory params = _lpToken
            .viewPoolParams(tokenId);
        ILSSVMPair _pair = ILSSVMPair(params.poolAddress);

        (uint128 _reserve0, uint128 _reserve1) = getReserves(); // gas savings
        uint256 amount0 = _nft.balanceOf(address(_pair));
        uint256 amount1 = (address(_tokenAddress)==address(0))? address(_pair).balance : _tokenAddress.balanceOf(address(_pair));
        uint256 indicatorAtLeastOneBid = 1;
        ( , , ,uint256 bidPrice, ,) = _pair.getSellNFTQuote(1,1);
        if (amount1 < bidPrice) {
            indicatorAtLeastOneBid = 0;
        }

        amount = Math.sqrt(amount0 * amount1 * indicatorAtLeastOneBid);

        uint256 balance0 = _reserve0 + amount0;
        uint256 balance1 = _reserve1 + amount1;
        require(
            balance0 <= type(uint128).max && balance1 <= type(uint128).max,
            "Balance overflow"
        );

        reserve0 = uint128(balance0);
        reserve1 = uint128(balance1);
        lpTokenInfo[tokenId] = LPTokenInfo({
            amount0: amount0,
            amount1: amount1,
            amount: amount,
            owner: msg.sender 
        });
    }

    function burn(uint256 tokenId) private returns (uint256 amount) {
        LPTokenInfo memory lpTokenIdInfo = lpTokenInfo[tokenId];
        require(lpTokenIdInfo.owner == msg.sender, "Not owner");
        amount = lpTokenIdInfo.amount;

        (uint128 _reserve0, uint128 _reserve1) = getReserves(); // gas savings

        uint256 balance0 = _reserve0 - lpTokenIdInfo.amount0;
        uint256 balance1 = _reserve1 - lpTokenIdInfo.amount1;

        reserve0 = uint128(balance0);
        reserve1 = uint128(balance1);

        delete lpTokenInfo[tokenId];
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        uint256 lastRewardTime = lastTimeRewardApplicable();
        // latter condition required because calculations will revert when called externally
        // even though internally this function will only be called if lastRewardTime > lastUpdateTime
        if (totalSupply() == 0 || lastRewardTime <= lastUpdateTime) {
            return rewardStored;
        }
        return rewardStored + (
                (lastRewardTime - lastUpdateTime) * rewardRate * 1e18 / totalSupply()
            );
    }

    function earned(address account) public view returns (uint256) {
        return balanceOf(account)
                * (rewardPerToken() - userRewardPerTokenPaid[account])
                / (1e18)
                + rewards[account];
    }

    function stake(uint256 tokenId) public updateReward(msg.sender) {
        require(tx.origin == msg.sender, "Caller must be EOA");
        uint256 amount = mint(tokenId);
        require(amount > 0, "Cannot stake one-sided LPs");

        _totalSupply += amount;
        _balances[msg.sender] += amount;
        lpToken.safeTransferFrom(msg.sender, address(this), tokenId);
        emit Staked(msg.sender, tokenId, amount);
    }

    function withdraw(uint256 tokenId) public updateReward(msg.sender) {
        // amount will never be 0 because it is checked in stake() 
        uint256 amount = burn(tokenId);
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        lpToken.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Withdrawn(msg.sender, tokenId, amount);
    }

    function exit(uint256 tokenId) external {
        withdraw(tokenId);
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward);
            rewardToken.safeTransfer(msg.sender, reward);
        }
    }

    function getReserves()
        public
        view
        returns (uint128 _reserve0, uint128 _reserve1)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function getIncentivisationParams()
        external
        view
        returns (IERC20, IERC721, address, uint128, uint96)
    {
        return (tokenAddress, nft, bondingCurve, delta, fee);
    }
}
