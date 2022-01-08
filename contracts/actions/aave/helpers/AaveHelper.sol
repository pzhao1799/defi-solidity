// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "../../../interfaces/aave/ILendingPool.sol";
import "../../../interfaces/aave/IAaveProtocolDataProvider.sol";
import "../../../interfaces/aave/IAaveIncentivesController.sol";
import "./MainnetAaveAddresses.sol";
import "../../../interfaces/aave/IStakedToken.sol";

/// @title Utility functions and data used in Aave actions
contract AaveHelper is MainnetAaveAddresses {
    uint16 public constant AAVE_REFERRAL_CODE = 64;

    uint256 public constant STABLE_ID = 1;
    uint256 public constant VARIABLE_ID = 2;

    bytes32 public constant DATA_PROVIDER_ID =
        0x0100000000000000000000000000000000000000000000000000000000000000;
    
    IAaveIncentivesController constant public AaveIncentivesController = IAaveIncentivesController(STAKED_CONTROLLER_ADDR);

    IStakedToken constant public StakedToken = IStakedToken(STAKED_TOKEN_ADDR);

    /// @notice Enable/Disable a token as collateral for the specified Aave market
    function enableAsCollateral(
        address _market,
        address _tokenAddr,
        bool _useAsCollateral
    ) public {
        address lendingPool = ILendingPoolAddressesProvider(_market).getLendingPool();

        ILendingPool(lendingPool).setUserUseReserveAsCollateral(_tokenAddr, _useAsCollateral);
    }

    /// @notice Switches the borrowing rate mode (stable/variable) for the user
    function switchRateMode(
        address _market,
        address _tokenAddr,
        uint256 _rateMode
    ) public {
        address lendingPool = ILendingPoolAddressesProvider(_market).getLendingPool();

        ILendingPool(lendingPool).swapBorrowRateMode(_tokenAddr, _rateMode);
    }

    /// @notice Fetch the data provider for the specified market
    function getDataProvider(address _market) internal view returns (IAaveProtocolDataProvider) {
        return
            IAaveProtocolDataProvider(
                ILendingPoolAddressesProvider(_market).getAddress(DATA_PROVIDER_ID)
            );
    }

    /// @notice Returns the lending pool contract of the specified market
    function getLendingPool(address _market) internal view returns (ILendingPool) {
        return ILendingPool(ILendingPoolAddressesProvider(_market).getLendingPool());
    }
}