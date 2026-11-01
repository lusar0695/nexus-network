# NEXUS MVP — AI Agent Payments on BNB Smart Chain

**Status:** experimental prototype; not audited; not production-ready.

NEXUS MVP starts with an ERC-20 escrow workflow so two independent agents (or a human and an agent) can exchange a paid service with an on-chain payment record.

## What is included

- `contracts/NexusPayEscrow.sol` — ERC-20 escrow for paid tasks.
- `contracts/MockUSDC.sol` — test-only six-decimal mock token. It is not a real stablecoin.
- `docs/architecture.md` — architecture and trust assumptions.
- `docs/grant-plan.md` — MVP deliverables and grant budget draft.

## MVP workflow

1. Buyer approves an ERC-20 token for the escrow contract.
2. Buyer creates a job, deposits the agreed amount, and provides a hash of the task specification.
3. Seller submits a hash of the deliverable before the work deadline.
4. Buyer approves payment, or payment becomes claimable by the seller after the review period.
5. Buyer or seller may raise a dispute during the review period. The immutable arbitrator resolves it by allocating funds between buyer and seller.
6. If the seller never submits before the work deadline, the buyer can refund the deposit.

The contract does not store task text, prompts, files, or deliverables. Store them off-chain and put content hashes on-chain.

## Important trust and safety notes

- The arbitrator is immutable and trusted. A compromised, unavailable, or unfair arbitrator can harm users. For the testnet demo, use a dedicated test wallet; for production, design transparent arbitration, multisig governance, or a decentralized dispute mechanism.
- The contract accepts ERC-20 tokens, not native BNB. Use a test token on testnet.
- Never use `MockUSDC` as a real stablecoin or imply it is backed by USD.
- This code has not been audited. Do not deploy with real funds before independent review, tests, and a threat model.
- Token issuance (NXS) is intentionally separate from the payment MVP. A token is not required to demonstrate agent payments.

## Build and test with Foundry

Install Foundry, then run:

```bash
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install foundry-rs/forge-std --no-commit
forge build
forge test -vvv
```

The project uses Solidity 0.8.24 and OpenZeppelin Contracts 5.x.

## BNB Smart Chain Testnet

- Network: BNB Smart Chain Testnet
- Chain ID: `97`
- RPC: `https://data-seed-prebsc-1-s1.bnbchain.org:8545`
- Explorer: `https://testnet.bscscan.com`

Get test BNB only from an official BNB Chain faucet. Test BNB has no monetary value.

## Deployment safety

A Foundry deployment script is provided in `script/DeployNexusPay.s.sol`. It reads `PRIVATE_KEY` and `ARBITRATOR_ADDRESS` from environment variables. Copy `.env.example` to a local `.env` file and fill values only in your local environment. Never commit `.env`.

**Do not deploy this prototype to mainnet or use real funds.** The code has not been compiled, tested, or audited in this environment. Mainnet readiness requires independent security review, remediation, arbitration governance, token risk controls, monitoring, key management, and legal review.

## Repository

Public source repository: https://github.com/lusar0695/nexus-network

## Next engineering tasks

- Run Foundry build and unit tests in CI; fix all failures.
- Add fuzz, invariant, and integration tests.
- Add a TypeScript SDK and sample buyer/seller agent.
- Add signed task metadata and replay protection for off-chain agent messages.
- Add an indexer and developer dashboard.
- Complete an independent security review before any mainnet use.

See `docs/testnet-deployment.md` for the testnet-only deployment guide. See `PROJECT_STATUS.md` for current status and `SECURITY.md` for reporting guidance.
