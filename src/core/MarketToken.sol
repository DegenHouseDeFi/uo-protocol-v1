// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MarketCurve} from "./MarketCurve.sol";

/**
 * @title Token created by the Market Factory
 */
contract MarketToken is ERC20 {
    MarketCurve immutable curve;
    constructor(
        string memory _name,
        string memory _symbol,
        MarketCurve _curve
    ) ERC20(_name, _symbol) {
        _mint(address(_curve), 1_000_000_000 * 10 ** decimals());
        curve = _curve;
    }
}
