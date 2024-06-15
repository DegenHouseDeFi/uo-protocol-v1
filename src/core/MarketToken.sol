// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {MarketManager} from "./MarketManager.sol";

/**
 * @title Token created by the Market Factory
 */
contract MarketToken is ERC20 {
    MarketManager immutable manager;
    constructor(
        string memory _name,
        string memory _symbol,
        MarketManager _manager
    ) ERC20(_name, _symbol) {
        _mint(_manager, 1_000_000_000 * 10 ** decimals());
        manager = _manager;
    }
}
