// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/core/MarketFactory.sol";

contract FactoryScript is Script {
    function setUp() public {}

    uint128 constant initiationFee = 0.0015 ether;
    uint128 constant graduationFee = 0.005 ether;
    address constant WETH = address(0x123);
    address constant FACTORY = address(0x123);
    address constant ROUTER = address(0x123);

    function sellToken(
        MarketToken token,
        MarketCurve curve,
        uint256 amount
    ) public returns (uint256) {
        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();
        console.log("=====================================");
        console.log("Selling token with amount: %d", amount);
        console.log(
            "Before: xReserve: %d, yReserve: %d",
            xReserveBefore,
            yReserveBefore
        );
        console.log(
            "Before: xBalance: %d, yBalance: %d",
            xBalanceBefore,
            yBalanceBefore
        );

        token.approve(address(curve), amount);
        uint256 ethReceived = curve.sell(amount, 1);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        console.log("-------------------------------------");
        console.log("Eth received: %d", ethReceived);
        console.log(
            "After: xReserve: %d, yReserve: %d",
            xReserveAfter,
            yReserveAfter
        );
        console.log(
            "After: xBalance: %d, yBalance: %d",
            xBalanceAfter,
            yBalanceAfter
        );

        return ethReceived;
    }

    function buyToken(
        MarketCurve curve,
        uint256 amount
    ) public returns (uint256) {
        (uint256 xReserveBefore, uint256 yReserveBefore) = curve.getReserves();
        (uint256 xBalanceBefore, uint256 yBalanceBefore) = curve.getBalances();
        console.log("=====================================");
        console.log("Buying token with amount: %d", amount);
        console.log(
            "Before: xReserve: %d, yReserve: %d",
            xReserveBefore,
            yReserveBefore
        );
        console.log(
            "Before: xBalance: %d, yBalance: %d",
            xBalanceBefore,
            yBalanceBefore
        );

        uint256 tokensBought = curve.buy{value: amount}(amount, 1);

        (uint256 xReserveAfter, uint256 yReserveAfter) = curve.getReserves();
        (uint256 xBalanceAfter, uint256 yBalanceAfter) = curve.getBalances();

        console.log("-------------------------------------");
        console.log("Tokens bought: %d", tokensBought);
        console.log(
            "After: xReserve: %d, yReserve: %d",
            xReserveAfter,
            yReserveAfter
        );
        console.log(
            "After: xBalance: %d, yBalance: %d",
            xBalanceAfter,
            yBalanceAfter
        );

        return tokensBought;
    }

    function runCurveSimualtion(
        string memory name,
        string memory symbol
    ) public {
        MarketFactory factory = new MarketFactory(
            MarketFactory.MarketParameters({
                liquidityCap: 3.744 ether,
                xStartVirtualReserve: 1.296 ether,
                yStartVirtualReserve: 1_080_000_000 ether,
                yMintAmount: 1_000_000_000 ether,
                yReservedForLP: 200_000_000 ether,
                yReservedForCurve: 800_000_000 ether
            }),
            MarketFactory.FeeParameters({
                feeTo: address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8),
                BASIS_POINTS: 10_000,
                initiationFee: initiationFee,
                initialBuyFee: 200,
                tradeFee: 100,
                graduationFee: graduationFee
            }),
            WETH,
            FACTORY,
            ROUTER
        );
        console.log("Factory deployed at", address(factory));
        address owner = factory.owner();
        console.log("Owner is", owner);
        factory.createMarket{value: 0.0015 ether}(name, symbol, false, 0);
        address deployedToken = factory.allTokens(0);
        MarketCurve deployedCurve = factory.tokenToCurve(
            MarketToken(deployedToken)
        );
        uint256 amount1 = buyToken(deployedCurve, 1 ether);
        sellToken(MarketToken(deployedToken), deployedCurve, amount1 / 2);
        uint256 amount2 = buyToken(deployedCurve, 1 ether);
        sellToken(MarketToken(deployedToken), deployedCurve, amount2 / 2);
        uint256 amount3 = buyToken(deployedCurve, 1 ether);
        sellToken(MarketToken(deployedToken), deployedCurve, amount3);
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address payable account = payable(vm.addr(deployerPrivateKey));
        console.log("Deployer address is", account);

        vm.startBroadcast(deployerPrivateKey);
        runCurveSimualtion("Test Token 1", "TT1");
        vm.stopBroadcast();
        vm.startBroadcast(deployerPrivateKey);
        runCurveSimualtion("Test Token 2", "TT2");
        vm.stopBroadcast();
    }
}
