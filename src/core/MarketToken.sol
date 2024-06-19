// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token created by the Market Factory
 */
contract MarketToken is ERC20 {
    constructor(string memory _name, string memory _symbol, address receiver, uint256 _initialSupply)
        ERC20(_name, _symbol)
    {
        _mint(receiver, _initialSupply);
    }
}
