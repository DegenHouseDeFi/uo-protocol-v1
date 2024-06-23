// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../../src/core/MarketFactory.sol";
import {MarketToken} from "../../src/core/MarketToken.sol";
import {MarketCurve} from "../../src/core/MarketCurve.sol";

contract MarketFactoryTest is Test {
    MarketFactory public factory;
    address constant WETH = address(0);
    address constant FACTORY = address(0);
    address constant ROUTER = address(0);

    receive() external payable {}

    uint256 constant initiationFee = 0.0015 ether;
    uint256 constant graduationFee = 0.005 ether;

    function setUp() public {
        factory = new MarketFactory(
            MarketFactory.MarketParameters({
                liquidityCap: 3.744 ether,
                xStartVirtualReserve: 1.296 ether,
                yStartVirtualReserve: 1_080_000_000 ether,
                yMintAmount: 1_000_000_000 ether,
                yReservedForLP: 200_000_000 ether,
                yReservedForCurve: 800_000_000 ether
            }),
            MarketFactory.FeeParameters({
                feeTo: address(this),
                BASIS_POINTS: 10_000,
                initiationFee: initiationFee,
                tradeFee: 100,
                graduationFee: graduationFee
            }),
            WETH,
            FACTORY,
            ROUTER
        );
    }

    function test_MarketCreated() public {
        factory.createMarket{value: initiationFee}("Test Token", "TT");
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

        (uint256 x, uint256 y) = curve.getReserves();
        assertEq(x, 1.296 ether);
        assertEq(y, 1_080_000_000 ether);

        (uint256 cap, uint256 xReserve, uint256 yReserve, uint256 yLP, uint256 yCurve) = curve.getParams();
        assertEq(cap, 3.744 ether);
        assertEq(xReserve, 1.296 ether);
        assertEq(yReserve, 1_080_000_000 ether);
        assertEq(yLP, 200_000_000 ether);
        assertEq(yCurve, 800_000_000 ether);
    }
}
