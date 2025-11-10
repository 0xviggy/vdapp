# DEX Smart Contract Design (Production Grade)

## Overview
This DEX implements an Automated Market Maker (AMM) using the constant product formula (x * y = k), similar to Uniswap V2. The design prioritizes security, gas efficiency, and upgradeability while maintaining production-ready code quality.

## Core Components

### 1. **DEXFactory.sol** - Pool Factory & Registry
Creates and tracks liquidity pool pairs.

**Key Functions:**
- `createPair(address tokenA, address tokenB)` - Creates new trading pair
- `getPair(address tokenA, address tokenB)` - Returns pair address
- `allPairs()` - Returns all pair addresses

**Features:**
- Prevents duplicate pairs
- Emits `PairCreated` events for indexing
- Maintains pair registry for router lookup

### 2. **DEXPair.sol** - Liquidity Pool Implementation
Manages individual token pair pools using constant product formula.

**Key Functions:**
- `mint(address to)` - Issues LP tokens for liquidity providers
- `burn(address to)` - Removes liquidity and returns tokens
- `swap(uint amount0Out, uint amount1Out, address to)` - Executes token swaps
- `sync()` - Syncs reserves with actual balances
- `getReserves()` - Returns current pool reserves

**Math & Formulas:**
- Constant Product: `x * y = k`
- Swap formula: `amountOut = (amountIn * 997 * reserveOut) / (reserveIn * 1000 + amountIn * 997)` (0.3% fee)
- LP tokens: `√(amount0 * amount1)` on first mint

**Security:**
- Reentrancy guards on swap, mint, burn
- Minimum liquidity lock (1000 wei) to prevent manipulation
- Price oracle using cumulative prices
- Flash loan protection

### 3. **DEXRouter.sol** - User-Facing Interface
Simplifies interactions with pairs, handles multi-hop swaps.

**Key Functions:**
- `addLiquidity(tokenA, tokenB, amountA, amountB, minA, minB, to, deadline)`
- `removeLiquidity(tokenA, tokenB, liquidity, minA, minB, to, deadline)`
- `swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline)`
- `swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline)`
- `getAmountsOut(amountIn, path[])` - Calculate output amounts for path
- `getAmountsIn(amountOut, path[])` - Calculate input amounts for path

**Features:**
- Multi-hop routing (e.g., A -> B -> C)
- Slippage protection via min/max amounts
- Deadline mechanism to prevent stale transactions
- Automatic pair creation if needed
- Optimized path finding for best rates

### 4. **DEXLibrary.sol** - Shared Utilities
Pure functions for calculations and validations.

**Key Functions:**
- `quote(amountA, reserveA, reserveB)` - Calculate equivalent amounts
- `getAmountOut(amountIn, reserveIn, reserveOut)` - Calc output with fee
- `getAmountIn(amountOut, reserveIn, reserveOut)` - Calc required input
- `sortTokens(tokenA, tokenB)` - Canonical token ordering
- `pairFor(factory, tokenA, tokenB)` - Calculate pair address

### 5. **UUPS Proxy Pattern** - Upgradeability
Allows safe contract upgrades without losing state or funds.

**Implementation:**
- `DEXRouterUpgradeable.sol` - UUPS upgradeable router
- `DEXFactoryUpgradeable.sol` - UUPS upgradeable factory
- Only admin can upgrade via `upgradeTo(address newImplementation)`
- Uses OpenZeppelin's `UUPSUpgradeable` base contract

## Security Features

### Access Control
- **Ownable Pattern:** Factory and Router have owner for admin functions
- **Role-Based Access:** Use OpenZeppelin's `AccessControl` for granular permissions
- **Multi-sig Support:** Critical functions require multiple signatures (production)
- **Timelock:** Delay on sensitive operations (upgrades, parameter changes)

### Attack Prevention
- **Reentrancy Guards:** All state-changing functions protected
- **Flash Loan Protection:** Minimum liquidity lock prevents zero-liquidity attacks
- **Front-running Mitigation:** Deadlines and slippage limits
- **Integer Overflow:** Solidity 0.8+ built-in checks
- **Price Manipulation:** Time-weighted average price (TWAP) oracle
- **Sandwich Attack Protection:** MEV-aware slippage settings

