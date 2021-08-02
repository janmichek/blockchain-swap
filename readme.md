### Blockchain Swap DAPP

DAPP which let you exchange ETH for made up DAPP currency and vice versa.

This repository is inspired by following tutorial:
https://www.youtube.com/watch?v=99pYGpTWcXM

## Dependencies

- Ganache https://www.trufflesuite.com/ganache
- Node JS
- Yarn

## Init project

### Install backend dependencies

```yarn install```

### Deploy contracts to blockchain

Run Ganache with Quickstart Workspace

```yarn deploy```

### Install frontend dependencies

```cd frontend```

```yarn install```

## Run project

```yarn serve```

### Init Metamask account

Login to Metamask

Go to Ganache and copy private key of first account

Open Metamask

Switch to Ganache Network

Click Import account

Paste private key

Connect Account

Open app on http://localhost:8080/

### Test Smart Contracts

```truffle test```