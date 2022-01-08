// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

import "../interfaces/IWAVAX.sol";
import "./SafeERC20.sol";

library TokenUtils {
    using SafeERC20 for IERC20;

    address public constant WAVAX_ADDR = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address internal constant AVAX_BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;


    function approveToken(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) internal {
        if (_tokenAddr == AVAX_BURN_ADDRESS) return;

        if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
            IERC20(_tokenAddr).safeApprove(_to, _amount);
        }
    }

    function pullTokensIfNeeded(
        address _token,
        address _from,
        uint256 _amount
    ) internal returns (uint256) {
        // handle max uint amount
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, _from);
        }

        if (_from != address(0) && _from != address(this) && _token != AVAX_BURN_ADDRESS && _amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }

        return _amount;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, address(this));
        }

        if (_to != address(0) && _to != address(this) && _amount != 0) {
            if (_token != AVAX_BURN_ADDRESS) {
                IERC20(_token).safeTransfer(_to, _amount);
            } else {
                payable(_to).transfer(_amount);
            }
        }

        return _amount;
    }

    function depositWavax(uint256 _amount) internal {
        IWAVAX(WAVAX_ADDR).deposit{value: _amount}();
    }

    function withdrawWavax(uint256 _amount) internal {
        IWAVAX(WAVAX_ADDR).withdraw(_amount);
    }

    function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {
        if (_tokenAddr == AVAX_BURN_ADDRESS) {
            return _acc.balance;
        } else {
            return IERC20(_tokenAddr).balanceOf(_acc);
        }
    }

    function getTokenDecimals(address _token) internal view returns (uint256) {
        if (_token == AVAX_BURN_ADDRESS) return 18;

        return IERC20(_token).decimals();
    }
}
