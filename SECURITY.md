# Security Policy

NEXUS is an experimental, unaudited prototype. Do not use it with real funds.

## Reporting
Do not publish exploit details in a public issue. Contact maintainers through
the official contact method once one is published. Never send private keys,
seed phrases, or sensitive wallet information to anyone.

## Current critical trust assumption
The escrow contract has an immutable arbitrator address. That arbitrator can
allocate disputed funds between buyer and seller. This is a centralized trust
assumption and must be redesigned or governed transparently before production.
