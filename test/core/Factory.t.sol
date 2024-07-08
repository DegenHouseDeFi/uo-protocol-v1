// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MarketFactory} from "../../src/core/MarketFactory.sol";
import {MarketToken} from "../../src/core/MarketToken.sol";
import {MarketCurve} from "../../src/core/MarketCurve.sol";

contract MarketFactoryTest is Test {
    MarketFactory public factory;
    address constant WETH = address(0x123);
    address constant FACTORY = address(0x123);
    address constant ROUTER = address(0x123);

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

    function test_FactoryConstructor() public {
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

        assertEq(factory.owner(), address(this));
        assertNotEq(address(factory.dexAdapter()), address(0));

        // check curve params
        (
            uint256 _liquidityCap,
            uint256 _xStartVirtualReserve,
            uint256 _yStartVirtualReserve,
            uint256 _yMintAmount,
            uint256 _yReservedForLP,
            uint256 _yReservedForCurve
        ) = factory.params();
        assertEq(_liquidityCap, 3.744 ether);
        assertEq(_xStartVirtualReserve, 1.296 ether);
        assertEq(_yStartVirtualReserve, 1_080_000_000 ether);
        assertEq(_yMintAmount, 1_000_000_000 ether);
        assertEq(_yReservedForLP, 200_000_000 ether);
        assertEq(_yReservedForCurve, 800_000_000 ether);

        // check fee params
        (address _feeTo, uint256 _BASIS_POINTS, uint256 _initiationFee, uint256 _tradeFee, uint256 _graduationFee) =
            factory.feeParams();
        assertEq(_feeTo, address(this));
        assertEq(_BASIS_POINTS, 10_000);
        assertEq(_initiationFee, initiationFee);
        assertEq(_tradeFee, 100);
        assertEq(_graduationFee, graduationFee);
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

    function testFail_MarketCreateWithWrongFee() public {
        factory.createMarket{value: initiationFee - 1}("Test Token", "TT");
    }

    // test to update all parameters, market, fee, dexAdapter
    function test_UpdateParams() public {
        factory.updateMarketParams(
            2.744 ether, 2.296 ether, 1_010_000_000 ether, 1_000_000_000 ether, 200_000_000 ether, 800_000_000 ether
        );

        (
            uint256 _liquidityCap,
            uint256 _xStartVirtualReserve,
            uint256 _yStartVirtualReserve,
            uint256 _yMintAmount,
            uint256 _yReservedForLP,
            uint256 _yReservedForCurve
        ) = factory.params();
        assertEq(_liquidityCap, 2.744 ether);
        assertEq(_xStartVirtualReserve, 2.296 ether);
        assertEq(_yStartVirtualReserve, 1_010_000_000 ether);
        assertEq(_yMintAmount, 1_000_000_000 ether);
        assertEq(_yReservedForLP, 200_000_000 ether);
        assertEq(_yReservedForCurve, 800_000_000 ether);

        // update fee params
        factory.updateFeeParams(address(this), 10_000, initiationFee, 100, graduationFee);
        // check fee params
        (address _feeTo, uint256 _BASIS_POINTS, uint256 _initiationFee, uint256 _tradeFee, uint256 _graduationFee) =
            factory.feeParams();
        assertEq(_feeTo, address(this));
        assertEq(_BASIS_POINTS, 10_000);
        assertEq(_initiationFee, initiationFee);
        assertEq(_tradeFee, 100);
        assertEq(_graduationFee, graduationFee);

        // update dexAdapter
        factory.newDexAdapter(WETH, FACTORY, ROUTER);
        assertNotEq(address(factory.dexAdapter()), address(0));
    }

    function testFail_UpdateMarketParamsWithWrongCaller() public {
        address random = address(0x123);
        vm.prank(random);

        factory.updateMarketParams(
            2.744 ether, 2.296 ether, 1_010_000_000 ether, 1_000_000_000 ether, 200_000_000 ether, 800_000_000 ether
        );
    }

    function testFail_UpdateFeeParamsWithWrongCaller() public {
        address random = address(0x123);
        vm.prank(random);

        factory.updateFeeParams(address(this), 10_000, initiationFee, 100, graduationFee);
    }

    function testFail_NewDexAdapterWithWrongCaller() public {
        address random = address(0x123);
        vm.prank(random);

        factory.newDexAdapter(WETH, FACTORY, ROUTER);
    }
}
