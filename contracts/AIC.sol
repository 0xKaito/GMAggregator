// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IGMP.sol";

contract AIC {
    // State variables
    address owner;
    IGMP[] public gmpServices;

    // Events
    event MessageSent(bytes indexed message, address indexed gmpService);
    event MessageReceived(bytes indexed message, address indexed gmpService);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to add a new GMP service
    function addGMPService(address _gmpService) external onlyOwner {
        IGMP gmp = IGMP(_gmpService);
        gmpServices.push(gmp);
    }

    // Function to send a message via a selected GMP service
    function sendMessage(
        bytes calldata message,
        uint256 destChainId,
        uint gmpIndex
    ) external payable {
        require(gmpIndex < gmpServices.length, "Invalid GMP service index");
        IGMP gmpService = gmpServices[gmpIndex];
        gmpService.sendMessage{value: msg.value}(
            msg.sender,
            message,
            destChainId
        );
        emit MessageSent(message, address(gmpService));
    }

    // Callback function that the GMP service will call to deliver the message
    function receiveMessage(bytes calldata message, uint gmpIndex) external {
        require(gmpIndex < gmpServices.length, "Invalid GMP service index");
        // Verify that the message is from a registered GMP service
        IGMP gmpService = gmpServices[gmpIndex];
        require(
            msg.sender == address(gmpService),
            "Invalid GMP service sender"
        );

        // Process the message
        // ...

        emit MessageReceived(message, msg.sender);
    }

    // Add more functions related to the contract's logic here
    // ...
}
