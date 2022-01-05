// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

import "../AP/APMath.sol";
import "../interfaces/IWAVAX.sol";
import "../interfaces/exchange/IExchangeV3.sol";
import "./APExchangeData.sol";
import "../utils/Discount.sol";
import "../utils/FeeRecipient.sol";
import "./APExchangeHelper.sol";
import "./ProtectorExchangeRegistry.sol";
import "./helpers/ExchangeHelper.sol";

contract APExchangeCore is APExchangeHelper, APMath, APExchangeData, ExchangeHelper {
    using SafeERC20 for IERC20;
    using TokenUtils for address;

    string public constant ERR_SLIPPAGE_HIT = "Slippage hit";
    string public constant ERR_DEST_AMOUNT_MISSING = "Dest amount missing";
    string public constant ERR_WRAPPER_INVALID = "Wrapper invalid";
    FeeRecipient public constant feeRecipient =
        FeeRecipient(FEE_RECIPIENT_ADDRESS);

    /// @notice Internal method that preforms a sell on 0x/on-chain
    /// @dev Useful for other AP contract to integrate for exchanging
    /// @param exData Exchange data struct
    /// @return (address, uint) Address of the wrapper used and destAmount
    function _sell(ExchangeData memory exData) internal returns (address, uint256) {
        uint256 amountWithoutFee = exData.srcAmount;

        uint256 destBalanceBefore = exData.destAddr.getBalance(address(this));

        // Takes AP exchange fee
        if (exData.apFeeDivider != 0) {
            exData.srcAmount = sub(exData.srcAmount, getFee(
                exData.srcAmount,
                exData.user,
                exData.srcAddr,
                exData.apFeeDivider
            ));
        }

        onChainSwap(exData, ActionType.SELL);
        address wrapper = exData.wrapper;

        uint256 destBalanceAfter = exData.destAddr.getBalance(address(this));
        uint256 amountBought = sub(destBalanceAfter, destBalanceBefore);

        // check slippage
        require(amountBought >= wmul(exData.minPrice, exData.srcAmount), ERR_SLIPPAGE_HIT);

        // revert back exData changes to keep it consistent
        exData.srcAmount = amountWithoutFee;

        return (wrapper, amountBought);
    }

    /// @notice Internal method that preforms a buy on 0x/on-chain
    /// @dev Useful for other AP contract to integrate for exchanging
    /// @param exData Exchange data struct
    /// @return (address, uint) Address of the wrapper used and srcAmount
    function _buy(ExchangeData memory exData) internal returns (address, uint256) {
        require(exData.destAmount != 0, ERR_DEST_AMOUNT_MISSING);

        uint256 amountWithoutFee = exData.srcAmount;

        uint256 destBalanceBefore = exData.destAddr.getBalance(address(this));

        // Takes AP exchange fee
        if (exData.apFeeDivider != 0) {
            exData.srcAmount = sub(exData.srcAmount, getFee(
                exData.srcAmount,
                exData.user,
                exData.srcAddr,
                exData.apFeeDivider
            ));
        }

        onChainSwap(exData, ActionType.BUY);
        address wrapper = exData.wrapper;

        uint256 destBalanceAfter = exData.destAddr.getBalance(address(this));
        uint256 amountBought = sub(destBalanceAfter, destBalanceBefore);

        // check slippage
        require(amountBought >= exData.destAmount, ERR_SLIPPAGE_HIT);

        // revert back exData changes to keep it consistent
        exData.srcAmount = amountWithoutFee;

        return (wrapper, amountBought);
    }

    /// @notice Calls wrapper contract for exchange to preform an on-chain swap
    /// @param _exData Exchange data struct
    /// @param _type Type of action SELL|BUY
    /// @return swappedTokens For Sell that the destAmount, for Buy thats the srcAmount
    function onChainSwap(ExchangeData memory _exData, ActionType _type)
        internal
        returns (uint256 swappedTokens)
    {
        require(
            ProtectorExchangeRegistry(PROTECTOR_EXCHANGE_REGISTRY).isWrapper(_exData.wrapper),
            ERR_WRAPPER_INVALID
        );

        IERC20(_exData.srcAddr).safeTransfer(_exData.wrapper, _exData.srcAmount);

        if (_type == ActionType.SELL) {
            swappedTokens = IExchangeV3(_exData.wrapper).sell(
                _exData.srcAddr,
                _exData.destAddr,
                _exData.srcAmount,
                _exData.wrapperData
            );
        } else {
            swappedTokens = IExchangeV3(_exData.wrapper).buy(
                _exData.srcAddr,
                _exData.destAddr,
                _exData.destAmount,
                _exData.wrapperData
            );
        }
    }

    /// @notice Takes a feePercentage and sends it to wallet
    /// @param _amount Dai amount of the whole trade
    /// @param _user Address of the user
    /// @param _token Address of the token
    /// @param _apFeeDivider AP fee divider
    /// @return feeAmount Amount in Dai owner earned on the fee
    function getFee(
        uint256 _amount,
        address _user,
        address _token,
        uint256 _apFeeDivider
    ) internal returns (uint256 feeAmount) {
        if (_apFeeDivider != 0 && Discount(DISCOUNT_ADDRESS).isCustomFeeSet(_user)) {
            _apFeeDivider = Discount(DISCOUNT_ADDRESS).getCustomServiceFee(_user);
        }

        if (_apFeeDivider == 0) {
            feeAmount = 0;
        } else {
            feeAmount = _amount / _apFeeDivider;

            // fee can't go over 10% of the whole amount
            if (feeAmount > (_amount / 10)) {
                feeAmount = _amount / 10;
            }

            address walletAddr = feeRecipient.getFeeAddr();

            _token.withdrawTokens(walletAddr, feeAmount);
        }
    }

}
