// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {UniswapV2LiquidityAdapter} from "../../../src/core/adapters/UniswapV2Adapter.sol";
import {MarketToken} from "../../../src/core/MarketToken.sol";

import {IUniswapV2Factory} from "../../../src/interfaces/uniswapV2/IUniswapV2Factory.sol";

/**
 * @title UniswapV2LiquidityAdapter Test
 * @notice The variables used in the contract are from Base Mainnet. This should be run as a test on the local fork of Base.
 */
contract UniV2AdapterTest is Test {
    MarketToken public token;

    UniswapV2LiquidityAdapter public adapter;

    address constant WETH = address(0x4200000000000000000000000000000000000006);
    address constant FACTORY = address(0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6);
    address constant ROUTER = address(0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24);

    uint256 public constant tokenToSupply = 200_000_000 ether;
    uint256 public constant ethToSupply = 3.644 ether; // from NOTES.md

    string constant BASE_URL = "https://mainnet.base.org";
    uint256 constant FORK_BLOCK = 16842704;

    function setUp() public {
        vm.createSelectFork(BASE_URL);
        vm.rollFork(FORK_BLOCK);

        token = new MarketToken("Test Token", "TT", address(this), address(this), tokenToSupply);
        token.setGraduated(true);

        adapter = new UniswapV2LiquidityAdapter(WETH, address(FACTORY), ROUTER);
    }

    function test_AdapterConstructor() public {
        adapter = new UniswapV2LiquidityAdapter(WETH, address(FACTORY), ROUTER);
        assertEq(address(adapter.WETH()), WETH);
        assertEq(address(adapter.factory()), FACTORY);
        assertEq(address(adapter.router()), ROUTER);
    }

    function test_CreatePairAndAddLiquidityETH() public {
        (uint256 tokenBalanceBefore, uint256 etherBalanceBefore) =
            (token.balanceOf(address(this)), address(this).balance);

        address pair = IUniswapV2Factory(FACTORY).getPair(address(token), WETH);
        assertEq(pair, address(0), "Pair should not exist");

        console.log(tokenBalanceBefore);
        token.approve(address(adapter), tokenToSupply);
        adapter.createPairAndAddLiquidityETH{value: ethToSupply}(
            address(token), ethToSupply, tokenToSupply, address(this)
        );

        pair = IUniswapV2Factory(FACTORY).getPair(address(token), WETH);
        (uint256 tokenBalanceAfter, uint256 etherBalanceAfter) = (token.balanceOf(address(this)), address(this).balance);

        assertTrue(pair != address(0), "Pair should exist");
        assertEq(tokenBalanceAfter, tokenBalanceBefore - tokenToSupply);
        assertEq(etherBalanceAfter, etherBalanceBefore - ethToSupply);
    }

    function test_CreatePairAndAddLiquidityETHWithInvalidETH() public {
        token.approve(address(adapter), tokenToSupply);

        vm.expectRevert(UniswapV2LiquidityAdapter.InsufficientETH.selector);
        adapter.createPairAndAddLiquidityETH{value: ethToSupply - 1}(
            address(token), ethToSupply, tokenToSupply, address(this)
        );
    }
}
