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
    //////////////////// EVENTS ////////////////////
    event MarketCreated(address creator, string name, address token, address curve);
    event MarketParametersUpdated(
        uint256 liquidityCap,
        uint256 xStartVirtualReserve,
        uint256 yStartVirtualReserve,
        uint256 yMintAmount,
        uint256 yReservedForLP,
        uint256 yReservedForCurve
    );
    event FeeParametersUpdated(
        address feeTo, uint256 BASIS_POINTS, uint256 initiationFee, uint256 tradeFee, uint256 graduationFee
    );

    //////////////////// ERRORS ////////////////////
    error Factory_InvalidFee(uint256 expected, uint256 received);
    error Factory_FailedEtherTransfer();

    //////////////////// DATA STRUCTURES ////////////////////
    struct MarketParameters {
        uint256 liquidityCap; // amount of ETH to be raised before moving to a DEX
        uint256 xStartVirtualReserve; // initial virtual reserve for ETH
        uint256 yStartVirtualReserve; // initial virtual reserve for created token
        uint256 yMintAmount; // Supply of the created token
        uint256 yReservedForLP; // Amount of created token to LP once curve cap is reached
        uint256 yReservedForCurve; // Amount of created tokens to sell through the curve
    }

    struct FeeParameters {
        address feeTo;
        uint256 BASIS_POINTS;
        uint256 initiationFee;
        uint256 tradeFee;
        uint256 graduationFee;
    }

    //////////////////// VARIABLES ////////////////////
    address[] public allTokens;
    MarketParameters public params;
    FeeParameters public feeParams;
    UniswapV2LiquidityAdapter public dexAdapter;
    mapping(MarketToken => MarketCurve) public tokenToCurve;

    //////////////////// CONSTRUCTOR ////////////////////
    constructor(
        MarketParameters memory _params,
        FeeParameters memory _feeParams,
        address _WETH,
        address _v2Factory,
        address _v2Router
    ) Ownable(msg.sender) {
        params = _params;
        feeParams = _feeParams;
        dexAdapter = new UniswapV2LiquidityAdapter(_WETH, _v2Factory, _v2Router);
    }

    //////////////////// FUNCTIONS ////////////////////
    function createMarket(string calldata name, string calldata symbol) public payable {
        if (msg.value != feeParams.initiationFee) {
            revert Factory_InvalidFee({expected: feeParams.initiationFee, received: msg.value});
        }

        require(msg.value == feeParams.initiationFee, "INVALID_FEE");

        MarketCurve curve = new MarketCurve(
            MarketCurve.CurveParameters({
                cap: params.liquidityCap,
                xVirtualReserve: params.xStartVirtualReserve,
                yVirtualReserve: params.yStartVirtualReserve,
                yReservedForLP: params.yReservedForLP,
                yReservedForCurve: params.yReservedForCurve
            }),
            MarketCurve.FeeParamters({
                feeTo: feeParams.feeTo,
                BASIS_POINTS: feeParams.BASIS_POINTS,
                tradeFee: feeParams.tradeFee,
                graduationFee: feeParams.graduationFee
            })
        );

        sendEther(feeParams.feeTo, feeParams.initiationFee);

        MarketToken token = new MarketToken(name, symbol, address(curve), params.yMintAmount);
        curve.initialiseCurve(token, dexAdapter);

        allTokens.push(address(token));
        tokenToCurve[token] = curve;

        emit MarketCreated(msg.sender, name, address(token), address(curve));
    }

    //////////////////// ADMIN FUNCTIONS ////////////////////

    function updateMarketParams(
        uint256 _liquidityCap,
        uint256 _xStartVirtualReserve,
        uint256 _yStartVirtualReserve,
        uint256 _yMintAmount,
        uint256 _yReservedForLP,
        uint256 _yReservedForCurve
    ) external onlyOwner {
        params = MarketParameters({
            liquidityCap: _liquidityCap,
            xStartVirtualReserve: _xStartVirtualReserve,
            yStartVirtualReserve: _yStartVirtualReserve,
            yMintAmount: _yMintAmount,
            yReservedForLP: _yReservedForLP,
            yReservedForCurve: _yReservedForCurve
        });

        emit MarketParametersUpdated(
            _liquidityCap,
            _xStartVirtualReserve,
            _yStartVirtualReserve,
            _yMintAmount,
            _yReservedForLP,
            _yReservedForCurve
        );
    }

    function updateFeeParams(
        address _feeTo,
        uint256 _BASIS_POINTS,
        uint256 _initiationFee,
        uint256 _tradeFee,
        uint256 _graduationFee
    ) external onlyOwner {
        feeParams = FeeParameters({
            feeTo: _feeTo,
            BASIS_POINTS: _BASIS_POINTS,
            initiationFee: _initiationFee,
            tradeFee: _tradeFee,
            graduationFee: _graduationFee
        });

        emit FeeParametersUpdated(_feeTo, _BASIS_POINTS, _initiationFee, _tradeFee, _graduationFee);
    }

    function newDexAdapter(address _WETH, address _v2Factory, address _v2Router) external onlyOwner {
        dexAdapter = new UniswapV2LiquidityAdapter(_WETH, _v2Factory, _v2Router);
    }

    //////////////////// UTILITY FUNCTIONS ////////////////////
    function sendEther(address to, uint256 amount) internal {
        (bool sent,) = to.call{value: amount}("");
        if (!sent) {
            revert Factory_FailedEtherTransfer();
        }
    }
}
