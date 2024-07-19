// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IMarketToken} from "../interfaces/core/IMarketToken.sol";

/**
 * @title MarketToken
 * @author Manan Gouhari (@manangouhari)
 * @dev Contract representing the ERC-20 token with limited transferability until graduation.
 */
contract MarketToken is ERC20, IMarketToken {
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

    error Token_InvalidParams();

    address public immutable mom;
    mapping(address => bool) public allowedTransfer;
    bool public isGraduated = false;

    /**
     * @dev Constructor function for the MarketToken contract.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _mom The address of the mom (curve).
     * @param _initialSupply The initial supply of the token.
     */
    constructor(string memory _name, string memory _symbol, address _mom, uint256 _initialSupply)
        ERC20(_name, _symbol)
    {
        if (_initialSupply == 0 || _mom == address(0)) {
            revert Token_InvalidParams();
        }

        mom = _mom;

        allowedTransfer[msg.sender] = true;
        allowedTransfer[_mom] = true;

        _mint(_mom, _initialSupply);
    }

    /**
     * @dev Internal function to update token balances on transfers.
     * @dev This function only allows a transfer if the token is graduated or if either the to or from address is allowed for transfer.
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
