// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MarketFactory} from "./MarketFactory.sol";
import {MarketToken} from "./MarketToken.sol";

import {UniswapV2LiquidityAdapter} from "./adapters/UniswapV2Adapter.sol";

/**
 * @title Bonding Curve for a token market
 * @author Manan Gouhar (@manangouhari)
 * @notice This contract implements the Market with a bonding curve for a token.
 * @dev MarketCurve contract is designed to only safely work with MarketToken. (Use with other ERC-20 implementations at your own risk)
 */
contract MarketCurve {
    ////////////// EVENTS //////////////

    /**
     * @dev Emitted when the curve is initialized with the token and DEX adapter addresses.
     * @param token The address of the MarketToken contract.
     * @param dexAdapter The address of the UniswapV2LiquidityAdapter contract.
     */
    event CurveInitialised(address token, address dexAdapter);

    /**
     * @dev Emitted when a trade occurs in the market curve.
     * @param trader The address of the trader.
     * @param isBuy A boolean indicating whether the trade is a buy or sell.
     * @param xAmount The amount of input token (ETH) used in the trade.
     * @param yAmount The amount of output token (MarketToken) received in the trade.
     */
    event Trade(address indexed trader, bool indexed isBuy, uint256 xAmount, uint256 yAmount);

    /**
     * @dev Emitted when the market curve graduates and creates a DEX pair with liquidity.
     * @param token The address of the MarketToken contract.
     * @param dexPair The address of the DEX pair contract.
     */
    event Graduated(address indexed token, address indexed dexPair);

    ////////////// ERRORS //////////////
    error Curve_InvalidParams();
    error Curve_InvalidBalance(uint256 expected, uint256 actual);
    error Curve_InvalidStatus(Status expected, Status actual);

    /**
     * @param amount The invalid input amount.
     */
    error Curve_InvalidInputAmount(uint256 amount);

    /**
     * @param amount The invalid output amount.
     */
    error Curve_InvalidOutputAmount(uint256 amount);
    error Curve_InvalidInputAmounts();
    error Curve_FailedEtherTransfer();
    error Curve_NotMOM();

    //////////////////// DATA STRUCTURES ////////////////////
    /**
     * @title MarketCurve
     * @dev This contract defines the data structures used in the market curve implementation.
     */
    enum Status {
        Created,
        Trading,
        CapReached,
        Graduated
    }

    /**
     * @title CurveParameters
     * @dev This struct defines the parameters used in the market curve.
     */
    struct CurveParameters {
        /// @notice The total amount of x liquidity post which token should be moved to a DEX.
        uint256 cap;
        /// @notice The virtual reserve for the backing token.
        uint256 xVirtualReserve;
        /// @notice The virtual reserve for the created token.
        uint256 yVirtualReserve;
        /// @notice The amount of created token to LP once curve cap is reached.
        uint256 yReservedForLP;
        /// @notice The amount of created tokens to sell through the curve. The curve is considered complete once yReservedForCurve is exhausted.
        uint256 yReservedForCurve;
    }

    /**
     * @title Balances
     * @dev This struct defines the balances of tokens in the market curve.
     * @dev This is used to keep track of the real balances of x and y in the curve.
     */
    struct Balances {
        uint256 x;
        uint256 y;
    }

    //////////////////// VARIABLES ////////////////////
    Status public status;
    Balances public balances;
    MarketToken public token;
    CurveParameters public params;
    MarketFactory public immutable mom;
    UniswapV2LiquidityAdapter public dexAdapter;

    //////////////////// CONSTANTS ////////////////////
    address constant BURN_ADDRESS = address(0x0);

    //////////////////// CONSTRUCTOR ////////////////////
    constructor(CurveParameters memory _params) {
        if (
            _params.cap == 0 || _params.yReservedForLP == 0 || _params.yReservedForCurve == 0
                || _params.xVirtualReserve == 0 || _params.yVirtualReserve == 0
        ) {
            revert Curve_InvalidParams();
        }
        mom = MarketFactory(msg.sender);
        params = _params;
        status = Status.Created;
    }

    //////////////////// FUNCTIONS ////////////////////
    /**
     * @notice Initializes the market curve by setting the token, DEX adapter, and status.
     * @dev This function can only be called by the contract owner.
     * @param _token The address of the MarketToken contract.
     * @param _dexAdapter The address of the UniswapV2LiquidityAdapter contract.
     */
    function initialiseCurve(MarketToken _token, UniswapV2LiquidityAdapter _dexAdapter) external onlyMom {
        if (address(token) != address(0) || address(dexAdapter) != address(0)) {
            revert Curve_InvalidParams();
        }

        // Set the token, DEX adapter, and status
        token = _token;
        dexAdapter = _dexAdapter;
        status = Status.Trading;

        // Set the x and y balances
        balances.x = 0;
        balances.y = params.yReservedForCurve;

        // Emit an event to indicate that the curve has been initialised
        emit CurveInitialised(address(token), address(dexAdapter));
    }

    /**
     * @dev Executes a buy trade in the market curve.
     * @param xIn The amount of input tokens to be used for the trade.
     * @param yMinOut The minimum amount of output tokens expected from the trade.
     * @return out The amount of output tokens received from the trade.
     */
    function buy(uint256 xIn, uint256 yMinOut) external payable onlyTrading nonZeroIn(xIn) returns (uint256 out) {
        if (msg.value != xIn) {
            revert Curve_InvalidInputAmount(msg.value);
        }

        // Retrieve fee parameters from the fee manager contract
        (address feeTo, uint256 BASIS_POINTS,, uint256 tradeFee,) = mom.feeParams();

        // Calculate the trade fee based on the input amount
        uint256 fee = (xIn * tradeFee) / BASIS_POINTS;
        uint256 xInAfterFee = xIn - fee;

        uint256 adjustedXIn = balances.x + xInAfterFee > params.cap ? params.cap - balances.x : xInAfterFee;

        // Calculate the output amount based on the adjusted input amount
        uint256 quote = getQuote(adjustedXIn, 0);

        out = quote;

        // Revert the transaction if the output amount is less than the minimum expected
        if (out < yMinOut) {
            revert Curve_InvalidOutputAmount(out);
        }

        // Update the balances and virtual reserves
        balances.x += adjustedXIn;
        balances.y -= out;
        params.xVirtualReserve += adjustedXIn;
        params.yVirtualReserve -= out;

        // Update the status if the y balance reaches zero
        if (balances.y == 0) {
            status = Status.CapReached;
        }

        // Transfer the output tokens to the buyer and send the trade fee to the fee recipient
        token.transfer(msg.sender, out);
        sendEther(feeTo, fee);

        // Send back x if there is any remaining after the trade.
        if (xInAfterFee - adjustedXIn > 0) {
            sendEther(msg.sender, xInAfterFee - adjustedXIn);
        }

        // Emit a trade event
        emit Trade(msg.sender, true, adjustedXIn, out);
    }

    /**
     * @dev Executes a sell trade.
     * @param yIn The amount of token Y to sell.
     * @param xMinOut The minimum amount of token X expected to receive.
     * @return out The amount of token X received after the trade.
     */
    function sell(uint256 yIn, uint256 xMinOut) external onlyTrading nonZeroIn(yIn) returns (uint256 out) {
        // Calculate the quote for the trade
        uint256 quote = getQuote(0, yIn);

        out = quote;

        // Get fee parameters from the mom contract
        (address feeTo, uint256 BASIS_POINTS,, uint256 tradeFee,) = mom.feeParams();
        // Calculate the trade fee
        uint256 fee = (out * tradeFee) / BASIS_POINTS;
        // Deduct the trade fee from the output amount
        out = out - fee;
        // Check if the output amount is less than the minimum expected amount
        if (out < xMinOut) {
            revert Curve_InvalidOutputAmount(out);
        }

        // Update the balances of token X and token Y
        balances.x -= out;
        balances.y += yIn;

        // Update the virtual reserves of token X and token Y
        params.xVirtualReserve -= out;
        params.yVirtualReserve += yIn;

        // Transfer token Y from the sender to the contract
        token.transferFrom(msg.sender, address(this), yIn);
        // Send token X to the sender
        sendEther(msg.sender, out);
        // Send the trade fee to the fee recipient
        sendEther(feeTo, fee);

        // Emit a Trade event
        emit Trade(msg.sender, false, out, yIn);
    }

    /**
     * @dev Graduates the market by creating a pair on a DEX and adding liquidity.
     * Only callable when the market status is `CapReached`.
     * Emits a `Graduated` event upon successful graduation.
     */
    function graduate() external {
        // Check if the market status is `CapReached`
        if (status != Status.CapReached) {
            revert Curve_InvalidStatus(Status.CapReached, status);
        }
        status = Status.Graduated;

        // Get the fee parameters from the MarketFactory
        (address feeTo,,,, uint256 graduationFee) = mom.feeParams();
        uint256 xToLP = balances.x - graduationFee;

        // Send the graduation fee to the specified fee recipient
        sendEther(feeTo, graduationFee);

        // Set the token as graduated and approve the DEX adapter to spend the reserved LP tokens
        token.setGraduated(true);
        token.approve(address(dexAdapter), params.yReservedForLP);

        // Create a pair on the DEX and add liquidity using ETH and reserved LP tokens
        dexAdapter.createPairAndAddLiquidityETH{value: xToLP}(
            address(token), xToLP, params.yReservedForLP, BURN_ADDRESS
        );

        // Emit the Graduated event
        emit Graduated(address(token), address(dexAdapter));
    }

    /**
     * @dev Calculates the quote for a given input of x and y amounts.
     * @param xAmountIn The amount of x tokens to be swapped.
     * @param yAmountIn The amount of y tokens to be swapped.
     * @return quote The calculated quote for the given input amounts.
     */
    function getQuote(uint256 xAmountIn, uint256 yAmountIn) public view returns (uint256 quote) {
        // Check if the input amounts are greater than zero
        if (xAmountIn > 0 && yAmountIn > 0) {
            revert Curve_InvalidInputAmounts(); // Revert with an error if both amounts are greater than zero
        }

        // Get the virtual reserves of x and y tokens
        (uint256 xReserve, uint256 yReserve) = (params.xVirtualReserve, params.yVirtualReserve);

        if (xAmountIn > 0) {
            // Calculate the quote for xAmountIn
            quote = (yReserve * xAmountIn) / (xReserve + xAmountIn);
            quote = min(quote, balances.y); // Ensure the quote does not exceed the available y token balance
        } else {
            // Calculate the quote for yAmountIn
            quote = (xReserve * yAmountIn) / (yReserve + yAmountIn);
            quote = min(quote, balances.x); // Ensure the quote does not exceed the available x token balance
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
        if (msg.sender != address(mom)) {
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
