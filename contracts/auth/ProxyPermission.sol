// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "../AP/APGuard.sol";
import "../AP/APAuth.sol";

import "./helpers/AuthHelper.sol";

/// @title ProxyPermission Proxy contract which works with APProxy to give execute permission
contract ProxyPermission is AuthHelper {

    /// @notice Called in the context of APProxy to authorize an address
    /// @param _contractAddr Address which will be authorized
    function givePermission(address _contractAddr) public {
        address currAuthority = address(APAuth(address(this)).authority());
        APGuard guard = APGuard(currAuthority);

        if (currAuthority == address(0)) {
            guard = APGuardFactory(FACTORY_ADDRESS).newGuard();
            APAuth(address(this)).setAuthority(APAuthority(address(guard)));
        }

        guard.permit(_contractAddr, address(this), bytes4(keccak256("execute(address,bytes)")));
    }

    /// @notice Called in the context of APProxy to remove authority of an address
    /// @param _contractAddr Auth address which will be removed from authority list
    function removePermission(address _contractAddr) public {
        address currAuthority = address(APAuth(address(this)).authority());

        // if there is no authority, that means that contract doesn't have permission
        if (currAuthority == address(0)) {
            return;
        }

        APGuard guard = APGuard(currAuthority);
        guard.forbid(_contractAddr, address(this), bytes4(keccak256("execute(address,bytes)")));
    }

    function proxyOwner() internal view returns (address) {
        return APAuth(address(this)).owner();
    }
}
