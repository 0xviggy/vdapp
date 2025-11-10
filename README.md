# VDAPP - Production-Grade DEX on Arbitrum

A full-stack decentralized exchange (DEX) implementation on Arbitrum, featuring production-ready smart contracts, comprehensive testing, and a modern web3 frontend. Built for production deployment and designed to showcase professional blockchain development practices.

## 🎯 Project Overview

This project implements a complete DEX with:
- **Automated Market Maker (AMM)** with constant product formula
- **Liquidity Pools** for token pair trading
- **Router Contract** for optimal swap routing
- **Upgradeable Architecture** using UUPS proxy pattern
- **Modern Frontend** with Next.js, TypeScript, and Web3 integration
- **Comprehensive Testing** (>95% coverage target)
- **Production Security** features and gas optimizations

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Frontend (Next.js + TypeScript)              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  - Wallet Connection (MetaMask, WalletConnect)             │ │
│  │  - Swap Interface with real-time pricing                   │ │
│  │  - Liquidity Management UI                                 │ │
│  │  - Transaction Status & History                            │ │
│  │  - Auto-generated TypeScript types from ABIs               │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │ ethers.js
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Smart Contracts (Solidity + Foundry)            │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────────┐  │
│  │  Router        │  │  Liquidity     │  │  Swap Engine     │  │
│  │  (Entry Point) │─▶│  Pool Manager  │─▶│  (AMM Logic)     │  │
│  └────────────────┘  └────────────────┘  └──────────────────┘  │
│           │                                                      │
│           ▼                                                      │
│  ┌────────────────┐                                             │
│  │  UUPS Proxy    │  (Upgradeability)                           │
│  └────────────────┘                                             │
│                                                                  │
│  Security: Access Control, Reentrancy Guards, Pause Mechanism   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                         Arbitrum Network
```

## 📁 Project Structure

```
vdapp/
├── dex-contracts/          # Smart contracts (Foundry)
│   ├── src/               # Contract source files
│   ├── test/              # Unit, fuzz, and invariant tests
│   ├── script/            # Deployment and interaction scripts
│   └── foundry.toml       # Foundry configuration
│
├── dex-frontend/          # Frontend application (Next.js)
│   ├── src/
│   │   ├── app/          # Next.js app router pages
│   │   ├── components/   # React components
│   │   └── __tests__/    # Frontend tests (Vitest)
│   ├── package.json
│   └── vitest.config.ts
│
├── .github/
│   └── workflows/        # CI/CD pipelines
│       └── ci.yml        # Automated testing workflow
│
├── docs/                 # Additional documentation
├── setup_commands.md     # Setup commands with explanations
└── README.md            # This file
```

## 🚀 Quick Start

### Prerequisites

- Node.js >= 20.9.0 (use `nvm` for version management)
- Foundry (for smart contract development)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/0xviggy/vdapp.git
   cd vdapp
   ```

2. **Install Foundry (if not already installed)**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

3. **Setup Smart Contracts**
   ```bash
   cd dex-contracts
   forge install
   forge build
   forge test
   ```

4. **Setup Frontend**
   ```bash
   cd ../dex-frontend
   npm install
   npm run dev
   ```

5. **Open the application**
   - Frontend: http://localhost:3000
   - You can interact with the DEX once contracts are deployed

## 🧪 Testing

### Smart Contract Tests
```bash
cd dex-contracts

# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testSwap

# Generate coverage report
forge coverage
```

### Frontend Tests
```bash
cd dex-frontend

# Run unit tests
npm test

# Run with coverage
npm test -- --coverage
```

### CI/CD
All tests run automatically on every push and pull request via GitHub Actions.

## 📦 Deployment

### Local Development (Anvil)
```bash
# Terminal 1: Start local node
anvil

# Terminal 2: Deploy contracts
cd dex-contracts
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Arbitrum Testnet
```bash
forge script script/Deploy.s.sol \
  --rpc-url $ARBITRUM_GOERLI_RPC \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### Frontend Deployment
The frontend can be deployed to Vercel:
```bash
cd dex-frontend
vercel deploy
```

## 🔒 Security Features

- **Access Control**: Role-based permissions using OpenZeppelin
- **Reentrancy Protection**: Guards on all state-changing functions
- **Pause Mechanism**: Emergency stop functionality
- **Input Validation**: Comprehensive checks on all user inputs
- **Slippage Protection**: User-defined acceptable slippage limits
- **Safe Math**: Solidity 0.8+ overflow protection
- **Upgradeable**: UUPS proxy pattern for safe contract upgrades

## 🛠️ Tech Stack

### Smart Contracts
- **Solidity** ^0.8.30
- **Foundry** - Testing and deployment
- **OpenZeppelin** - Security and upgradeability
- **Forge-std** - Testing utilities

### Frontend
- **Next.js 16** - React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **ethers.js** - Blockchain interaction
- **Vitest** - Testing framework
- **React Testing Library** - Component testing

### DevOps
- **GitHub Actions** - CI/CD
- **ESLint** - Code quality
- **Prettier** - Code formatting

## 📚 Development Workflow

1. **Contract Development**
   - Write contracts in `dex-contracts/src/`
   - Add tests in `dex-contracts/test/`
   - Run `forge test` frequently during development
   - Aim for >95% test coverage

2. **Frontend Development**
   - Generate TypeScript types from contract ABIs
   - Build components in `dex-frontend/src/components/`
   - Write tests alongside components
   - Run `npm run dev` for hot reload

3. **Deployment**
   - Test thoroughly on local Anvil node
   - Deploy to testnet (Arbitrum Goerli)
   - Verify contracts on block explorer
   - Deploy frontend to Vercel

## 🎓 Interview & Production Notes

This project demonstrates:
- **Smart Contract Patterns**: Factory, Proxy, Router patterns
- **DeFi Mechanics**: AMM, liquidity pools, constant product formula
- **Security Best Practices**: Multiple layers of protection
- **Testing Excellence**: Unit, fuzz, invariant, integration tests
- **Modern Web3 Stack**: Type-safe contract interactions
- **CI/CD**: Automated testing and deployment
- **Gas Optimization**: Efficient storage and computation
- **Upgradeability**: Safe contract upgrades without data loss

## 📖 Documentation

- [DEX Design Document](dex-contracts/src/DEXDesign.md) - Architecture and design decisions
- [Setup Commands](setup_commands.md) - Detailed setup with explanations
- [Project Structure](dex-contracts/project_structure_details.md) - Codebase organization
- [CI/CD Notes](.github/workflows/ci_notes.md) - Workflow documentation

## 🤝 Contributing

This is a portfolio/learning project, but suggestions and improvements are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## 📄 License

MIT License - feel free to use this project for learning or as a starting point for your own DEX.

## 🔗 Links

- **Repository**: https://github.com/0xviggy/vdapp
- **Author**: [@0xviggy](https://github.com/0xviggy)
- **Network**: Arbitrum

---

Built with ❤️ for production-grade blockchain development
