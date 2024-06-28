// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IMarketFactory {
    //////////////////// EVENTS ////////////////////
    event MarketCreated(address indexed creator, string name, address indexed token, address indexed curve);
    event MarketParametersUpdated(
        uint256 liquidityCap,
        uint256 xStartVirtualReserve,
        uint256 yStartVirtualReserve,
        uint256 yMintAmount,
        uint256 yReservedForLP,
        uint256 yReservedForCurve
    );
    event FeeParametersUpdated(
        address indexed feeTo, uint256 BASIS_POINTS, uint256 initiationFee, uint256 tradeFee, uint256 graduationFee
    );
    event DexAdapterUpdated(address indexed adapter);

    //////////////////// FUNCTIONS ////////////////////
    function createMarket(string calldata name, string calldata symbol) external payable;

    function updateMarketParams(
        uint256 _liquidityCap,
        uint256 _xStartVirtualReserve,
        uint256 _yStartVirtualReserve,
        uint256 _yMintAmount,
        uint256 _yReservedForLP,
        uint256 _yReservedForCurve
    ) external;

    function updateFeeParams(
        address _feeTo,
        uint256 _BASIS_POINTS,
        uint256 _initiationFee,
        uint256 _tradeFee,
        uint256 _graduationFee
    ) external;

    function newDexAdapter(address _WETH, address _v2Factory, address _v2Router) external;

    //////////////////// VIEW FUNCTIONS ////////////////////
    function allTokens(uint256 index) external view returns (address);
    function params()
        external
        view
        returns (
            uint256 liquidityCap,
            uint256 xStartVirtualReserve,
            uint256 yStartVirtualReserve,
            uint256 yMintAmount,
            uint256 yReservedForLP,
            uint256 yReservedForCurve
        );
    function feeParams()
        external
        view
        returns (address feeTo, uint256 BASIS_POINTS, uint256 initiationFee, uint256 tradeFee, uint256 graduationFee);
    function dexAdapter() external view returns (address);
    function tokenToCurve(address token) external view returns (address);
}
