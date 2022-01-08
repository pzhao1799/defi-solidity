// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "./APProxyRegistry.sol";
import "../interfaces/IAPProxy.sol";
import "../AP/APProxyFactoryInterface.sol";
import "./helpers/UtilHelper.sol";


/// @title User facing contract to manage new proxies (is owner of APProxyRegistry)
contract APProxyRegistryController is AdminAuth, UtilHelper {

    /// @dev List of prebuild proxies the users can claim to save gas
    address[] public proxyPool;

    event NewProxy(address, address);
    event ChangedOwner(address, address);

    /// @notice User calls from EOA to build a new AP registred proxy
    function addNewProxy() public returns (address) {
        address newProxy = getFromPoolOrBuild(msg.sender);
        APProxyRegistry(AP_PROXY_REGISTRY_ADDR).addAdditionalProxy(msg.sender, newProxy);

        emit NewProxy(msg.sender, newProxy);

        return newProxy;
    }

    /// @notice Will change owner of proxy in APRegistry
    /// @dev Still need to .setOwner() in APProxy first
    /// @dev msg.sender == APProxy which calls this method
    function changeOwnerInAPRegistry(address _newOwner) public {
        APProxyRegistry(AP_PROXY_REGISTRY_ADDR).changeMcdOwner(_newOwner, msg.sender);

        emit ChangedOwner(_newOwner, msg.sender);
    }

    /// @notice Adds proxies to pool for users to later claim and save on gas
    function addToPool(uint256 _numNewProxies) public {
        for (uint256 i = 0; i < _numNewProxies; ++i) {
            APProxy newProxy = APProxyFactoryInterface(PROXY_FACTORY_ADDR).build();
            proxyPool.push(address(newProxy));
        }
    }

    /// @notice Created a new APProxy or grabs a prebuilt one
    function getFromPoolOrBuild(address _user) internal returns (address) {
        if (proxyPool.length > 0) {
            address newProxy = proxyPool[proxyPool.length - 1];
            proxyPool.pop();

            APAuth(newProxy).setOwner(_user);

            return newProxy;
        } else {
            APProxy newProxy = APProxyFactoryInterface(PROXY_FACTORY_ADDR).build(_user);
            return address(newProxy);
        }
    }

    function getProxies(address _user) public view returns (address[] memory) {
        (address mcdProxy, address[] memory additionalProxies) = APProxyRegistry(
            AP_PROXY_REGISTRY_ADDR
        ).getAllProxies(_user);

        if (mcdProxy == address(0)) {
            return additionalProxies;
        }

        address[] memory proxies = new address[](additionalProxies.length + 1);
        proxies[0] = mcdProxy;

        if (additionalProxies.length == 0) {
            return proxies;
        }

        for (uint256 i = 0; i < additionalProxies.length; ++i) {
            proxies[i + 1] = additionalProxies[i];
        }

        return proxies;
    }

    function getProxyPoolCount() public view returns (uint256) {
        return proxyPool.length;
    }
}