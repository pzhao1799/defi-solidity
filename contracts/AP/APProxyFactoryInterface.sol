// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "./APProxy.sol";

abstract contract APProxyFactoryInterface {
    function build(address owner) public virtual returns (APProxy proxy);
    function build() public virtual returns (APProxy proxy);
}