// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";
import {MarketToken} from "../src/core/MarketToken.sol";
import {MarketCurve} from "../src/core/MarketCurve.sol";
import {UniswapV2LiquidityAdapter} from "../src/core/adapters/UniswapV2Adapter.sol";

contract MarketCurveTest is Test {
    MarketCurve public curve;
    MarketToken public token;

    address constant WETH = address(0);
    address constant FACTORY = address(0);
    address constant ROUTER = address(0);
    UniswapV2LiquidityAdapter adapter = new UniswapV2LiquidityAdapter(WETH, FACTORY, ROUTER);

    uint256 public constant cap = 5.04 ether;
    uint256 public constant xInitialVirtualReserve = 1.296 ether;
    uint256 public constant yInitialVirtualReserve = 1_080_000_000 ether;
    uint256 public constant yReservedForLP = 200_000_000 ether;
    uint256 public constant yReservedForCurve = 800_000_000 ether;
    uint256 public constant yToMint = 1_000_000_000 ether;

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

        token = new MarketToken("Test Token", "TT", curve, yToMint);
    }

    receive() external payable {}

    function test_InitialiseCurve() public {
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Created));
        assertEq(address(curve.mom()), address(this));
        assertEq(address(curve.token()), address(0));

        curve.initialiseCurve(token, adapter);

        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Trading));
        assertEq(address(curve.token()), address(token));
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

    function test_buyTokenWithOneEther() public {
        curve.initialiseCurve(token, adapter);

        uint256 quote = curve.getQuote(1 ether, 0);
        token.approve(address(curve), quote);

        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();

        uint256 ethBalanceSelfBefore = address(this).balance;
        uint256 tokenBalanceSelfBefore = token.balanceOf(address(this));

        curve.buy{value: 1 ether}(1 ether);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        uint256 ethBalanceSelfAfter = address(this).balance;
        uint256 tokenBalanceSelfAfter = token.balanceOf(address(this));

        assertEq(xReserveAfter - xReserveBefore, 1 ether);
        assertEq(yReserveBefore - yReserveAfter, quote);

        assertEq(xBalanceAfter - xBalanceBefore, 1 ether);
        assertEq(yBalanceBefore - yBalanceAfter, quote);

        assertEq(ethBalanceSelfBefore - ethBalanceSelfAfter, 1 ether);
        assertEq(tokenBalanceSelfAfter - tokenBalanceSelfBefore, quote);
    }

    function test_sellTokenForOneEther() public {
        curve.initialiseCurve(token, adapter);

        // Need to buy tokens before we can sell.
        curve.buy{value: 1 ether}(1 ether);
        uint256 tokensToSell = token.balanceOf(address(this));
        token.approve(address(curve), tokensToSell);

        uint256 quote = curve.getQuote(0, tokensToSell);

        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();

        uint256 ethBalanceSelfBefore = address(this).balance;
        uint256 tokenBalanceSelfBefore = token.balanceOf(address(this));

        curve.sell(tokensToSell);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        uint256 ethBalanceSelfAfter = address(this).balance;
        uint256 tokenBalanceSelfAfter = token.balanceOf(address(this));

        assertEq(xReserveBefore - xReserveAfter, quote);
        assertEq(yReserveAfter - yReserveBefore, tokensToSell);

        assertEq(xBalanceBefore - xBalanceAfter, quote);
        assertEq(yBalanceAfter - yBalanceBefore, tokensToSell);

        assertEq(ethBalanceSelfAfter - ethBalanceSelfBefore, quote);
        assertEq(tokenBalanceSelfBefore - tokenBalanceSelfAfter, tokensToSell);
    }
}
