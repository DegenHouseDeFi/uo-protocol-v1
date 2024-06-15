// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketManager} from "./MarketManager.sol";
import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";

/**
 * @title Contract to create new token markets.
 * @dev Responsible for accurately deploying new token markets with the preffered parameters.
 */
contract MarketFactory {
    function createMarket(string calldata name, string calldata symbol) public {
        // deploy a manager
        // initialise the manager
    }
}
