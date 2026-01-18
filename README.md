# SplitPay | Base

A simple split payment mini-app on Base. Users can pay their share of a bill using IDRX (or any ERC-20) with a one-tap intent-based transaction.

## Prerequisites

- **Foundry**: For smart contract development.
- **Node.js**: For frontend.
- **Base Sepolia Wallet**: With ETH for gas.

## 1. Smart Contract Setup

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

## 2. Frontend Setup

Navigate to `frontend/`:

```bash
cd ../frontend
npm install
```

1. Create `.env.local`:

```bash
cp .env.local.example .env.local
```

Add your `NEXT_PUBLIC_ONCHAINKIT_API_KEY` (Get one from [Coinbase Developer Platform](https://portal.cdp.coinbase.com/)).

2. Update Contract Addresses:
   Open `src/app/page.tsx` and replace `SPLITPAY_ADDRESS` and `IDRX_ADDRESS` with your deployed addresses.

3. Run the App:

```bash
npm run dev
```

## 3. How to Demo

1. Open `http://localhost:3000`.
2. Connect your Smart Wallet (creates a new one or uses Passkey).
3. Mint some Mock IDRX to your wallet (if using Mock).
   - You can use Cast or Etherscan to call `mint` or just transfer if you deployed it.
   - _Note: MockIDRX mints 1B to deployer. Send some to your test wallet._
4. Enter Total Bill (e.g. 100) and Participants (e.g. 2).
5. "My Share" is calculated (50).
6. Click **Pay My Share**.
7. Confirm the transaction (Approval + Pay batched).
8. Success!

## Architecture

- **Smart Contract (`SplitPay.sol`)**: Stores split sessions via mapping. Supports lazy creation on first payment. Auto-forwards funds when total reached.
- **Frontend**: Next.js + Tailwind + OnchainKit. Uses `Transaction` component for batched ERC20 Approval + Payment.
