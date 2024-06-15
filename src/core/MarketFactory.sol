// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";

/**
 * @title Contract to create new token markets.
 * @dev Responsible for accurately deploying new token markets with the preffered parameters.
 */
contract MarketFactory is Ownable {
    mapping(MarketToken => MarketCurve) public tokenToCurve;

    struct MarketParameters {
        uint256 liquidityCap;
        uint256 xStartVirtualReserve;
        uint256 yStartVirtualReserve;
        uint256 yMintAmount;
        uint256 yReservedForLP;
        uint256 yReservedForCurve;
    }

    MarketParameters params;

    constructor(MarketParameters memory _params) Ownable(msg.sender) {
        params = _params;
    }

    function createMarket(string calldata name, string calldata symbol) public {
        // TODO: Update the initialisation parameters for the MarketCurve.
        MarketCurve curve = new MarketCurve(0, 0, 0, 0, 0);
        MarketToken token = new MarketToken(name, symbol, curve);

        tokenToCurve[token] = curve;
    }

    function updateLiquidityCap(uint256 _liquidityCap) public onlyOwner {
        params.liquidityCap = _liquidityCap;
    }

    function updateVirtualReserveConfig(
        uint256 _xStartVirtualReserve,
        uint256 _yStartVirtualReserve
    ) public onlyOwner {
        params.xStartVirtualReserve = _xStartVirtualReserve;
        params.yStartVirtualReserve = _yStartVirtualReserve;
    }

    function updateTokenParams(
        uint256 _yMintAmount,
        uint256 _yReservedForLP,
        uint256 _yReservedForCurve
    ) public onlyOwner {
        params.yMintAmount = _yMintAmount;
        params.yReservedForLP = _yReservedForLP;
        params.yReservedForCurve = _yReservedForCurve;
    }
}
