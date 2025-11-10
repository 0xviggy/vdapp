# Smart Contract Development - Study Notes

This document contains conceptual explanations and learning material for blockchain/Solidity fundamentals encountered during DEX development. Use this for interview preparation and deeper understanding of core concepts.

---

## Table of Contents
1. [Event Encoding & Indexing](#event-encoding--indexing)
2. [Testing Framework Quirks](#testing-framework-quirks)
3. [Foundry vs Hardhat](#foundry-vs-hardhat)
4. [OpenZeppelin Design Patterns](#openzeppelin-design-patterns)
5. [Gas Optimization Concepts](#gas-optimization-concepts)
6. [Security Best Practices](#security-best-practices)

---

## Event Encoding & Indexing

### What Are Events?

Events in Solidity are logs stored in the blockchain's transaction receipts. They provide a way to:
- Record contract activity for off-chain consumption
- Enable efficient filtering/searching of blockchain data
- Cheaper than storage (events cost ~375-1500 gas vs storage at 20,000+ gas)

### Event Anatomy: Topics vs Data

When you emit an event, it gets stored with two components:

1. **Topics** (array of up to 4 indexed values) - used for **filtering/searching**
2. **Data** (single blob of ABI-encoded bytes) - contains non-indexed parameters

```
Event Log Structure:
├── Topics[0]: Event signature hash (always present)
├── Topics[1-3]: Indexed parameters (up to 3)
└── Data: ABI-encoded non-indexed parameters
```

### Indexed vs Non-Indexed Parameters

```solidity
event PairCreated(
    address indexed token0,    // INDEXED - becomes a topic
    address indexed token1,    // INDEXED - becomes a topic
    address pair,              // NOT indexed - goes in data
    uint256 pairCount          // NOT indexed - goes in data
);
```

#### Indexed Parameters → Topics

**Purpose:** Make the parameter **searchable/filterable**

**Characteristics:**
- More expensive gas-wise (~375 gas per indexed parameter)
- Maximum 3 indexed parameters per event (+ 1 reserved for event signature)
- Each indexed param becomes a separate topic in the log
- Enables efficient filtering in off-chain queries

**When to Index:**
- Fields you want to filter by (e.g., "show me all transfers FROM this address")
- Primary keys or identifiers
- Common query parameters

**Example Use Case:**
```solidity
event Transfer(address indexed from, address indexed to, uint256 amount);

// Can efficiently query:
// - All transfers from Alice
// - All transfers to Bob  
// - All transfers between Alice and Bob
// - Amount is not indexed (usually don't search by specific amounts)
```

#### Non-Indexed Parameters → Data

**Purpose:** Store additional information efficiently

**Characteristics:**
- Cheaper gas-wise
- All non-indexed params are ABI-encoded together into a single data blob
- Cannot filter by these values efficiently (must download and decode)
- Can be any size (within gas limits)

**When NOT to Index:**
- Large data (strings, bytes, arrays) - expensive when indexed
- Values you record but don't filter by
- Derived/computed values

### Real Event Example with Encoding

```solidity
event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256 pairCount
);

// When emitting:
emit PairCreated(0xAAA, 0xBBB, 0xCCC, 1);

// Results in this log entry:
Topics: [
  0x0d3648bd0f6ba80134a33ba9275ac585d9d315f0ad8355cddefde31afa28d0e9,  // keccak256("PairCreated(address,address,address,uint256)")
  0x000000000000000000000000AAA,  // token0 (padded to 32 bytes)
  0x000000000000000000000000BBB,  // token1 (padded to 32 bytes)
]
Data: 0x000000000000000000000000CCC0000000000000000000000000000000000001
      // ABI encoding of (pair=0xCCC, pairCount=1)
```

### Why Indexing Matters: Filtering Example

**With Indexed Parameters (Efficient):**
```javascript
// Find all pairs created with USDC as token0
const filter = contract.filters.PairCreated(USDC_ADDRESS, null, null, null);
const events = await contract.queryFilter(filter);  // Fast! Uses indexed topics

// Find all pairs with USDC as token1
const filter2 = contract.filters.PairCreated(null, USDC_ADDRESS, null, null);

// Find specific pair USDC-WETH
const filter3 = contract.filters.PairCreated(USDC_ADDRESS, WETH_ADDRESS, null, null);
```

**Without Indexed Parameters (Inefficient):**
```javascript
// Must fetch ALL events and filter manually
const allEvents = await contract.queryFilter(contract.filters.PairCreated());
const filtered = allEvents.filter(e => 
  e.args.token0 === USDC_ADDRESS || e.args.token1 === USDC_ADDRESS
);
// Slow! Downloads and decodes every single event
```

### Gas Cost Tradeoff

```solidity
// Cheapest: No indexed params (~800 gas)
event Data(uint256 a, uint256 b, uint256 c);

// Most expensive: All indexed (~1,900 gas)
event Data(uint256 indexed a, uint256 indexed b, uint256 indexed c);

// Balanced: Index searchable fields (~1,100 gas)
event Data(uint256 indexed a, uint256 b, uint256 c);
```

**Rule of Thumb:** Only index what you'll filter by. Each indexed parameter adds ~375 gas to emit cost.

### Common Indexing Patterns

**ERC20 Transfer:**
```solidity
event Transfer(address indexed from, address indexed to, uint256 amount);
// Index sender/receiver for wallet tracking, not amount
```

**Uniswap Swap:**
```solidity
event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
);
// Index actor addresses, not amounts (too many combinations)
```

**Ownership Transfer:**
```solidity
event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
);
// Index both for tracking ownership history
```

### Interview Questions

**Q: "Why use events instead of storage?"**
- **Cost:** Events ~100x cheaper than storage (375 gas vs 20,000+ gas)
- **Purpose:** Different use cases - storage for contract state, events for historical logs
- **Accessibility:** Events can be read by off-chain services without blockchain calls

**Q: "When should you index a parameter?"**
- When you need to filter by it in queries
- When it's a primary identifier (addresses, IDs)
- When gas cost is acceptable (~375 gas per indexed param)

**Q: "What's the limit on indexed parameters?"**
- Maximum 3 indexed parameters per event
- Total 4 topics: 1 for event signature + 3 for indexed params

**Q: "Can you index arrays or strings?"**
- Technically yes, but they're hashed (keccak256)
- You get the hash in topics, not the actual value
- Usually not useful - can't filter by content, only exact hash match

---

## Testing Framework Quirks

### vm.expectEmit() Deep Dive

The `vm.expectEmit()` cheatcode in Foundry has counter-intuitive behavior that trips up even experienced developers.

#### Function Signature
```solidity
vm.expectEmit(
    bool checkTopic1,
    bool checkTopic2,
    bool checkTopic3,
    bool checkData
);
```

#### Parameter Mapping

```solidity
event PairCreated(
    address indexed token0,    // → Topic 1
    address indexed token1,    // → Topic 2
    address pair,              // → Data (not a topic!)
    uint256 pairCount          // → Data (not a topic!)
);

vm.expectEmit(true, true, false, true);
//            ^     ^     ^      ^
//            |     |     |      |
//          topic1 topic2 topic3 all non-indexed params together
```

**Key Insight:** The 3rd parameter only matters if the event has 3 indexed parameters. In our case, `pair` is NOT indexed, so it doesn't become topic 3 - it goes into the data blob.

#### Common Mistake

```solidity
// ❌ WRONG: Trying to skip checking 'pair' by using false for topic3
vm.expectEmit(true, true, false, false);
emit PairCreated(token0, token1, address(0), 0);  // Dummy values

// This doesn't work because pair is NOT topic3, it's in data!
```

#### Correct Approaches

**Option 1: Check Everything**
```solidity
// Pre-compute expected values
address expectedPair = factory.pairFor(tokenA, tokenB);

vm.expectEmit(true, true, false, true);  // Check topics 1,2 and data
emit PairCreated(token0, token1, expectedPair, 1);  // Must match exactly
```

**Option 2: Don't Check Data**
```solidity
vm.expectEmit(true, true, false, false);  // Check only indexed params
emit PairCreated(token0, token1, address(0), 0);  // Data values don't matter
```

**Option 3: Use vm.recordLogs() for Complex Cases**
```solidity
vm.recordLogs();
factory.createPair(tokenA, tokenB);

Vm.Log[] memory logs = vm.getRecordedLogs();
assertEq(logs.length, 1, "Should emit one event");
// Can decode and check specific fields manually
```

#### Why the 4th Parameter is All-or-Nothing

The `checkData` parameter controls checking of the **entire data blob**. You cannot selectively check individual non-indexed parameters.

```solidity
// If checkData = true, ALL non-indexed params must match:
event PairCreated(..., address pair, uint256 pairCount);
//                     ^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^
//                     Both must match if checkData=true

// No way to check only 'pair' and not 'pairCount'
```

This is because non-indexed parameters are ABI-encoded together into a single data field at the EVM level.

#### Debugging Failed Event Tests

**Error Message Pattern:**
```
[FAIL: PairCreated param mismatch at pair: expected=0x0000..., got=0xa07bf83c...]
```

This indicates:
1. The event WAS emitted (good!)
2. The signature matches (good!)
3. Indexed topics match (if no topic error)
4. But data doesn't match your expected values

**Solution Steps:**
1. Verify event signature matches exactly
2. Pre-compute expected values (don't use dummy values)
3. Ensure parameter order matches
4. Consider setting `checkData=false` if values are complex/non-deterministic

### Interview Takeaway

The vm.expectEmit() API demonstrates an important principle: **test what matters**. Sometimes checking that an event was emitted is enough; other times you need exact parameter matching. Understanding the tradeoffs and the underlying EVM event encoding makes you a better test writer.

---

## Foundry vs Hardhat

### High-Level Comparison

| Feature | Foundry | Hardhat |
|---------|---------|---------|
| **Language** | Rust (compiled) | JavaScript/TypeScript |
| **Test Language** | Solidity | JavaScript/TypeScript |
| **Speed** | Very Fast (5-10x faster) | Moderate |
| **Gas Reports** | Built-in | Requires plugin |
| **Fuzz Testing** | Native | External tools |
| **Ecosystem** | Growing rapidly | Mature, extensive plugins |
| **Learning Curve** | Steeper (Solidity tests, new concepts) | Gentler (familiar JS patterns) |
| **Dependencies** | Git submodules | npm packages |

### When to Use Foundry

**Best For:**
- Speed-critical projects (fast iteration during development)
- Solidity-first teams (prefer writing tests in Solidity)
- Gas optimization work (detailed gas reports, benchmarking)
- Advanced testing (fuzz testing, invariant testing, symbolic execution)
- Projects with minimal JavaScript integration

**Advantages:**
- **Speed:** Tests run 5-10x faster due to compiled Rust + parallel execution
- **Gas Precision:** Exact gas measurements, not estimates
- **Fuzz Testing:** Built-in property-based testing
- **Cheatcodes:** Powerful testing utilities (time travel, impersonation, etc.)
- **No Context Switching:** Write contracts and tests in same language

**Disadvantages:**
- Smaller plugin ecosystem
- Less documentation/tutorials compared to Hardhat
- Steeper learning curve for JavaScript developers
- Git submodule dependency management can be tricky

### When to Use Hardhat

**Best For:**
- JavaScript/TypeScript-heavy projects
- Teams familiar with Node.js ecosystem
- Complex deployment scripts requiring JS logic
- Projects needing extensive plugins (verification, gas reporters, etc.)
- Integration with frontend frameworks (easier with JS)

**Advantages:**
- **Mature Ecosystem:** Extensive plugins for every need
- **Familiar:** JavaScript developers feel at home
- **Documentation:** More tutorials, examples, community support
- **npm Packages:** Standard dependency management
- **Flexibility:** Easy to script complex deployment logic

**Disadvantages:**
- Slower test execution (Node.js overhead + sequential tests)
- Less precise gas reporting
- Fuzz testing requires external tools (Echidna, etc.)
- Context switching between Solidity and JavaScript

### Hybrid Approach

Many projects use both:
- **Foundry** for unit tests, gas optimization, fuzz testing
- **Hardhat** for deployment scripts, integration tests, frontend integration

```bash
# Project structure supporting both
contracts/
├── foundry.toml
├── hardhat.config.js
├── src/              # Contracts
├── test/
│   ├── foundry/      # Foundry tests (.t.sol)
│   └── hardhat/      # Hardhat tests (.test.js)
└── script/
    ├── foundry/      # Forge scripts
    └── hardhat/      # Hardhat tasks
```

### Interview Insight

The choice between Foundry and Hardhat often comes down to:
1. **Team preferences** - Solidity vs JavaScript comfort
2. **Project requirements** - Speed vs ecosystem
3. **Testing needs** - Fuzz testing vs integration testing

Modern developers should be comfortable with both. Foundry is growing rapidly and becoming the preferred choice for DeFi protocols focused on security and gas optimization.

---

## OpenZeppelin Design Patterns

### Why Use OpenZeppelin?

**Interview Answer:**
1. **Security:** Battle-tested, audited implementations used by billions in TVL
2. **Standards Compliance:** ERC20, ERC721, etc. guaranteed to match specs
3. **Time Savings:** Don't reinvent the wheel on critical security code
4. **Community Trust:** Industry standard, audited by multiple firms
5. **Active Maintenance:** Regular updates, security patches

### Key Contracts We Use

#### ReentrancyGuard

**Purpose:** Prevents reentrancy attacks

**How It Works:**
```solidity
contract DEXPair is ReentrancyGuard {
    function swap(...) external nonReentrant {
        // Protected function
    }
}

// Under the hood:
uint256 private _status = 1;  // NOT_ENTERED

modifier nonReentrant() {
    require(_status != 2, "ReentrancyGuard: reentrant call");
    _status = 2;  // ENTERED
    _;
    _status = 1;  // Reset
}
```

**Gas Cost:** ~2,400 gas per protected function (worth it for security)

**Interview Question:** "When do you need reentrancy protection?"
- Functions that:
  1. Make external calls (to untrusted contracts)
  2. Update state AFTER the external call
  3. Could be exploited if called again before completion

**Famous Reentrancy Attack:** The DAO hack (2016) - $60M stolen
```solidity
// Vulnerable code:
function withdraw() public {
    uint amount = balances[msg.sender];
    msg.sender.call{value: amount}("");  // External call BEFORE state update
    balances[msg.sender] = 0;  // Too late! Attacker already reentered
}
```

#### ERC20 Implementation

**Why Not Write Our Own:**
- ERC20 spec has subtle edge cases
- OpenZeppelin handles: overflow protection, allowance edge cases, total supply tracking
- Audited by multiple firms over years

**Inheritance Pattern:**
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DEXPair is ERC20("LP Token", "LP") {
    // Inherits: balanceOf, transfer, approve, transferFrom, etc.
    // Just add custom logic: mint, burn, swap
}
```

### Security Best Practices We Follow

1. **Checks-Effects-Interactions Pattern**
   ```solidity
   function swap(...) external {
       // 1. Checks
       require(amount > 0, "Invalid amount");
       
       // 2. Effects (update state)
       reserve0 = newReserve0;
       reserve1 = newReserve1;
       
       // 3. Interactions (external calls last)
       token.transfer(to, amount);
   }
   ```

2. **Pull Over Push** for payments
   ```solidity
   // ❌ Push: Dangerous
   for (user in users) {
       user.transfer(amount);  // If one fails, all fail
   }
   
   // ✅ Pull: Safe
   mapping(address => uint) public withdrawable;
   function withdraw() external {
       uint amount = withdrawable[msg.sender];
       withdrawable[msg.sender] = 0;
       msg.sender.transfer(amount);
   }
   ```

3. **Explicit Visibility** for all functions
   ```solidity
   function swap(...) external { }  // Explicit 'external'
   function _update(...) private { }  // Explicit 'private'
   ```

---

## Gas Optimization Concepts

### Why Gas Matters

**Interview Context:**
- Each operation costs gas (paid in ETH)
- High gas = poor UX, limits adoption
- Popular protocols optimize heavily (Uniswap V3 spent months on gas optimization)

### Common Optimization Techniques

#### 1. Storage Packing

**Concept:** Solidity packs variables into 32-byte slots

```solidity
// ❌ Inefficient: 3 storage slots (96 bytes)
uint256 a;      // Slot 0
uint128 b;      // Slot 1
uint128 c;      // Slot 2

// ✅ Efficient: 2 storage slots (64 bytes)
uint256 a;      // Slot 0
uint128 b;      // Slot 1
uint128 c;      // Slot 1 (packed with b)

// Storage access: 2,100 gas per slot (first time), 100 gas (warm)
```

**DEXPair Example:**
```solidity
uint112 private reserve0;   // Packed
uint112 private reserve1;   // Packed (same slot)
uint32 private blockTimestamp;  // Packed (same slot)
// Total: 1 slot instead of 3 (saves ~4,200 gas per update)
```

#### 2. Immutable and Constant

```solidity
address public constant WETH = 0x...;  // Embedded in bytecode, no storage
address public immutable factory;      // Set once in constructor, no storage slot

// vs
address public weth;  // Storage slot, 2,100 gas per read (first time)
```

#### 3. Unchecked Arithmetic (Solidity 0.8+)

```solidity
// Overflow checks add ~20-40 gas per operation
for (uint i = 0; i < 100; i++) {  // Checked
    // ...
}

// When overflow is impossible:
for (uint i = 0; i < 100;) {
    // ...
    unchecked { ++i; }  // Saves ~35 gas per iteration
}
```

**⚠️ Use With Caution:** Only when you're 100% sure overflow is impossible

#### 4. Short-Circuiting

```solidity
// ❌ Always reads storage twice
if (reserve0 != 0 && reserve1 != 0) { }

// ✅ Short-circuits: if reserve0 == 0, doesn't read reserve1
if (reserve0 != 0 && reserve1 != 0) { }  // Same, but save gas if first false

// ✅ Order matters: put cheaper checks first
if (amount > 0 && token.balanceOf(user) >= amount) { }  // amount check is free
```

#### 5. Memory vs Storage

```solidity
// ❌ Expensive: reads storage multiple times
function bad() public view returns (uint) {
    return reserve0 + reserve0 + reserve0;  // 3 SLOADs
}

// ✅ Cheap: cache in memory
function good() public view returns (uint) {
    uint r = reserve0;  // 1 SLOAD
    return r + r + r;   // memory ops are cheap
}
```

### Gas Benchmarking

**Foundry Built-in:**
```bash
forge test --gas-report
```

**Output:**
```
| Function | Avg Gas | Max Gas |
|----------|---------|---------|
| swap     | 87,234  | 92,111  |
| mint     | 112,331 | 124,882 |
```

**Interview Tip:** Know approximate gas costs:
- Storage write: 20,000 gas (new), 5,000 gas (update), 15,000 refund (delete)
- Memory: 3 gas per word
- SLOAD: 2,100 gas (cold), 100 gas (warm)
- External call: 2,600 gas base + called function's gas

---

## Security Best Practices

### Critical Vulnerabilities to Avoid

#### 1. Reentrancy
**Prevention:** Use ReentrancyGuard, Checks-Effects-Interactions pattern

#### 2. Integer Overflow/Underflow
**Prevention:** Use Solidity 0.8+ (automatic checks), or SafeMath library

#### 3. Unchecked External Calls
```solidity
// ❌ Dangerous: ignores return value
token.transfer(to, amount);

// ✅ Safe: check return value
require(token.transfer(to, amount), "Transfer failed");

// ✅ Safer: use SafeERC20 library (handles non-standard tokens)
token.safeTransfer(to, amount);
```

#### 4. Front-Running
**Mitigation:** Slippage protection, deadlines
```solidity
function swap(uint amountOutMin, uint deadline) external {
    require(block.timestamp <= deadline, "Expired");
    uint amountOut = calculateSwap(...);
    require(amountOut >= amountOutMin, "Slippage exceeded");
}
```

#### 5. Access Control
```solidity
// ❌ Anyone can set fees
function setFeeTo(address _feeTo) external {
    feeTo = _feeTo;
}

// ✅ Only authorized
function setFeeTo(address _feeTo) external {
    require(msg.sender == feeToSetter, "Unauthorized");
    feeTo = _feeTo;
}
```

### Audit Checklist

Before production:
- [ ] Reentrancy protection on all external calls
- [ ] Access control on privileged functions
- [ ] Input validation (zero addresses, amounts, etc.)
- [ ] Slippage/deadline protection for user-facing functions
- [ ] Gas optimization (but not at expense of clarity)
- [ ] Comprehensive test coverage (>90%)
- [ ] Fuzz testing for edge cases
- [ ] Professional security audit (for high-value contracts)

### Tools for Security

1. **Slither** - Static analyzer
   ```bash
   pip install slither-analyzer
   slither src/
   ```

2. **Mythril** - Symbolic execution
   ```bash
   pip install mythril
   myth analyze src/DEXPair.sol
   ```

3. **Echidna** - Fuzz testing
4. **Certora** - Formal verification

---

## Additional Resources

### Must-Read for Interviews

- [Consensys Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- [Solidity by Example](https://solidity-by-example.org/)
- [Uniswap V2 Whitepaper](https://uniswap.org/whitepaper.pdf)
- [Foundry Book](https://book.getfoundry.sh/)

### Learn from Past Exploits

- [Rekt News](https://rekt.news/) - DeFi hack postmortems
- [DeFi Security Summit](https://www.defisecuritysummit.org/)

### Practice

- [Ethernaut](https://ethernaut.openzeppelin.com/) - Security challenges
- [Damn Vulnerable DeFi](https://www.damnvulnerabledefi.xyz/) - DeFi hacking challenges

---

**Document Version:** 1.0  
**Last Updated:** 2024-11-11  
**Purpose:** Interview preparation and conceptual learning

**Changelog:**
- v1.0: Initial version with event encoding, testing quirks, Foundry vs Hardhat, OpenZeppelin patterns, gas optimization, security
