// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

import {MarketCurve} from "./MarketCurve.sol";
import {MarketToken} from "./MarketToken.sol";
import {UniswapV2LiquidityAdapter} from "./adapters/UniswapV2Adapter.sol";

/**
 * @title Contract to create new token markets.
 * @author Manan Gouhari (@manangouhari)
 * @dev Responsible for accurately deploying new token markets with the preffered parameters.
 */
contract MarketFactory is Ownable {
    //////////////////// EVENTS ////////////////////
    event MarketCreated(address indexed creator, string name, address token, address curve);
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
    event DexAdapterUpdated(address adapter);

    //////////////////// ERRORS ////////////////////
    error Factory_InvalidFee(uint256 expected, uint256 received);
    error Factory_FailedEtherTransfer();
    error Factory_InvalidParams();

    //////////////////// DATA STRUCTURES ////////////////////
    /**
     * @title MarketParameters
     * @dev Struct to store the parameters for creating a market.
     */
    struct MarketParameters {
        /// @notice Amount of ETH to be raised before moving to a DEX
        uint256 liquidityCap;
        /// @notice Initial virtual reserve for ETH
        uint256 xStartVirtualReserve;
        /// @notice Initial virtual reserve for created token
        uint256 yStartVirtualReserve;
        /// @notice Supply of the created token
        uint256 yMintAmount;
        /// @notice Amount of created token to LP once curve cap is reached
        uint256 yReservedForLP;
        /// @notice Amount of created tokens to sell through the curve
        uint256 yReservedForCurve;
    }

    /**
     * @title FeeParameters struct
     * @notice This struct represents the parameters for fees in the market factory.
     */
    struct FeeParameters {
        /// @notice The address where the fees will be sent to.
        address feeTo;
        /// @notice The basis points for calculating fees.
        uint16 BASIS_POINTS;
        /// @notice The fee charged for each trade in the market.
        uint16 tradeFee;
        /// @notice The initiation fee for creating a new market.
        uint128 initiationFee;
        /// @notice The fee charged for graduating a market.
        uint128 graduationFee;
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
        if (
            _params.yMintAmount != _params.yReservedForCurve + _params.yReservedForLP || _WETH == address(0)
                || _v2Factory == address(0) || _v2Router == address(0)
        ) {
            revert Factory_InvalidParams();
        }

        params = _params;
        feeParams = _feeParams;
        dexAdapter = new UniswapV2LiquidityAdapter(_WETH, _v2Factory, _v2Router);
    }

    //////////////////// FUNCTIONS ////////////////////
    /**
     * @dev Creates a new token and a market associated with it.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     */
    function createMarket(string calldata name, string calldata symbol) external payable {
        // Check if the received fee matches the initiation fee
        if (msg.value != feeParams.initiationFee) {
            revert Factory_InvalidFee({expected: feeParams.initiationFee, received: msg.value});
        }

        // Create a new market curve with the specified parameters
        MarketCurve curve = new MarketCurve(
            MarketCurve.CurveParameters({
                cap: params.liquidityCap,
                xVirtualReserve: params.xStartVirtualReserve,
                yVirtualReserve: params.yStartVirtualReserve,
                yReservedForLP: params.yReservedForLP,
                yReservedForCurve: params.yReservedForCurve
            })
        );

        // Create a new market token associated with the market curve
        MarketToken token = new MarketToken(name, symbol, address(curve), address(curve), params.yMintAmount);
        // Initialize the market curve with the market token and the DEX adapter
        curve.initialiseCurve(token, dexAdapter);

        // Update the directory
        allTokens.push(address(token));
        tokenToCurve[token] = curve;

        // Send the initiation fee to the specified fee recipient
        sendEther(feeParams.feeTo, feeParams.initiationFee);

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
        if (_yMintAmount != _yReservedForCurve + _yReservedForLP) {
            revert Factory_InvalidParams();
        }

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
        uint16 _BASIS_POINTS,
        uint16 _tradeFee,
        uint128 _initiationFee,
        uint128 _graduationFee
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
        if (address(_WETH) == address(0) || address(_v2Factory) == address(0) || address(_v2Router) == address(0)) {
            revert Factory_InvalidParams();
        }

        dexAdapter = new UniswapV2LiquidityAdapter(_WETH, _v2Factory, _v2Router);
        emit DexAdapterUpdated(address(dexAdapter));
    }

    //////////////////// UTILITY FUNCTIONS ////////////////////
    function sendEther(address to, uint256 amount) internal {
        (bool sent,) = to.call{value: amount}("");
        if (!sent) {
            revert Factory_FailedEtherTransfer();
        }
    }

    //////////////////// VIEW FUNCTIONS ////////////////////
    function allMarkets() external view returns (address[] memory) {
        return allTokens;
    }
}
