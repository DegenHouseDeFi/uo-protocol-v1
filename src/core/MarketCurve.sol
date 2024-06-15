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
    Status status;
    address public mom;
    MarketToken public token;
    CurveParameters public params;

    //////////////////// CONSTRUCTOR ////////////////////
    constructor(
        MarketFactory _factory,
        uint256 _cap,
        uint256 _xVirtualReserve,
        uint256 _yVirtualReserve,
        uint256 _yReservedForLP,
        uint256 _yReservedForCurve
    ) {
        mom = msg.sender;
        params = CurveParameters({
            cap: _cap,
            xVirtualReserve: _xVirtualReserve,
            yVirtualReserve: _yVirtualReserve,
            yReservedForLP: _yReservedForLP,
            yReservedForCurve: _yReservedForCurve
        });

        status = Status.Created;
    }

    //////////////////// FUNCTIONS ////////////////////
    function initialiseCurve(MarketToken _token) public onlyMom {
        token = _token;
        status = Status.Trading;
    }

    //////////////////// MODIFIERS ////////////////////
    modifier onlyMom() {
        require(msg.sender == mom, "ONLY_MOM");
        _;
    }
}
