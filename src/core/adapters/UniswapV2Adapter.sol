// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MarketToken} from "../MarketToken.sol";

import {IUniswapV2Factory} from "../../interfaces/uniswapV2/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "../../interfaces/uniswapV2/IUniswapV2Router02.sol";

/**
 * @title UniswapV2LiquidityAdapter
 * @dev A contract that allows creating a Uniswap V2 pair and adding liquidity to it using ETH and ERC20 tokens.
 */
contract UniswapV2LiquidityAdapter {
    event PairCreatedAndLiquidityAdded(
        address indexed token, address pair, address indexed to, uint256 xToSupply, uint256 yToSupply
    );

    error InsufficientETH();

    address public immutable WETH;
    IUniswapV2Factory public immutable factory;
    IUniswapV2Router02 public immutable router;

    /**
     * @dev Initializes the UniswapV2LiquidityAdapter contract.
     * @param _WETH The address of the WETH token.
     * @param _factory The address of the Uniswap V2 factory contract.
     * @param _router The address of the Uniswap V2 router contract.
     */
    constructor(address _WETH, address _factory, address _router) {
        WETH = _WETH;
        factory = IUniswapV2Factory(_factory);
        router = IUniswapV2Router02(_router);
    }

    /**
     * @dev Creates a Uniswap V2 pair and adds liquidity using ETH and ERC20 tokens.
     * @param token The address of the ERC20 token being paired with WETH.
     * @param xToSupply The amount of ETH being supplied.
     * @param yToSupply The amount of ERC20 token being supplied.
     * @param to The address where the liquidity is being added.
     */
    function createPairAndAddLiquidityETH(address token, uint256 xToSupply, uint256 yToSupply, address to)
        external
        payable
    {
        if (msg.value < xToSupply) revert InsufficientETH();

        address pair = IUniswapV2Factory(factory).createPair(token, WETH);

        MarketToken(token).transferFrom(msg.sender, address(this), yToSupply);
        MarketToken(token).approve(address(router), yToSupply);
        router.addLiquidityETH{value: xToSupply}(token, yToSupply, 1, 1, to, block.timestamp);

        emit PairCreatedAndLiquidityAdded(token, pair, to, xToSupply, yToSupply);
    }
}
