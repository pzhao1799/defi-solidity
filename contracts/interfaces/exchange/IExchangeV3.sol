// SPDX-License-Identifier: MIT

pragma solidity =0.7.6;

interface IExchangeV3 {
    function sell(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);

    function buy(address _srcAddr, address _destAddr, uint _destAmount, bytes memory _additionalData) external returns(uint);

    function getSellRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);

    function getBuyRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);
}