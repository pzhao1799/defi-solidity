// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

abstract contract IDSProxy {

    function execute(address _target, bytes memory _data) public payable virtual returns (bytes32);

    function setCache(address _cacheAddr) public payable virtual returns (bool);

    function owner() public view virtual returns (address);
}