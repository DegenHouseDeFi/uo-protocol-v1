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
    struct MarketParameters {
        uint256 liquidityCap; // amount of ETH to be raised before moving to a DEX
        uint256 xStartVirtualReserve; // initial virtual reserve for ETH
        uint256 yStartVirtualReserve; // initial virtual reserve for created token
        uint256 yMintAmount; // Supply of the created token
        uint256 yReservedForLP; // Amount of created token to LP once curve cap is reached
        uint256 yReservedForCurve; // Amount of created tokens to sell through the curve
    }

    event MarketCreated(
        address creator,
        string name,
        address token,
        address curve
    );

    mapping(MarketToken => MarketCurve) public tokenToCurve;
    MarketParameters params;

    constructor(MarketParameters memory _params) Ownable(msg.sender) {
        params = _params;
    }

    function createMarket(string calldata name, string calldata symbol) public {
        // TODO: Update the initialisation parameters for the MarketCurve.
        MarketCurve curve = new MarketCurve(0, 0, 0, 0, 0);
        MarketToken token = new MarketToken(
            name,
            symbol,
            curve,
            params.yMintAmount
        );

        tokenToCurve[token] = curve;

        emit MarketCreated(msg.sender, name, token, curve);
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
