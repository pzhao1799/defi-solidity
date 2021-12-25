pragma solidity ^0.6.0;


abstract contract APAuthority {
    function canCall(address src, address dst, bytes4 sig) public virtual view returns (bool);
}