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

```mermaid
graph TD
    AIC[Aggregator Interface Contract] -->|Registers / Manages| GMPR[GMP Registry Contract]
    AIC -->|Defines Security Policies| SPC[Security Policy Contract]
    AIC -->|Manages Queue| MQC[Message Queue Contract]
    AIC -->|Message Verification| VC[Verification Contract]
    AIC -->|Handles Specific Actions| AH[Action Handlers]
    AIC -->|Fallback Mechanism| FHC[Fallback Handler Contract]
    GMPR -->|Interface for GMPs| GMPIC1[GMP Interface Contract 1]
    GMPR -->|Interface for GMPs| GMPIC2[GMP Interface Contract 2]
    GMPR -->|Interface for GMPs| GMPIC3[GMP Interface Contract 3]
    GOV[Governance Contract] -->|Governs Whole System| AIC
    GOV -->|Governs GMPs| GMPR

    classDef contract fill:#f9f,stroke:#333,stroke-width:2px;
    class AIC,GMPR,SPC,MQC,VC,AH,FHC,GMPIC1,GMPIC2,GMPIC3,GOV contract;

```
## Case Scenario 
Below is a case when, a complex action such as liquidation requires confirmations from both GMPs (CCIP and LayerZero in our case)

```mermaid
sequenceDiagram
    participant dApp
    participant AIC as Aggregator Interface Contract
    participant SPC as Security Policy Contract
    participant GMPIC_LZ as GMP Interface Contract (LayerZero)
    participant GMPIC_CCIP as GMP Interface Contract (CCIP)
    participant RHC as Receiver Handler Contract
    participant VC as Verification Contract
    participant AH as Action Handler

    dApp->>AIC: Initiate liquidation
    AIC->>SPC: Check security policy for liquidation
    SPC-->>AIC: Requires both GMP confirmations
    AIC->>GMPIC_LZ: Send message via LayerZero
    AIC->>GMPIC_CCIP: Send message via CCIP
    GMPIC_LZ->>RHC: Deliver message to target chain
    GMPIC_CCIP->>RHC: Deliver message to target chain
    RHC->>VC: Verify message authenticity
    VC-->>AIC: All messages verified
    AIC->>AH: Execute liquidation action


```

