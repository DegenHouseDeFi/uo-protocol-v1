// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../../src/core/MarketFactory.sol";
import {MarketToken} from "../../src/core/MarketToken.sol";
import {MarketCurve} from "../../src/core/MarketCurve.sol";

contract MarketTokenTest is Test {
    MarketToken public token;
    address public receiver;
    address public parent;

    function setUp() public {
        receiver = address(this);
        parent = address(this);

        token = new MarketToken("Test Token", "TT", parent, 1_000_000_000 ether);
    }

    function test_TokenCreated() public view {
        assertEq(token.name(), "Test Token");
        assertEq(token.symbol(), "TT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1_000_000_000 ether);

        assertEq(token.balanceOf(receiver), 1_000_000_000 ether);
        assertEq(token.balanceOf(parent), 1_000_000_000 ether);
    }

    function testFail_TokenTransferBeforeGraduate() public {
        address randomOne = address(0x1234);
        address randomTwo = address(0x5678);
        token.transfer(randomOne, 100 ether);

        vm.prank(randomOne);
        token.transfer(randomTwo, 100 ether);
    }

    function test_TokenTransfer() public {
        token.setGraduated(true);
        address randomOne = address(0x1234);
        address randomTwo = address(0x5678);
        token.transfer(randomOne, 100 ether);

        vm.prank(randomOne);
        token.transfer(randomTwo, 100 ether);
    }

    function testFail_unauthorizedGraduate() public {
        address random = address(0x1234);
        vm.prank(random);
        token.setGraduated(true);
    }
}
