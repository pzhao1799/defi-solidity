// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;


abstract contract APGuard {
    function canCall(address src_, address dst_, bytes4 sig) public view virtual returns (bool);

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public virtual;

    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public virtual;

    function permit(address src, address dst, bytes32 sig) public virtual;

    function forbid(address src, address dst, bytes32 sig) public virtual;
}

abstract contract APGuardFactory {
    function newGuard() public virtual returns (APGuard guard);
}