// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";
import {UniswapV2LiquidityAdapter} from "./adapters/UniswapV2Adapter.sol";

/**
 * @title Contract to create new token markets.
 * @dev Responsible for accurately deploying new token markets with the preffered parameters.
 */
contract MarketFactory is Ownable {
    //////////////////// DATA STRUCTURES ////////////////////
    struct MarketParameters {
        uint256 initiationFee; // fee to create a new market
        uint256 liquidityCap; // amount of ETH to be raised before moving to a DEX
        uint256 xStartVirtualReserve; // initial virtual reserve for ETH
        uint256 yStartVirtualReserve; // initial virtual reserve for created token
        uint256 yMintAmount; // Supply of the created token
        uint256 yReservedForLP; // Amount of created token to LP once curve cap is reached
        uint256 yReservedForCurve; // Amount of created tokens to sell through the curve
    }

    //////////////////// EVENTS ////////////////////
    event MarketCreated(address creator, string name, address token, address curve);

    //////////////////// CONSTANTS ////////////////////
    uint256 constant BASIS_POINTS = 10000;

    //////////////////// VARIABLES ////////////////////
    address public feeTo;
    address[] public allTokens;
    MarketParameters public params;
    UniswapV2LiquidityAdapter public dexAdapter;
    mapping(MarketToken => MarketCurve) public tokenToCurve;

    //////////////////// CONSTRUCTOR ////////////////////
    constructor(MarketParameters memory _params, address _feeTo, address _WETH, address _v2Factory, address _v2Router)
        Ownable(msg.sender)
    {
        feeTo = _feeTo;
        params = _params;
        dexAdapter = new UniswapV2LiquidityAdapter(_WETH, _v2Factory, _v2Router);
    }

    //////////////////// FUNCTIONS ////////////////////
    function createMarket(string calldata name, string calldata symbol) public payable {
        require(msg.value == params.initiationFee, "INVALID_FEE");

        MarketCurve curve = new MarketCurve(
            MarketCurve.CurveParameters({
                cap: params.liquidityCap,
                xVirtualReserve: params.xStartVirtualReserve,
                yVirtualReserve: params.yStartVirtualReserve,
                yReservedForLP: params.yReservedForLP,
                yReservedForCurve: params.yReservedForCurve
            })
        );

        sendEther(feeTo, params.initiationFee);

        MarketToken token = new MarketToken(name, symbol, address(curve), params.yMintAmount);
        curve.initialiseCurve(token, dexAdapter);

        allTokens.push(address(token));
        tokenToCurve[token] = curve;

        emit MarketCreated(msg.sender, name, address(token), address(curve));
    }

    function updateLiquidityCap(uint256 _liquidityCap) public onlyOwner {
        params.liquidityCap = _liquidityCap;
    }

    function updateVirtualReserveConfig(uint256 _xStartVirtualReserve, uint256 _yStartVirtualReserve)
        public
        onlyOwner
    {
        params.xStartVirtualReserve = _xStartVirtualReserve;
        params.yStartVirtualReserve = _yStartVirtualReserve;
    }

    function updateTokenParams(uint256 _yMintAmount, uint256 _yReservedForLP, uint256 _yReservedForCurve)
        public
        onlyOwner
    {
        params.yMintAmount = _yMintAmount;
        params.yReservedForLP = _yReservedForLP;
        params.yReservedForCurve = _yReservedForCurve;
    }

    function updateInitiationFee(uint256 _initiationFee) public onlyOwner {
        params.initiationFee = _initiationFee;
    }

    function updateFeeTo(address _feeTo) public onlyOwner {
        feeTo = _feeTo;
    }

    function sendEther(address to, uint256 amount) internal {
        (bool sent,) = to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
