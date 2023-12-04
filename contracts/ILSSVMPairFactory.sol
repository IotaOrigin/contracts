// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICurve} from "./ICurve.sol";
import {ILSSVMPair, ILSSVMPairETH} from "./ILSSVMPair.sol";

interface ILSSVMPairFactory {
    function createPairERC721ETH(
        IERC721 _nft,
        ICurve _bondingCurve,
        address payable _assetRecipient,
        ILSSVMPair.PoolType _poolType,
        uint128 _delta,
        uint96 _fee,
        uint128 _spotPrice,
        address _propertyChecker,
        uint256[] calldata _initialNFTIDs
    ) external payable returns (ILSSVMPairETH pair);


    struct CreateERC721ERC20PairParams {
        IERC20 token;
        IERC721 nft;
        ICurve bondingCurve;
        address payable assetRecipient;
        ILSSVMPair.PoolType poolType;
        uint128 delta;
        uint96 fee;
        uint128 spotPrice;
        address propertyChecker;
        uint256[] initialNFTIDs;
        uint256 initialTokenBalance;
    }

    /**
     * @notice Creates a pair contract using EIP-1167.
     * @param params The info used to create a new pair. This includes:
     * - token: The ERC20 token the pair trades
     * - nft: The NFT contract of the collection the pair trades
     * - bondingCurve: The bonding curve for the pair to price NFTs, must be whitelisted
     * - assetRecipient: The address that will receive the assets traders give during trades.
     *   If set to address(0), assets will be sent to the pool address. Not available to TRADE pools.
     * - poolType: TOKEN, NFT, or TRADE
     * - delta: The delta value used by the bonding curve. The meaning of delta depends on the specific curve.
     * - fee: The fee taken by the LP in each trade. Can only be non-zero if poolType is Trade.
     * - spotPrice: Param 1 for the bonding curve, usually used for start price
     * - delta: Param 2 for the bonding curve, usually used for dynamic adjustment
     * - propertyChecker: The contract to use for verifying properties of IDs sent in
     * - initialNFTIDs: The list of IDs of NFTs to transfer from the sender to the pair
     * - initialTokenBalance: The initial token balance sent from the sender to the new pair
     * @return pair The new pair
     */
    function createPairERC721ERC20(CreateERC721ERC20PairParams calldata params)
    external
    returns (ILSSVMPair pair);

}