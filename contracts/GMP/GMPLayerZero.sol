// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "hardhat/console.sol";

contract GMPLayerZero is NonblockingLzApp {
    bytes public lstmessage;
    string public ms;

    /// @param _lzEndPoint The Layer Zero EndPoint contract address.
    constructor(address _lzEndPoint) NonblockingLzApp(_lzEndPoint) {}

    event SendPacket(
        address indexed account,
        bytes path,
        uint16 indexed dstChainId,
        uint64 nonce
    );

    function sendMessage(
        address account,
        bytes calldata message,
        uint256 _dstChainId
    ) external payable {
        uint16 dstChainId = uint16(_dstChainId);
        console.log("gmp layer send message");
        bytes memory adapterParam = _lzAdapterParam(0, dstChainId);

        ILayerZeroEndpoint iEndpoint = ILayerZeroEndpoint(lzEndpoint);

        _lzSend(
            dstChainId,
            message,
            payable(account),
            address(0x0),
            adapterParam,
            msg.value
        );

        uint64 outBoundNonce = iEndpoint.getOutboundNonce(
            dstChainId,
            address(this)
        );

        {
            bytes memory path = trustedRemoteLookup[dstChainId];
            emit SendPacket(account, path, dstChainId, outBoundNonce);
        }
    }

    function receiveMessage(bytes calldata message) external {}

    function _lzAdapterParam(
        uint16 packetType,
        uint16 dstChainId
    ) internal view returns (bytes memory) {
        uint16 version = 1;
        uint expectedGas = minDstGasLookup[dstChainId][packetType];

        return abi.encodePacked(version, expectedGas);
    }

    function _nonblockingLzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory _payload
    ) internal override {
        lstmessage = _payload;
    }
}