### Emergency Controls
- **Circuit Breaker:** Pause mechanism for emergency stops
- **Granular Pausing:** Can pause specific pairs or all operations
- **Emergency Withdrawal:** Admin can help users recover funds in emergencies
- **Upgrade Safety:** UUPS pattern with storage collision protection

### Input Validation
- Non-zero addresses and amounts
- Valid token pairs
- Sufficient balances and allowances
- Deadline not expired
- Slippage within acceptable range
- Path length validation (max hops)

## Events & Logging

### Core Events
```solidity
// DEXFactory
event PairCreated(address indexed token0, address indexed token1, address pair, uint);

// DEXPair
event Mint(address indexed sender, uint amount0, uint amount1);
event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
event Sync(uint112 reserve0, uint112 reserve1);

// DEXRouter
event LiquidityAdded(address indexed provider, address indexed tokenA, address indexed tokenB, uint amountA, uint amountB);
event LiquidityRemoved(address indexed provider, address indexed tokenA, address indexed tokenB, uint amountA, uint amountB);
```

## Gas Optimizations

1. **Storage Packing:** Pack variables to use fewer storage slots
2. **Calldata vs Memory:** Use calldata for read-only arrays
3. **Unchecked Math:** Use unchecked blocks where overflow is impossible
4. **Short-circuit Logic:** Order conditions to fail fast
5. **Batch Operations:** Support batch swaps/liquidity changes
6. **Minimal Proxy (EIP-1167):** For pair creation
7. **View Functions:** Mark pure/view where possible

## Testing Strategy

### Unit Tests (Foundry)
- Test each function in isolation
- Edge cases: zero amounts, identical tokens, etc.
- Access control: unauthorized calls should revert
- Math precision: rounding, overflow, underflow

### Fuzz Tests
- Random inputs to discover edge cases
- Price impact under extreme conditions
- LP token calculation accuracy
- Slippage protection effectiveness

### Invariant Tests
- Constant product formula holds: k never decreases
- Total LP tokens match pool reserves
- Balance consistency: sum of user balances = pool balance
- No locked funds: can always withdraw proportional share

### Integration Tests
- Multi-hop swaps work correctly
- Add/remove liquidity updates reserves properly
- Price oracle updates on swaps
- Router + Factory + Pair interaction flows

### Coverage Target
- Line Coverage: >95%
- Branch Coverage: >90%
- Function Coverage: 100%

## Implementation Checklist

### Phase 1: Core Contracts
- [ ] DEXFactory.sol
- [ ] DEXPair.sol  
- [ ] DEXLibrary.sol
- [ ] ERC20 token for LP shares (in DEXPair)

### Phase 2: Router & Utilities
- [ ] DEXRouter.sol
- [ ] Multi-hop swap logic
- [ ] Slippage/deadline validation

### Phase 3: Upgradeability
- [ ] Convert to UUPS upgradeable
- [ ] Migration scripts
- [ ] Storage layout validation

### Phase 4: Security & Testing
- [ ] Comprehensive test suite
- [ ] Security audit preparation
- [ ] Gas optimization pass
- [ ] Documentation

### Phase 5: Advanced Features
- [ ] Price oracle (TWAP)
- [ ] Fee collection mechanism
- [ ] Governance token integration (optional)
- [ ] Analytics/subgraph support

## Interview Discussion Points

### Architecture Decisions
- Why AMM vs order book?
- Constant product formula trade-offs
- UUPS vs Transparent Proxy pattern
- Factory pattern benefits

### DeFi Concepts
- Impermanent loss explanation
- Slippage and price impact
- Liquidity provider incentives
- MEV and front-running

### Security Considerations
- Attack vectors and mitigations
- Upgrade safety mechanisms
- Oracle manipulation risks
- Flash loan attack scenarios

### Gas Optimization
- Storage slot packing examples
- Why minimal proxy for pairs
- Batch operation benefits
- View function gas savings

---

This design serves as both implementation guide and interview prep material. Update as development progresses.
