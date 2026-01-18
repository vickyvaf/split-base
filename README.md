# SplitPay | Base

A simple split payment mini-app on Base. Users can pay their share of a bill using IDRX (or any ERC-20) with a one-tap intent-based transaction.

## Prerequisites

- **Foundry**: For smart contract development.
- **Node.js**: For frontend.
- **Base Sepolia Wallet**: With ETH for gas.

## Smart Contract Setup

Navigate to `contracts/`:

```bash
cd contracts
forge install
```

### Deploy to Base Sepolia

1. Create `.env` in `contracts/` with your `PRIVATE_KEY` and RPC URL (optional if using default).
2. Deploy Mock IDRX (if you don't have a token):

```bash
forge script script/DeployMock.s.sol --rpc-url https://sepolia.base.org --broadcast
```

3. Copy the deployed **MockIDRX Address**.
4. Deploy SplitPay:

```bash
export IDRX_ADDRESS=<PASTE_MOCK_IDRX_ADDRESS>
forge script script/Deploy.s.sol --rpc-url https://sepolia.base.org --broadcast
```

5. Note the **SplitPay Address**.
