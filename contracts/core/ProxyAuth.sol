// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "../interfaces/IAPRegistry.sol";
import "../interfaces/IAPProxy.sol";
import "../auth/AdminAuth.sol";
import "./helpers/CoreHelper.sol";

/// @title ProxyAuth Gets APProxy auth from users and is callable by the Executor
contract ProxyAuth is AdminAuth, CoreHelper {

    IAPRegistry public constant registry = IAPRegistry(REGISTRY_ADDR);

    bytes32 constant STRATEGY_EXECUTOR_ID = keccak256("StrategyExecutor");
    string public constant ERR_SENDER_NOT_EXECUTOR = "Sender not executor addr";

    modifier onlyExecutor {
        address executorAddr = registry.getAddr(STRATEGY_EXECUTOR_ID);
        require(msg.sender == executorAddr, ERR_SENDER_NOT_EXECUTOR);
        _;
    }

    /// @notice Calls the .execute() method of the specified users APProxy
    /// @dev Contract gets the authority from the user to call it, only callable by Executor
    /// @param _proxyAddr Address of the users APProxy
    /// @param _contractAddr Address of the contract which to execute
    /// @param _data Call data of the function to be called
    function callExecute(
        address _proxyAddr,
        address _contractAddr,
        bytes memory _data
    ) public payable onlyExecutor {

        IAPProxy(_proxyAddr).execute{value: msg.value}(_contractAddr, _data);

        // return if anything left
        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }

}