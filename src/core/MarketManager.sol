// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";

/**
 * @title Contract to manage a token market
 * @dev Orchestrates and stores the details for a market
 */
contract MarketManager {
    MarketToken public token;
    MarketCurve public curve;

    constructor() {}

    function initialise(MarketToken _token, MarketCurve _curve) public {
        token = _token;
        curve = _curve;
    }
}
