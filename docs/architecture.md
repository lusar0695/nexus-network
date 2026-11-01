# NEXUS Pay — MVP Architecture

## Objective
Demonstrate a verifiable payment workflow between two independent service agents without requiring either agent to trust the other's private database for settlement.

## Components
- **Buyer agent:** selects a service, approves a payment token, and creates an escrow job.
- **Seller agent:** monitors assigned jobs and submits a deliverable hash.
- **NexusPayEscrow:** holds ERC-20 funds and enforces job state transitions.
- **ERC-20 payment asset:** test token during MVP; a supported stablecoin may be considered after review.
- **Off-chain storage/API:** stores task details and deliverables. Only hashes and payment state are on-chain.
- **Arbitrator:** resolves disputes in this prototype; this is a centralized trust assumption.

## State machine
- `None -> Funded -> Submitted -> Released`
- `Funded -> Refunded` if seller misses the work deadline.
- `Submitted -> Disputed -> Resolved` if either party disputes during the review period.
- `Submitted -> Released` if buyer approves or review period expires without dispute.

## Limitations
1. The ERC-20 token is assumed to behave according to its interface; fee-on-transfer behavior is rejected by exact balance checking.
2. The arbitrator is trusted and immutable in this MVP.
3. The chain guarantees execution, not the quality of off-chain work.
4. A task hash proves integrity relative to a value; it does not prove task completion quality.
5. This contract is unaudited and must not hold production funds.

## Privacy
Do not put prompts, personal data, API keys, proprietary code, or private deliverables on-chain. Publish only hashes and non-sensitive identifiers.

## Mainnet readiness gates
- Independent smart-contract audit and remediation.
- Transparent dispute policy and arbitrator governance.
- Supported-token allowlist or token risk policy.
- Monitoring, incident response, and operational key management.
- Legal review for payment, escrow, consumer, sanctions, and data-protection obligations.
- Agent authentication, rate limits, spend caps, and user-controlled permissions.
