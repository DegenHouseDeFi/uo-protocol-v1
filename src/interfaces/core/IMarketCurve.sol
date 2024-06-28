// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IMarketCurve {
    ////////////// EVENTS //////////////
    event CurveInitialised(address token, address dexAdapter);
    event Trade(address indexed trader, bool indexed isBuy, uint256 xAmount, uint256 yAmount);
    event Graduated(address indexed token, address indexed dexPair);

    ////////////// FUNCTIONS //////////////
    function initialiseCurve(address _token, address _dexAdapter) external;

    function buy(uint256 xIn, uint256 yMinOut) external payable returns (uint256 out);

    function sell(uint256 yIn, uint256 xMinOut) external returns (uint256 out);

    function graduate() external;

    function getQuote(uint256 xAmountIn, uint256 yAmountIn) external view returns (uint256 quote);

    function getParams()
        external
        view
        returns (
            uint256 cap,
            uint256 xVirtualReserve,
            uint256 yVirtualReserve,
            uint256 yReservedForLP,
            uint256 yReservedForCurve
        );

    function getReserves() external view returns (uint256 xReserve, uint256 yReserve);

    function getBalances() external view returns (uint256 x, uint256 y);
}
