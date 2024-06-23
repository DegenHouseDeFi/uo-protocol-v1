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
    function initialiseCurve(MarketToken _token, UniswapV2LiquidityAdapter _dexAdapter) public onlyMom {
        token = _token;
        dexAdapter = _dexAdapter;
        status = Status.Trading;

        uint256 balanceY = token.balanceOf(address(this));
        require(balanceY == params.yReservedForCurve + params.yReservedForLP, "INVALID_BALANCE");

        balances.x = 0;
        balances.y = balanceY - params.yReservedForLP;
    }

    function buy(uint256 xIn) public payable onlyTrading nonZeroIn(xIn) returns (uint256 out) {
        // Flaw: There are no protections against the user overspending `x` to buy the available `y`
        require(xIn > 0, "INVALID_IN");
        require(status == Status.Trading, "NOT_TRADING");
        require(msg.value == xIn, "INVALID_VALUE_SENT");

        uint256 fee = (xIn * feeParams.tradeFee) / feeParams.BASIS_POINTS;
        uint256 adjustedXIn = xIn - fee;
        // The amount of ETH to buy should not exceed the ETH liquidity cap
        if (balances.x + adjustedXIn > params.cap) {
            adjustedXIn = params.cap - balances.x;
            sendEther(msg.sender, xIn - adjustedXIn - fee);
        }

        uint256 quote = getQuote(adjustedXIn, 0);

        out = quote;
        require(out > 0, "INVALID_OUT");

        balances.x += adjustedXIn;
        balances.y -= out;

        params.xVirtualReserve += adjustedXIn;
        params.yVirtualReserve -= out;

        if (balances.y == 0) {
            status = Status.CapReached;
        }

        token.transfer(msg.sender, out);
        sendEther(feeParams.feeTo, fee);
    }

    function sell(uint256 yIn) public onlyTrading nonZeroIn(yIn) returns (uint256 out) {
        require(yIn > 0, "INVALID_IN");
        require(status == Status.Trading, "NOT_TRADING");

        uint256 quote = getQuote(0, yIn);

        out = quote;
        require(quote > 0, "INVALID_QUOTE");
        uint256 fee = (out * feeParams.tradeFee) / feeParams.BASIS_POINTS;
        uint256 adjustedOut = out - fee;

        balances.x -= out;
        balances.y += yIn;

        params.xVirtualReserve -= out;
        params.yVirtualReserve += yIn;

        token.transferFrom(msg.sender, address(this), yIn);
        sendEther(msg.sender, adjustedOut);
        sendEther(feeParams.feeTo, fee);
    }

    function graduate() public {
        require(status == Status.CapReached, "NOT_CAP_REACHED");
        status = Status.Graduated;
        token.approve(address(dexAdapter), params.yReservedForLP);
        dexAdapter.createPairAndAddLiquidityETH{value: balances.x}(
            address(token), balances.x, params.yReservedForLP, BURN_ADDRESS
        );
    }

    function getQuote(uint256 xAmountIn, uint256 yAmountIn) public view returns (uint256 quote) {
        require(xAmountIn == 0 || yAmountIn == 0, "ONE_TOKEN_ONLY");

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
        require(sent, "Failed to send Ether");
    }

    function updateFeeParams(FeeParamters memory _feeParams) public onlyMom {
        feeParams = _feeParams;
    }

    //////////////////// MODIFIERS ////////////////////
    modifier onlyMom() {
        require(msg.sender == mom, "ONLY_MOM");
        _;
    }

    modifier nonZeroIn(uint256 _in) {
        require(_in > 0, "INVALID_IN");
        _;
    }

    modifier onlyTrading() {
        require(status == Status.Trading, "NOT_TRADING");
        _;
    }
}
