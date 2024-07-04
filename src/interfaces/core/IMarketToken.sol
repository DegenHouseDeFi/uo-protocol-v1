// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface IMarketToken is IERC20 {
    function setGraduated(bool _isGraduated) external;
}
