// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "../auth/AdminAuth.sol";

contract ProtectorExchangeRegistry is AdminAuth {

	mapping(address => bool) private wrappers;

	function addWrapper(address _wrapper) public onlyOwner {
		wrappers[_wrapper] = true;
	}

	function removeWrapper(address _wrapper) public onlyOwner {
		wrappers[_wrapper] = false;
	}

	function isWrapper(address _wrapper) public view returns(bool) {
		return wrappers[_wrapper];
	}
}
