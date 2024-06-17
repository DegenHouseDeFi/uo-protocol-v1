// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketFactory} from "./MarketFactory.sol";
import {MarketToken} from "./MarketToken.sol";

/**
 * @title Bonding Curve for a token market
 */
contract MarketCurve {
    //////////////////// DATA STRUCTURES ////////////////////
    enum Status {
        Created,
        Trading,
        CapReached,
        Graduated
    }

    struct CurveParameters {
        uint256 cap; // total amount of liquidity post which token should be moved to a DEX
        uint256 xVirtualReserve; // virtual reserve for backing token
        uint256 yVirtualReserve; // virtual reserve for created token
        uint256 yReservedForLP; // amount of created token to LP once curve cap is reached
        uint256 yReservedForCurve; // amount of created tokens to sell through the curve
    }

    //////////////////// VARIABLES ////////////////////
    Status public status;
    address public mom;
    MarketToken public token;
    CurveParameters public params;

    //////////////////// CONSTRUCTOR ////////////////////
    constructor(CurveParameters memory _params) {
        mom = msg.sender;
        params = _params;
        status = Status.Created;
    }

    //////////////////// FUNCTIONS ////////////////////
    function initialiseCurve(MarketToken _token) public onlyMom {
        token = _token;
        status = Status.Trading;
    }

    // function getQuote(uint256 xAmountIn, uint256 yAmountIn) public view returns (uint256 quote) {
    //     require(xAmountIn == 0 || yAmountIn == 0, "ONE_TOKEN_ONLY");
    //     (uint256 xReserve, uint256 yReserve) = (params.xVirtualReserve, params.yVirtualReserve);

    //     if (xAmountIn > 0) {
    //         // Swapping xAmountIn worth of x for y
    //     } else {
    //         // Swapping yAmountIn worth of y for x
    //     }
    // }

    function getParams()
        public
        view
        returns (
            uint256 cap,
            uint256 xVirtualReserve,
            uint256 yVirtualReserve,
            uint256 yReservedForLP,
            uint256 yReservedForCurve
        )
    {
        (cap, xVirtualReserve, yVirtualReserve, yReservedForLP, yReservedForCurve) = (
            params.cap, params.xVirtualReserve, params.yVirtualReserve, params.yReservedForLP, params.yReservedForCurve
        );
    }

    function getReserves() public view returns (uint256 xReserve, uint256 yReserve) {
        xReserve = params.xVirtualReserve;
        yReserve = params.yVirtualReserve;
    }

    //////////////////// MODIFIERS ////////////////////
    modifier onlyMom() {
        require(msg.sender == mom, "ONLY_MOM");
        _;
    }
}
