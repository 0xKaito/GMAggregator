# Cross-Chain Generalized Aggregator (CCGA)

## Introduction
The Cross-Chain Generalized Aggregator (CCGA) is a smart contract platform designed to enable dApps to customize their cross-chain messaging and interactions. With a focus on flexibility and security, CCGA allows dApps to select from multiple General Messaging Partners (GMPs) such as LayerZero and CCIP, determining the appropriate level of security and redundancy for their specific needs.

## Components

### Aggregator Interface Contract (AC)
The core smart contract that interfaces with multiple GMPs. It serves as the primary point of interaction for dApps, routing messages and managing cross-chain communication.

### GMP Interface Contracts
Individual smart contracts for each GMP, adhering to a unified interface for message sending. These are called by the AC to facilitate message delivery.

### Security Level Selector
A built-in function of the AC allowing dApps to specify their desired level of security for each action, enabling a choice in the number of GMPs required.

## Conclusion
The CCGA provides a customizable and secure framework for dApps to engage in cross-chain activities, from routine transfers to complex operations. It is built with the vision of empowering dApps with the autonomy to define their cross-chain interaction schemes while maintaining high standards of security and reliability.
