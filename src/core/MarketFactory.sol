// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";

/**
 * @title Contract to create new token markets.
 * @dev Responsible for accurately deploying new token markets with the preffered parameters.
 */
contract MarketFactory {
    mapping(MarketToken => MarketCurve) public tokenToCurve;

    function createMarket(string calldata name, string calldata symbol) public {
        // TODO: Update the initialisation parameters for the MarketCurve.
        MarketCurve curve = new MarketCurve(0, 0, 0, 0, 0);
        MarketToken token = new MarketToken(name, symbol, curve);

        tokenToCurve[token] = curve;
    }
}
