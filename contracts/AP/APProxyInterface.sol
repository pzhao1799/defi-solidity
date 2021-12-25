pragma solidity ^0.6.0;

import "./APProxy.sol";

abstract contract APProxyFactoryInterface {
    function build(address owner) public virtual returns (APProxy proxy);
}