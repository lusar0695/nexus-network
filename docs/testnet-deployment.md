# BNB Smart Chain Testnet Deployment (Test Only)

This guide is for the testnet prototype only. **Do not use a mainnet RPC, mainnet private key, or real funds.**

## Prerequisites
- Foundry installed.
- A fresh wallet used only for testnet.
- Test BNB from an official BNB Chain testnet faucet.
- A separate test wallet address to act as arbitrator (it may be a dedicated wallet for a demo; remember that this address has unilateral dispute-resolution power).

Never share your private key or seed phrase with anyone, including in ChatGPT, GitHub issues, or project files.

## Configure locally

```bash
git clone https://github.com/lusar0695/nexus-network.git
cd nexus-network
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install foundry-rs/forge-std --no-commit
cp .env.example .env
```

Edit `.env` locally with a dedicated testnet private key and arbitrator address. Do not commit `.env`.

Load the variables into your shell:

```bash
set -a
source .env
set +a
```

Confirm `RPC_URL` is the BNB Smart Chain Testnet endpoint in `.env.example`, and confirm the wallet holds **test BNB only**.

## Build and test before broadcast

```bash
forge build
forge test -vvv
```

Do not proceed if either command fails.

## Deploy the testnet contracts

```bash
forge script script/DeployNexusTestnet.s.sol:DeployNexusTestnet --rpc-url "$RPC_URL" --broadcast
```

Save the printed MockUSDC and NexusPayEscrow addresses and transaction hashes in a local note. Share only public contract addresses, never private keys.

## Verify on the explorer
Open https://testnet.bscscan.com and search for each printed contract address. Confirm the deployment transaction succeeded and the verified source/bytecode corresponds to the intended build where explorer verification is available.

## After deployment
- Minting is not open-ended: the included MockUSDC only mints its fixed test supply to its deployer.
- Test a buyer approval and job creation, seller submission, buyer approval/payment, refund timeout, and dispute resolution.
- Do not invite public users to deposit real assets.
- Record test results and addresses in a follow-up issue before considering any next stage.

## Mainnet gate
This testnet guide does not authorize mainnet deployment. Mainnet requires a separate reviewed release, independent audit, dispute-governance redesign, supported-token policy, monitoring, key management, and legal review.
