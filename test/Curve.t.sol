// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";
import {MarketToken} from "../src/core/MarketToken.sol";
import {MarketCurve} from "../src/core/MarketCurve.sol";

contract MarketCurveTest is Test {
    MarketCurve public curve;
    MarketToken public token;

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

    function test_InitialiseCurve() public {
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Created));
        assertEq(address(curve.mom()), address(this));
        assertEq(address(curve.token()), address(0));

        curve.initialiseCurve(token);

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
        curve.initialiseCurve(token);

        uint256 quote = curve.getQuote(1 ether, 0);
        assertApproxEqRel(quote, 470_383_275 * 1e18, 0.1e18);
    }

    function test_getQuoteForMillionTokens() public {
        curve.initialiseCurve(token);

        uint256 quote = curve.getQuote(0, 1_000_000 ether);
        assertApproxEqRel(quote, 0.0012 ether, 0.1e18);
    }
}
