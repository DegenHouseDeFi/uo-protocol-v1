// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IUniswapV2Factory} from "../../interfaces/uniswapV2/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "../../interfaces/uniswapV2/IUniswapV2Router02.sol";

contract UniswapV2LiquidityAdapter {
    address public immutable WETH;
    IUniswapV2Factory public immutable factory;
    IUniswapV2Router02 public immutable router;

    constructor(address _WETH, address _factory, address _router) {
        WETH = _WETH;
        factory = IUniswapV2Factory(_factory);
        router = IUniswapV2Router02(_router);
    }

    function createPairAndAddLiquidityETH(address token, uint256 xToSupply, uint256 yToSupply, address to)
        external
        payable
    {
        require(msg.value >= xToSupply, "INSUFFICIENT_ETH");

        // Create pair if it doesn't exist
        address pair = IUniswapV2Factory(factory).getPair(token, WETH);
        if (pair == address(0)) {
            pair = IUniswapV2Factory(factory).createPair(token, WETH);
        }

        router.addLiquidityETH{value: xToSupply}(token, yToSupply, 1, 1, to, block.timestamp);
    }
}
