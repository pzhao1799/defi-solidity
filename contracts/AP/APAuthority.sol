// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;


abstract contract APAuthority {
    function canCall(address src, address dst, bytes4 sig) public virtual view returns (bool);
}