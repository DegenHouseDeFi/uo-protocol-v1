// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";

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

    function test_deployed() public {
        assertEq(address(factory) != address(0), true);
    }
}
