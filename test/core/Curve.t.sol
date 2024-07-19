// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../../src/core/MarketFactory.sol";
import {MarketToken} from "../../src/core/MarketToken.sol";
import {MarketCurve} from "../../src/core/MarketCurve.sol";
import {UniswapV2LiquidityAdapter} from "../../src/core/adapters/UniswapV2Adapter.sol";

contract MarketCurveTest is Test {
    MarketCurve public curve;
    MarketToken public token;

    MarketFactory.FeeParameters public feeParams;

    address constant WETH = address(0);
    address constant FACTORY = address(0);
    address constant ROUTER = address(0);
    UniswapV2LiquidityAdapter adapter = new UniswapV2LiquidityAdapter(WETH, FACTORY, ROUTER);

    uint256 public constant cap = 3.744 ether;
    uint256 public constant xInitialVirtualReserve = 1.296 ether;
    uint256 public constant yInitialVirtualReserve = 1_080_000_000 ether;
    uint256 public constant yReservedForLP = 200_000_000 ether;
    uint256 public constant yReservedForCurve = 800_000_000 ether;
    uint256 public constant yToMint = 1_000_000_000 ether;

    uint16 public constant BASIS_POINTS = 10_000;
    uint16 public constant tradeFee = 100;
    uint16 public constant initialBuyFee = 200;
    uint128 public constant graduationFee = 0;
    uint128 public constant initiationFee = 0.0015 ether;

    function setUp() public {
        curve = new MarketCurve(
            MarketCurve.CurveParameters({
                cap: cap,
                xVirtualReserve: xInitialVirtualReserve,
                yVirtualReserve: yInitialVirtualReserve,
                yReservedForLP: yReservedForLP,
                yReservedForCurve: yReservedForCurve
            })
        );

        feeParams = MarketFactory.FeeParameters({
            feeTo: address(0x0),
            BASIS_POINTS: BASIS_POINTS,
            tradeFee: tradeFee,
            initialBuyFee: initialBuyFee,
            initiationFee: initiationFee,
            graduationFee: graduationFee
        });

        token = new MarketToken("Test Token", "TT", address(curve), yToMint);
    }

    receive() external payable {}

    function test_InitialiseCurve() public {
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Created));
        assertEq(address(curve.mom()), address(this));
        assertEq(address(curve.token()), address(0));

        vm.expectEmit(true, true, false, false);
        emit MarketCurve.CurveInitialised(address(token), address(adapter));
        curve.initialiseCurve(token, adapter);

        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Trading));
        assertEq(address(curve.token()), address(token));
        (uint256 xBalance, uint256 yBalance) = curve.balances();
        assertEq(xBalance, 0);
        assertEq(yBalance, yReservedForCurve);
    }

    function test_InitialiseCurveWithWrongCaller() public {
        MarketCurve crv = new MarketCurve(
            MarketCurve.CurveParameters({
                cap: cap,
                xVirtualReserve: xInitialVirtualReserve,
                yVirtualReserve: yInitialVirtualReserve,
                yReservedForLP: yReservedForLP,
                yReservedForCurve: yReservedForCurve
            })
        );

        feeParams = MarketFactory.FeeParameters({
            feeTo: address(0x0),
            BASIS_POINTS: BASIS_POINTS,
            initiationFee: initiationFee,
            tradeFee: tradeFee,
            initialBuyFee: initialBuyFee,
            graduationFee: graduationFee
        });

        MarketToken tkn = new MarketToken("Test Token", "TT", address(crv), yToMint);

        vm.prank(address(0x123));
        vm.expectRevert(MarketCurve.Curve_NotMOM.selector);
        crv.initialiseCurve(tkn, adapter);
    }

    function test_getReserve() public view {
        (uint256 xReserve, uint256 yReserve) = curve.getReserves();
        assertEq(xReserve, xInitialVirtualReserve);
        assertEq(yReserve, yInitialVirtualReserve);
    }

    function test_getParams() public view {
        (
            uint256 cap_,
            uint256 xVirtualReserve,
            uint256 yVirtualReserve,
            uint256 yReservedForLP_,
            uint256 yReservedForCurve_
        ) = curve.getParams();
        assertEq(cap_, cap);
        assertEq(xVirtualReserve, xInitialVirtualReserve);
        assertEq(yVirtualReserve, yInitialVirtualReserve);
        assertEq(yReservedForLP_, yReservedForLP);
        assertEq(yReservedForCurve_, yReservedForCurve);
    }

    function test_getQuoteForOneEther() public {
        curve.initialiseCurve(token, adapter);

        uint256 quote = curve.getQuote(1 ether, 0);
        assertApproxEqRel(quote, 470_383_275 * 1e18, 0.1e18);
    }

    function test_getQuoteForMillionTokens() public {
        curve.initialiseCurve(token, adapter);

        uint256 quote = curve.getQuote(0, 1_000_000 ether);
        assertEq(quote, 0); // quote is 0 because there is no ETH in the Curve yet.
    }

    function test_getQuoteWithZeroValues() public {
        curve.initialiseCurve(token, adapter);
        uint256 quote = curve.getQuote(0, 0);
        assertEq(quote, 0);
    }

    function test_getQuoteWithBothValues() public {
        curve.initialiseCurve(token, adapter);
        // curve.getQuote should revert with MarketCurve.Curve_InvalidInputAmounts
        vm.expectRevert(MarketCurve.Curve_InvalidInputAmounts.selector);
        curve.getQuote(1 ether, 1 ether);
    }

    function test_buyTokenWithOneEther() public {
        curve.initialiseCurve(token, adapter);

        uint256 toSell = 1 ether;
        uint256 fee = (toSell * tradeFee) / BASIS_POINTS;
        uint256 toSellAdjusted = toSell - fee;

        uint256 quote = curve.getQuote(toSellAdjusted, 0);
        token.approve(address(curve), quote);

        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();

        uint256 ethBalanceSelfBefore = address(this).balance;
        uint256 tokenBalanceSelfBefore = token.balanceOf(address(this));

        vm.expectEmit(true, true, false, true);
        emit MarketCurve.Trade(address(this), true, toSellAdjusted, quote);
        curve.buy{value: toSell}(toSell, 1);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        uint256 ethBalanceSelfAfter = address(this).balance;
        uint256 tokenBalanceSelfAfter = token.balanceOf(address(this));
        assertEq(xReserveAfter - xReserveBefore, toSellAdjusted, "xReserveImbalance");
        assertEq(yReserveBefore - yReserveAfter, quote, "yReserveImbalance");

        assertEq(xBalanceAfter - xBalanceBefore, toSellAdjusted, "xBalanceImbalance");
        assertEq(yBalanceBefore - yBalanceAfter, quote, "yBalanceImbalance");

        assertEq(ethBalanceSelfBefore - ethBalanceSelfAfter, 1 ether, "ethBalanceImbalance");
        assertEq(tokenBalanceSelfAfter - tokenBalanceSelfBefore, quote, "tokenBalanceImbalance");
    }

    function test_buyTokenWithInvalidParams() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketCurve.Curve_InvalidStatus.selector, MarketCurve.Status.Trading, MarketCurve.Status.Created
            )
        );
        curve.buy{value: 1 ether}(1 ether, 1);

        curve.initialiseCurve(token, adapter);

        vm.expectRevert(abi.encodeWithSelector(MarketCurve.Curve_InvalidInputAmount.selector, 0.1 ether));
        curve.buy{value: 0.1 ether}(1 ether, 1);

        uint256 toSell = 1 ether;
        uint256 fee = (toSell * tradeFee) / BASIS_POINTS;
        uint256 toSellAdjusted = toSell - fee;
        uint256 quote = curve.getQuote(toSellAdjusted, 0);

        vm.expectRevert(abi.encodeWithSelector(MarketCurve.Curve_InvalidOutputAmount.selector, quote));
        curve.buy{value: toSell}(toSell, quote + 10 ether);
    }

    function test_sellTokenForOneEther() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketCurve.Curve_InvalidStatus.selector, MarketCurve.Status.Trading, MarketCurve.Status.Created
            )
        );
        curve.sell(1000 ether, 1);

        curve.initialiseCurve(token, adapter);

        // Need to buy tokens before we can sell.
        curve.buy{value: 1 ether}(1 ether, 1);
        uint256 tokensToSell = token.balanceOf(address(this));
        token.approve(address(curve), tokensToSell);

        uint256 quote = curve.getQuote(0, tokensToSell);
        uint256 adjustedQuote = quote - (quote * tradeFee) / BASIS_POINTS;

        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();

        uint256 ethBalanceSelfBefore = address(this).balance;
        uint256 tokenBalanceSelfBefore = token.balanceOf(address(this));
        vm.expectEmit(true, true, false, true);
        emit MarketCurve.Trade(address(this), false, adjustedQuote, tokensToSell);
        curve.sell(tokensToSell, 1);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        assertEq(xReserveBefore - xReserveAfter, adjustedQuote, "xReserveImbalance");
        assertEq(yReserveAfter - yReserveBefore, tokensToSell, "yReserveImbalance");

        assertEq(xBalanceBefore - xBalanceAfter, adjustedQuote, "xBalanceImbalance");
        assertEq(yBalanceAfter - yBalanceBefore, tokensToSell, "yBalanceImbalance");

        assertEq(address(this).balance - ethBalanceSelfBefore, adjustedQuote, "ethBalanceImbalance");
        assertEq(tokenBalanceSelfBefore - token.balanceOf(address(this)), tokensToSell, "tokenBalanceImbalance");
    }

    function test_sellTokenWithInvalidParams() public {
        curve.initialiseCurve(token, adapter);

        curve.buy{value: 1 ether}(1 ether, 1);
        uint256 tokensToSell = token.balanceOf(address(this));
        token.approve(address(curve), tokensToSell);

        uint256 quote = curve.getQuote(0, tokensToSell);
        uint256 adjustedQuote = quote - ((quote * tradeFee) / BASIS_POINTS);
        vm.expectRevert(abi.encodeWithSelector(MarketCurve.Curve_InvalidOutputAmount.selector, adjustedQuote));
        curve.sell(tokensToSell, adjustedQuote + 1);
    }

    function test_tokenCapReach() public {
        curve.initialiseCurve(token, adapter);
        curve.buy{value: 3.8 ether}(3.8 ether, 1);

        MarketCurve.Status curveStatus = curve.status();
        assertEq(uint256(curveStatus), uint256(MarketCurve.Status.CapReached));
    }

    function test_invalidStatusGraduation() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketCurve.Curve_InvalidStatus.selector, MarketCurve.Status.CapReached, MarketCurve.Status.Created
            )
        );
        curve.graduate();

        curve.initialiseCurve(token, adapter);
        vm.expectRevert(
            abi.encodeWithSelector(
                MarketCurve.Curve_InvalidStatus.selector, MarketCurve.Status.CapReached, MarketCurve.Status.Trading
            )
        );
        curve.graduate();

        curve.buy{value: 3.8 ether}(3.8 ether, 1);
        vm.expectRevert(); // should revert when not run on Base Mainnet Fork
        curve.graduate();
    }
}
