// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketFactory} from "./MarketFactory.sol";
import {MarketToken} from "./MarketToken.sol";

import {UniswapV2LiquidityAdapter} from "./adapters/UniswapV2Adapter.sol";

/**
 * @title Bonding Curve for a token market
 * @dev This contract is designed to ONLY work with the MarketToken contract
 */
contract MarketCurve {
    ////////////// EVENTS //////////////
    event CurveInitialised(address token, address dexAdapter);
    event Trade(address indexed trader, bool indexed isBuy, uint256 xAmount, uint256 yAmount);
    event Graduated(address indexed token, address indexed dexPair);

    ////////////// ERRORS //////////////
    error Curve_InvalidBalance(uint256 expected, uint256 actual);
    error Curve_InvalidStatus(Status expected, Status actual);
    error Curve_InvalidInputAmount(uint256 amount);
    error Curve_InvalidOutputAmount(uint256 amount);
    error Curve_InvalidInputAmounts();
    error Curve_FailedEtherTransfer();
    error Curve_NotMOM();

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

    struct FeeParamters {
        address feeTo;
        uint256 BASIS_POINTS;
        uint256 tradeFee;
        uint256 graduationFee;
    }

    struct Balances {
        uint256 x;
        uint256 y;
    }

    //////////////////// VARIABLES ////////////////////
    address public mom;
    Status public status;
    MarketToken public token;
    Balances public balances;
    CurveParameters public params;
    FeeParamters public feeParams;
    UniswapV2LiquidityAdapter public dexAdapter;

    //////////////////// CONSTANTS ////////////////////
    address constant BURN_ADDRESS = address(0x0);

    //////////////////// CONSTRUCTOR ////////////////////
    constructor(CurveParameters memory _params, FeeParamters memory _feeParams) {
        mom = msg.sender;
        params = _params;
        feeParams = _feeParams;
        status = Status.Created;
    }

    //////////////////// FUNCTIONS ////////////////////
    function initialiseCurve(MarketToken _token, UniswapV2LiquidityAdapter _dexAdapter) external onlyMom {
        token = _token;
        dexAdapter = _dexAdapter;
        status = Status.Trading;

        uint256 balanceY = token.balanceOf(address(this));
        // @notice: This check might be redundant as the contract is assumed to work only with MarketToken.
        if (balanceY != params.yReservedForCurve + params.yReservedForLP) {
            revert Curve_InvalidBalance(params.yReservedForCurve + params.yReservedForLP, balanceY);
        }

        balances.x = 0;
        balances.y = balanceY - params.yReservedForLP;

        emit CurveInitialised(address(token), address(dexAdapter));
    }

    function buy(uint256 xIn, uint256 yMinOut) external payable onlyTrading nonZeroIn(xIn) returns (uint256 out) {
        if (msg.value != xIn) {
            revert Curve_InvalidInputAmount(xIn);
        }

        uint256 fee = (xIn * feeParams.tradeFee) / feeParams.BASIS_POINTS;
        uint256 adjustedXIn = xIn - fee;
        // The amount of ETH to buy should not exceed the ETH liquidity cap
        if (balances.x + adjustedXIn > params.cap) {
            adjustedXIn = params.cap - balances.x;
            sendEther(msg.sender, xIn - adjustedXIn - fee);
        }

        uint256 quote = getQuote(adjustedXIn, 0);

        out = quote;
        if (out < yMinOut) {
            revert Curve_InvalidOutputAmount(out);
        }

        balances.x += adjustedXIn;
        balances.y -= out;

        params.xVirtualReserve += adjustedXIn;
        params.yVirtualReserve -= out;

        if (balances.y == 0) {
            status = Status.CapReached;
        }

        token.transfer(msg.sender, out);
        sendEther(feeParams.feeTo, fee);

        emit Trade(msg.sender, true, adjustedXIn, out);
    }

    function sell(uint256 yIn, uint256 xMinOut) external onlyTrading nonZeroIn(yIn) returns (uint256 out) {
        uint256 quote = getQuote(0, yIn);

        out = quote;
        if (out < xMinOut) {
            revert Curve_InvalidOutputAmount(out);
        }

        uint256 fee = (out * feeParams.tradeFee) / feeParams.BASIS_POINTS;
        uint256 adjustedOut = out - fee;

        balances.x -= out;
        balances.y += yIn;

        params.xVirtualReserve -= out;
        params.yVirtualReserve += yIn;

        token.transferFrom(msg.sender, address(this), yIn);
        sendEther(msg.sender, adjustedOut);
        sendEther(feeParams.feeTo, fee);

        emit Trade(msg.sender, false, adjustedOut, yIn);
    }

    function graduate() external {
        if (status != Status.CapReached) {
            revert Curve_InvalidStatus(Status.CapReached, status);
        }
        status = Status.Graduated;
        token.approve(address(dexAdapter), params.yReservedForLP);

        uint256 xToLP = balances.x - feeParams.graduationFee;
        sendEther(feeParams.feeTo, feeParams.graduationFee);

        dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(
            address(token), xToLP, params.yReservedForLP, BURN_ADDRESS
        );

        emit Graduated(address(token), address(dexAdapter));
    }

    function getQuote(uint256 xAmountIn, uint256 yAmountIn) public view returns (uint256 quote) {
        if (xAmountIn > 0 && yAmountIn > 0) {
            revert Curve_InvalidInputAmounts();
        }

        (uint256 xReserve, uint256 yReserve) = (params.xVirtualReserve, params.yVirtualReserve);

        if (xAmountIn > 0) {
            quote = (yReserve * xAmountIn) / (xReserve + xAmountIn);
            quote = min(quote, balances.y);
        } else {
            quote = (xReserve * yAmountIn) / (yReserve + yAmountIn);
            quote = min(quote, balances.x);
        }
    }

    function getParams()
        public
        view
        returns (
            uint256 cap,
            uint256 xVirtualReserve,
            uint256 yVirtualReserve,
            uint256 yReservedForLP,
            uint256 yReservedForCurve
        )
    {
        (cap, xVirtualReserve, yVirtualReserve, yReservedForLP, yReservedForCurve) = (
            params.cap, params.xVirtualReserve, params.yVirtualReserve, params.yReservedForLP, params.yReservedForCurve
        );
    }

    function getReserves() public view returns (uint256 xReserve, uint256 yReserve) {
        xReserve = params.xVirtualReserve;
        yReserve = params.yVirtualReserve;
    }

    function getBalances() public view returns (uint256 x, uint256 y) {
        (x, y) = (balances.x, balances.y);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function sendEther(address to, uint256 amount) internal {
        (bool sent,) = to.call{value: amount}("");
        if (!sent) {
            revert Curve_FailedEtherTransfer();
        }
    }

    //////////////////// MODIFIERS ////////////////////
    modifier onlyMom() {
        if (msg.sender != mom) {
            revert Curve_NotMOM();
        }
        _;
    }

    modifier nonZeroIn(uint256 _in) {
        if (_in == 0) {
            revert Curve_InvalidInputAmount(_in);
        }
        _;
    }

    modifier onlyTrading() {
        if (status != Status.Trading) {
            revert Curve_InvalidStatus(Status.Trading, status);
        }
        _;
    }
}
