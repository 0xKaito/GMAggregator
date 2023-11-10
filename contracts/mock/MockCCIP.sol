// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";

interface ICCIPReceiver {
    function ccipReceive(Client.Any2EVMMessage calldata message) external;
}

contract MockCCIP {
    uint64 public chainId;
    uint256 public id;
    mapping(uint64 => uint256) public nativeFee;
    mapping(uint64 => address) public dstCCIP;

    constructor(uint64 _chain) {
        chainId = _chain;
    }

    function setDstCCIP(uint64 chain, address cp) external {
        dstCCIP[chain] = cp;
    }

    function setFee(uint64 chain, uint256 fee) external {
        nativeFee[chain] = fee;
    }

    function getFee(
        uint64 destinationChainSelector,
        Client.EVM2AnyMessage memory message
    ) external view returns (uint256 fee) {
        fee = message.data.length * nativeFee[destinationChainSelector];
    }

    function ccipSend(
        uint64 destinationChainSelector,
        Client.EVM2AnyMessage calldata message
    ) external payable returns (bytes32) {
        bytes32 messageid = bytes32(++id);
        Client.Any2EVMMessage memory message1 = Client.Any2EVMMessage({
            messageId: messageid, // MessageId corresponding to ccipSend on source.
            sourceChainSelector: chainId, // Source chain selector.
            sender: abi.encode(msg.sender), // abi.decode(sender) if coming from an EVM chain.
            data: message.data, // payload sent in original message.
            destTokenAmounts: message.tokenAmounts
        });
        ICCIPReceiver(dstCCIP[destinationChainSelector]).ccipReceive(message1);
        return messageid;
    }
}
