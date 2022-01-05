// SPDX-License-Identifier: MIT

// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

abstract contract IFeeRecipient {
    function getFeeAddr() public view virtual returns (address);
    function changeWalletAddr(address _newWallet) public virtual;
}