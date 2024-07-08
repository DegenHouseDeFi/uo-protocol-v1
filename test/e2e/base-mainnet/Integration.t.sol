// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../../../src/core/MarketFactory.sol";
import {MarketToken} from "../../../src/core/MarketToken.sol";
import {MarketCurve} from "../../../src/core/MarketCurve.sol";

contract BaseIntegrationTest is Test {
    MarketFactory public factory;

    address constant WETH = address(0x4200000000000000000000000000000000000006);
    address constant FACTORY = address(0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6);
    address constant ROUTER = address(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);

    uint256 constant liquidityCap = 3.744 ether;
    uint256 constant xStartVirtualReserve = 1.296 ether;
    uint256 constant yStartVirtualReserve = 1_080_000_000 ether;
    uint256 constant yMintAmount = 1_000_000_000 ether;
    uint256 constant yReservedForLP = 200_000_000 ether;
    uint256 constant yReservedForCurve = 800_000_000 ether;

    uint16 constant BASIS_POINTS = 10_000;
    uint16 constant tradeFee = 100;
    uint128 constant initiationFee = 0.0015 ether;
    uint128 constant graduationFee = 0.0015 ether;

    string constant BASE_URL = "https://mainnet.base.org";
    uint256 constant FORK_BLOCK = 16842704;

    receive() external payable {}

    function setUp() public {
        vm.createSelectFork(BASE_URL);
        vm.rollFork(FORK_BLOCK);

        factory = new MarketFactory(
            MarketFactory.MarketParameters({
                liquidityCap: liquidityCap,
                xStartVirtualReserve: xStartVirtualReserve,
                yStartVirtualReserve: yStartVirtualReserve,
                yMintAmount: yMintAmount,
                yReservedForLP: yReservedForLP,
                yReservedForCurve: yReservedForCurve
            }),
            MarketFactory.FeeParameters({
                feeTo: address(this),
                BASIS_POINTS: BASIS_POINTS,
                tradeFee: tradeFee,
                initiationFee: initiationFee,
                graduationFee: graduationFee
            }),
            WETH,
            FACTORY,
            ROUTER
        );
    }

    function test_BuyTokenAndGraduate() public {
        vm.deal(address(this), 1000 ether);
        factory.createMarket{value: initiationFee}("Test Token", "TT");

        MarketToken token = MarketToken(factory.allTokens(0));
        MarketCurve curve = MarketCurve(factory.tokenToCurve(token));

        assertNotEq(address(token), address(0));
        assertNotEq(address(curve), address(0));
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Trading));

        // uint256 amount = buyToken(curve, 1 ether);
        buyToken(curve, 1 ether);
        // sellToken(token, curve, amount);

        buyToken(curve, 5 ether);
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.CapReached));

        curve.graduate();
        assertEq(uint256(curve.status()), uint256(MarketCurve.Status.Graduated));
    }

    function buyToken(MarketCurve curve, uint256 amount) public returns (uint256) {
        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();
        console.log("=====================================");
        console.log("Buying token with amount: %d", amount);
        console.log("Before: xReserve: %d, yReserve: %d", xReserveBefore, yReserveBefore);
        console.log("Before: xBalance: %d, yBalance: %d", xBalanceBefore, yBalanceBefore);

        uint256 tokensBought = curve.buy{value: amount}(amount, 1);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        console.log("-------------------------------------");
        console.log("Tokens bought: %d", tokensBought);
        console.log("After: xReserve: %d, yReserve: %d", xReserveAfter, yReserveAfter);
        console.log("After: xBalance: %d, yBalance: %d", xBalanceAfter, yBalanceAfter);

        assertEq(yBalanceBefore, yBalanceAfter + tokensBought);
        // assertEq(xBalanceAfter, xBalanceBefore + amount);

        return tokensBought;
    }

    function sellToken(MarketToken token, MarketCurve curve, uint256 amount) public returns (uint256) {
        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();
        console.log("=====================================");
        console.log("Selling token with amount: %d", amount);
        console.log("Before: xReserve: %d, yReserve: %d", xReserveBefore, yReserveBefore);
        console.log("Before: xBalance: %d, yBalance: %d", xBalanceBefore, yBalanceBefore);

        token.approve(address(curve), amount);
        uint256 ethReceived = curve.sell(amount, 1);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        console.log("-------------------------------------");
        console.log("Eth received: %d", ethReceived);
        console.log("After: xReserve: %d, yReserve: %d", xReserveAfter, yReserveAfter);
        console.log("After: xBalance: %d, yBalance: %d", xBalanceAfter, yBalanceAfter);

        assertEq(yBalanceBefore + amount, yBalanceAfter);
        assertEq(xBalanceBefore - ethReceived, xBalanceAfter);

        return ethReceived;
    }
}
