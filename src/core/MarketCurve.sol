// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";
import {MarketManager} from "./MarketManager.sol";

/**
 * @title Bonding Curve for a token market
 */
contract MarketCurve {
    MarketManager immutable manager;
    constructor(address _manager) {
        manager = _manager;
    }
}
