// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";
import {MarketToken} from "../src/core/MarketToken.sol";
import {MarketCurve} from "../src/core/MarketCurve.sol";

contract MarketFactoryTest is Test {
    MarketFactory public factory;

    function setUp() public {
        factory = new MarketFactory(
            MarketFactory.MarketParameters({
                liquidityCap: 5.04 ether,
                xStartVirtualReserve: 1.296 ether,
                yStartVirtualReserve: 1_080_000_000 ether,
                yMintAmount: 1_000_000_000 ether,
                yReservedForLP: 200_000_000 ether,
                yReservedForCurve: 800_000_000 ether
            })
        );
    }

    function test_MarketCreated() public {
        factory.createMarket("Test Token", "TT");
        MarketToken token = MarketToken(factory.allTokens(0));
        MarketCurve curve = MarketCurve(factory.tokenToCurve(token));

        assertNotEq(address(token), address(0));
        assertNotEq(address(curve), address(0));

        assertEq(token.name(), "Test Token");
        assertEq(token.symbol(), "TT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1_000_000_000 ether);

        assertEq(token.balanceOf(address(curve)), 1_000_000_000 ether);

        assertEq(address(curve.mom()), address(factory));
        assertEq(address(curve.token()), address(token));
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Trading));
    }
}
