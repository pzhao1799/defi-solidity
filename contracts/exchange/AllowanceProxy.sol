pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../auth/AdminAuth.sol";
import "./APExchange.sol";
import "../utils/SafeERC20.sol";

contract AllowanceProxy is AdminAuth {

    using SafeERC20 for ERC20;

    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    APExchange apExchange = APExchange(0xc2Ce04e2FB4DD20964b4410FcE718b95963a1587);

    function callSell(APExchangeCore.ExchangeData memory exData) public payable {
        pullAndSendTokens(exData.srcAddr, exData.srcAmount);

        apExchange.sell{value: msg.value}(exData, msg.sender);
    }

    function callBuy(APExchangeCore.ExchangeData memory exData) public payable {
        pullAndSendTokens(exData.srcAddr, exData.srcAmount);

        apExchange.buy{value: msg.value}(exData, msg.sender);
    }

    function pullAndSendTokens(address _tokenAddr, uint _amount) internal {
        if (_tokenAddr == KYBER_ETH_ADDRESS) {
            require(msg.value >= _amount, "msg.value smaller than amount");
        } else {
            ERC20(_tokenAddr).safeTransferFrom(msg.sender, address(apExchange), _amount);
        }
    }

    function ownerChangeExchange(address payable _newExchange) public onlyOwner {
        apExchange = APExchange(_newExchange);
    }
}