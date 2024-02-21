// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./ICollectionswap.sol";
import "./RewardPoolETH.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Collectionstaker is Ownable {
    using SafeERC20 for IERC20;

    ICollectionswap lpToken;

    /// @notice Event emitted when a liquidity mining incentive has been created
    /// @param creator The creator Address
    /// @param poolAddress The Reward pool address
    /// @param rewardToken The token being distributed as a reward
    /// @param reward The amount of reward token to be distributed
    /// @param startTime The time when the incentive program begins
    /// @param endTime The time when rewards stop accruing
    event IncentiveETHCreated(
        address creator,
        address poolAddress,
        IERC20 rewardToken,
        uint256 reward,
        uint256 startTime,
        uint256 endTime
    );

    constructor(ICollectionswap _lpToken) {
        lpToken = _lpToken;
    }

    function createIncentiveETH(
        IERC20 tokenAddress,
        IERC721 nft,
        address bondingCurve,
        uint128 delta,
        uint96 fee,
        IERC20 rewardToken,
        uint256 reward,
        uint256 startTime,
        uint256 endTime
    ) external {
        require(startTime > block.timestamp, "cannot backdate");
        uint256 rewardRate = reward / (endTime - startTime); // guaranteed endTime > startTime
        require(rewardRate != 0, "0 reward rate"); // guaranteed endTime > startTime

        RewardPoolETH rewardPool = new RewardPoolETH(
            owner(),
            msg.sender,
            lpToken,
            tokenAddress,
            nft,
            bondingCurve,
            delta,
            fee,
            rewardToken,
            rewardRate,
            startTime,
            endTime  
        );

        // transfer reward tokens to RewardPool
        rewardToken.safeTransferFrom(
            msg.sender,
            address(rewardPool),
            reward
        );

        emit IncentiveETHCreated(msg.sender, address(rewardPool), rewardToken, reward, startTime, endTime);
    }
}
