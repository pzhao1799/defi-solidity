// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "./IERC20.sol";

abstract contract GasTokenInterface is IERC20 {
    function free(uint256 value) public virtual returns (bool success);

    function freeUpTo(uint256 value) public virtual returns (uint256 freed);

    function freeFrom(address from, uint256 value) public virtual returns (bool success);

    function freeFromUpTo(address from, uint256 value) public virtual returns (uint256 freed);
}