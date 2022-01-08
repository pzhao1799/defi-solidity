// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "../auth/AdminAuth.sol";
import "../interfaces/IProxyRegistry.sol";
import "../interfaces/IAPProxy.sol";
import "./helpers/UtilHelper.sol";

/// @title Checks Mcd registry and replaces the proxy addr if owner changed
contract APProxyRegistry is AdminAuth, UtilHelper {
    IProxyRegistry public mcdRegistry = IProxyRegistry(MKR_PROXY_REGISTRY);

    mapping(address => address) public changedOwners;
    mapping(address => address[]) public additionalProxies;

    /// @notice Changes the proxy that is returned for the user
    /// @dev Used when the user changed APProxy ownership himself
    function changeMcdOwner(address _user, address _proxy) public onlyOwner {
        if (IAPProxy(_proxy).owner() == _user) {
            changedOwners[_user] = _proxy;
        }
    }

    /// @notice Returns the proxy address associated with the user account
    /// @dev If user changed ownership of APProxy admin can hardcode replacement
    function getMcdProxy(address _user) public view returns (address) {
        address proxyAddr = mcdRegistry.proxies(_user);

        // if check changed proxies
        if (changedOwners[_user] != address(0)) {
            return changedOwners[_user];
        }

        return proxyAddr;
    }

    function addAdditionalProxy(address _user, address _proxy) public onlyOwner {
        if (IAPProxy(_proxy).owner() == _user) {
            additionalProxies[_user].push(_proxy);
        }
    }
			
    function getAllProxies(address _user) public view returns (address, address[] memory) {
        return (getMcdProxy(_user), additionalProxies[_user]);
    }
}