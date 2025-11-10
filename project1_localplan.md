# Project 1: EVM L2 Bridge Interface - Local Plan

## Project Overview
**Duration**: Days 1-4 (40 hours)  
**Stack**: Solidity, Foundry, TypeScript, Next.js, Ethers.js  
**Focus**: Production-ready L2 bridge interaction with rigorous TDD and full-stack typing

## Project Description
Build a production-grade EVM Layer 2 bridge interface that allows users to deposit and withdraw tokens between Ethereum mainnet and a Layer 2 network (Polygon/Optimism). The project demonstrates advanced Solidity patterns, comprehensive testing, and modern full-stack development.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Frontend Layer                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Next.js Application (SSR/SSG)                  │ │
│  │  - TypeScript with auto-generated contract types           │ │
│  │  - Wallet connection (WalletConnect, MetaMask)             │ │
│  │  - Real-time transaction status                            │ │
│  │  - Bridge UI (Deposit/Withdraw)                            │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ ethers.js / web3.js
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Blockchain Layer                            │
│                                                                   │
│  ┌──────────────────────┐         ┌──────────────────────┐      │
│  │   L1 (Ethereum)      │         │   L2 (Polygon/OP)    │      │
│  │                      │         │                      │      │
│  │  ┌───────────────┐  │         │  ┌───────────────┐  │      │
│  │  │ Bridge.sol    │  │◄───────►│  │ Bridge.sol    │  │      │
│  │  │ (UUPS Proxy)  │  │         │  │ (UUPS Proxy)  │  │      │
│  │  └───────────────┘  │         │  └───────────────┘  │      │
│  │         │            │         │         │            │      │
│  │  ┌───────────────┐  │         │  ┌───────────────┐  │      │
│  │  │ Token.sol     │  │         │  │ Token.sol     │  │      │
│  │  │ (ERC20)       │  │         │  │ (Wrapped)     │  │      │
│  │  └───────────────┘  │         │  └───────────────┘  │      │
│  └──────────────────────┘         └──────────────────────┘      │
│            │                                 │                   │
│            └────────── Message Relay ───────┘                   │
│                   (Canonical Bridge)                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Testing & CI/CD Layer                       │
│  - Foundry: Fuzz, Invariant, Integration Tests                  │
│  - GitHub Actions: Auto-deploy, Contract Verification           │
│  - Coverage Reports: >95% target                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
project1-l2-bridge/
├── contracts/
│   ├── src/
│   │   ├── Bridge.sol                    # Main bridge contract (UUPS)
│   │   ├── BridgeProxy.sol               # UUPS proxy
│   │   ├── Token.sol                     # ERC20 token
│   │   ├── interfaces/
│   │   │   ├── IBridge.sol
│   │   │   └── IMessageRelay.sol
│   │   └── libraries/
│   │       ├── SafeTransfer.sol
│   │       └── MessageEncoding.sol
│   ├── test/
│   │   ├── Bridge.t.sol                  # Unit tests
│   │   ├── BridgeFuzz.t.sol              # Fuzz tests
│   │   ├── BridgeInvariant.t.sol         # Invariant tests
│   │   ├── BridgeIntegration.t.sol       # Integration tests
│   │   └── mocks/
│   │       └── MockMessageRelay.sol
│   ├── script/
│   │   ├── Deploy.s.sol                  # Deployment script
│   │   └── Upgrade.s.sol                 # Upgrade script
│   ├── foundry.toml
│   └── package.json
│
├── frontend/
│   ├── src/
│   │   ├── app/
│   │   │   ├── page.tsx                  # Home page
│   │   │   ├── bridge/
│   │   │   │   └── page.tsx              # Bridge interface
│   │   │   └── layout.tsx
│   │   ├── components/
│   │   │   ├── BridgeForm.tsx
│   │   │   ├── TransactionStatus.tsx
│   │   │   ├── WalletConnect.tsx
│   │   │   └── NetworkSwitch.tsx
│   │   ├── hooks/
│   │   │   ├── useBridge.ts
│   │   │   ├── useWallet.ts
│   │   │   └── useTransaction.ts
│   │   ├── lib/
│   │   │   ├── contracts/                # Auto-generated types
│   │   │   │   ├── Bridge.ts
│   │   │   │   └── Token.ts
│   │   │   ├── web3.ts
│   │   │   └── constants.ts
│   │   └── types/
│   │       └── index.ts
│   ├── public/
│   ├── tests/
│   │   ├── unit/
│   │   └── integration/
│   ├── next.config.js
│   ├── tsconfig.json
│   ├── package.json
│   └── tailwind.config.js
│
├── .github/
│   └── workflows/
│       ├── contracts-test.yml
│       ├── frontend-test.yml
│       └── deploy.yml
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── SECURITY.md
│   └── API.md
│
└── README.md
```

---

## Day-by-Day Implementation Plan

### **Day 1: Smart Contract Foundation & Advanced Patterns**

#### Morning (4h): Solidity Development
- [ ] Initialize Foundry project structure
- [ ] Implement base Bridge.sol with UUPS proxy pattern
- [ ] Implement ERC20 Token.sol with burn/mint capabilities
- [ ] Add gas optimization techniques (packed storage, custom errors)
- [ ] Implement access control (Ownable, roles)

#### Afternoon (6h): Security & Testing Setup
- [ ] Write initial unit tests for core functions
- [ ] Implement reentrancy guards
- [ ] Add pause mechanism for emergency stops
- [ ] Set up test coverage reporting
- [ ] Document security considerations

**Deliverables:**
- Functional Bridge.sol and Token.sol contracts
- Basic unit tests passing
- Security patterns implemented

---

### **Day 2: TDD & Advanced Testing**

#### Morning (4h): Fuzz Testing
- [ ] Write fuzz tests for deposit amounts
- [ ] Test edge cases (zero amounts, max uint256)
- [ ] Verify balance invariants
- [ ] Test access control edge cases

#### Afternoon (6h): Invariant Testing
- [ ] Define core invariants:
  - Total supply on L1 + L2 = constant
  - Bridge balance ≥ locked tokens
  - User balance never negative
- [ ] Implement invariant test suite
- [ ] Test upgrade scenarios
- [ ] Achieve >95% coverage

**Deliverables:**
- Comprehensive test suite (unit, fuzz, invariant)
- Coverage report >95%
- All security invariants verified

---

### **Day 3: Full-Stack Integration & Type Generation**

#### Morning (4h): Frontend Setup
- [ ] Initialize Next.js 14 project with App Router
- [ ] Set up TypeScript strict mode
- [ ] Install ethers.js v6 and wagmi/viem
- [ ] Auto-generate TypeScript types from ABIs using TypeChain
- [ ] Configure Tailwind CSS

#### Afternoon (6h): Core UI Components
- [ ] Build WalletConnect component (MetaMask, WalletConnect)
- [ ] Create BridgeForm component (deposit/withdraw)
- [ ] Implement NetworkSwitch component
- [ ] Add real-time transaction status tracking
- [ ] Build responsive UI with loading states

**Deliverables:**
- Next.js app with wallet connection
- Bridge UI functional
- Type-safe contract interactions

---

### **Day 4: CI/CD & Production Deployment**

#### Morning (4h): CI/CD Pipeline
- [ ] Set up GitHub Actions for contract testing
- [ ] Add frontend testing workflow
- [ ] Configure automated contract verification (Etherscan)
- [ ] Set up deployment scripts with Foundry
- [ ] Add environment variable management

#### Afternoon (6h): Deployment & Documentation
- [ ] Deploy contracts to testnet (Sepolia + Mumbai/OP Goerli)
- [ ] Deploy frontend to Vercel
- [ ] Verify contracts on block explorers
- [ ] Write comprehensive README
- [ ] Document API endpoints and architecture
- [ ] Create demo video/screenshots

**Deliverables:**
- Deployed contracts (verified on explorers)
- Live frontend application
- Complete documentation
- CI/CD pipeline operational

---

## Technical Requirements

### Smart Contracts
- **Upgradability**: UUPS proxy pattern
- **Security**: ReentrancyGuard, Pausable, AccessControl
- **Gas Optimization**: Packed storage, custom errors, unchecked math
- **Events**: Comprehensive event emission for indexing

### Testing Standards
- **Coverage**: >95% line and branch coverage
- **Test Types**:
  - Unit tests for all functions
  - Fuzz tests for numerical operations
  - Invariant tests for system properties
  - Integration tests for full flows

### Frontend Requirements
- **Framework**: Next.js 14 with App Router
- **Type Safety**: TypeScript strict mode, auto-generated contract types
- **Wallet Support**: MetaMask, WalletConnect, Coinbase Wallet
- **State Management**: React Context or Zustand
- **Testing**: Vitest for unit tests, Playwright for E2E

### DevOps
- **CI/CD**: GitHub Actions
- **Deployment**: Foundry scripts, Vercel for frontend
- **Monitoring**: Contract verification, transaction tracking

---

## Security Invariants

1. **Supply Conservation**: `L1_locked_tokens + L2_minted_tokens = constant`
2. **Bridge Solvency**: `bridge.balance >= total_locked_tokens`
3. **No Token Creation**: Tokens can only be minted when locked on L1
4. **Withdrawal Safety**: Can only withdraw if tokens are locked
5. **Upgrade Safety**: Implementation can only be upgraded by owner

---

## Success Criteria

### Technical Excellence
- ✅ All tests passing with >95% coverage
- ✅ Zero critical security vulnerabilities
- ✅ Gas-optimized contracts (<100k gas for deposit)
- ✅ Type-safe frontend with no `any` types

### Production Readiness
- ✅ Contracts deployed and verified
- ✅ Frontend live with <3s load time
- ✅ CI/CD pipeline running successfully
- ✅ Comprehensive documentation

### Senior Engineering Competencies
- ✅ TDD demonstrated with invariant testing
- ✅ System design documented with diagrams
- ✅ Robust typing with auto-generated types
- ✅ Production deployment with monitoring

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Bridge exploit | Rigorous testing, security audit checklist, pausable |
| Gas costs too high | Optimize storage, batch operations, use L2 |
| Frontend bugs | Unit tests, E2E tests, TypeScript strict mode |
| Deployment issues | Testnet deployment first, automated scripts |
| Message relay failure | Mock for testing, fallback mechanisms |

---

## Resources & Tools

### Development
- Foundry (forge, cast, anvil)
- TypeChain for type generation
- Hardhat (optional for additional tooling)

### Testing
- Foundry test framework
- Vitest for frontend
- Playwright for E2E

### Deployment
- Alchemy/Infura RPC nodes
- Etherscan API for verification
- Vercel for frontend hosting

### Learning Resources
- OpenZeppelin contracts for patterns
- Foundry Book for testing
- EIP-1967 for proxy patterns
- Official L2 bridge documentation

---

## Notes
- Use AI tooling extensively for boilerplate generation
- Focus on senior engineering principles (TDD, system design, observability)
- Prioritize production readiness over feature completeness
- Document all architectural decisions
