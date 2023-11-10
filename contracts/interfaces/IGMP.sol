// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IGMP {
    function sendMessage(
        address account,
        bytes calldata message,
        uint256 destChainId
    ) external payable;

    function receiveMessage(bytes calldata message) external;
}
