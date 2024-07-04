// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title Token created by the Market Factory
 */
contract MarketToken is ERC20 {
    error Token_UnauthorizedTransfer(address from, address to);
    error Token_UnauthorizedAccess();

    address public immutable mom;
    mapping(address => bool) public allowedTransfer;
    bool public isGraduated = false;

    constructor(string memory _name, string memory _symbol, address _receiver, address _mom, uint256 _initialSupply)
        ERC20(_name, _symbol)
    {
        mom = _mom;

        allowedTransfer[_receiver] = true;
        allowedTransfer[_mom] = true;
        _mint(_receiver, _initialSupply);
    }

    function _update(address from, address to, uint256 value) internal override {
        if (isGraduated || allowedTransfer[from] || allowedTransfer[to]) {
            super._update(from, to, value);
        } else {
            revert Token_UnauthorizedTransfer(from, to);
        }
    }

    function setGraduated(bool _isGraduated) external {
        if (msg.sender != mom) {
            revert Token_UnauthorizedAccess();
        }
        isGraduated = _isGraduated;
    }
}
