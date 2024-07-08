// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title MarketToken
 * @dev Contract representing the ERC-20 token with limited transferability until graduation.
 */
contract MarketToken is ERC20 {
    /**
     * @dev Emitted when a token transfer is unauthorized.
     * @param from The address from which the transfer was attempted.
     * @param to The address to which the transfer was attempted.
     */
    error Token_UnauthorizedTransfer(address from, address to);

    /**
     * @dev Emitted when an unauthorized access is attempted.
     */
    error Token_UnauthorizedAccess();

    address public immutable mom;
    mapping(address => bool) public allowedTransfer;
    bool public isGraduated = false;

    /**
     * @dev Constructor function for the MarketToken contract.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _receiver The address of the receiver.
     * @param _mom The address of the mom.
     * @param _initialSupply The initial supply of the token.
     */
    constructor(string memory _name, string memory _symbol, address _receiver, address _mom, uint256 _initialSupply)
        ERC20(_name, _symbol)
    {
        mom = _mom;

        allowedTransfer[_receiver] = true;
        allowedTransfer[_mom] = true;
        _mint(_receiver, _initialSupply);
    }

    /**
     * @dev Internal function to update token balances on transfers.
     * @param from The address from which the tokens are transferred.
     * @param to The address to which the tokens are transferred.
     * @param value The amount of tokens being transferred.
     */
    function _update(address from, address to, uint256 value) internal override {
        if (isGraduated || allowedTransfer[from] || allowedTransfer[to]) {
            super._update(from, to, value);
        } else {
            revert Token_UnauthorizedTransfer(from, to);
        }
    }

    /**
     * @dev Sets the graduated status of the token.
     * @param _isGraduated The graduated status to be set.
     */
    function setGraduated(bool _isGraduated) external {
        if (msg.sender != mom) {
            revert Token_UnauthorizedAccess();
        }
        isGraduated = _isGraduated;
    }
}
