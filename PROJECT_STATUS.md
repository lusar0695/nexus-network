# NEXUS Project Status

**Founder model:** solo founder (as provided by founder)  
**Funding path:** grants (as selected by founder)  
**Initial chain:** BNB Smart Chain Testnet  
**Current stage:** initial smart-contract prototype committed; automated build and unit tests passed in GitHub Actions.

## Published
- ERC-20 escrow contract source.
- Test-only mock ERC-20 token.
- Foundry unit-test source.
- Architecture and trust assumptions.
- Draft 16-week grant plan and budget.
- GitHub Actions workflow for Solidity build and tests.
- Deployment script and environment example.
- Security and contribution guidance.
- Mainnet readiness checklist: GitHub Issue #1.

## Verified
- GitHub Actions run #8 completed successfully.
- Foundry dependency installation succeeded.
- `forge build` succeeded.
- `forge test -vvv` succeeded.
- CI run: https://github.com/lusar0695/nexus-network/actions/runs/41296656301

This verifies the current source against the included automated build and unit tests only. It is not a security audit or proof of production readiness.

## Not yet completed
- Independent security audit.
- Testnet deployment and verified contract address.
- Working AI agent clients and SDK.
- Expanded fuzz, invariant, and integration tests.
- Grant submission or award.

## Founder inputs still required
- Public founder name for external applications.
- Project contact email.
- Confirmation of grant eligibility and legal applicant/payment arrangements.

## Safety
No real funds or mainnet deployment. The prototype remains unaudited. Do not publish secrets, private keys, or wallet recovery phrases.
