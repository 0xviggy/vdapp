# DEX Smart Contracts Setup Commands

This document tracks all setup and development commands for the smart contract component, with explanations for reproducibility and interview preparation.

---

## Table of Contents
1. [Initial Setup](#initial-setup)
2. [Dependencies](#dependencies)
3. [Configuration](#configuration)
4. [Development Workflow](#development-workflow)
5. [Testing](#testing)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

---

## Initial Setup

### Command: `forge init dex-contracts --force`
**Purpose:** Initializes a new Foundry project for smart contract development.

**What This Creates:**
```
dex-contracts/
├── foundry.toml       # Foundry configuration
├── src/               # Smart contracts
├── test/              # Test files
├── script/            # Deployment scripts
└── lib/               # Dependencies (git submodules)
```

**Interview Note:** Foundry uses convention over configuration - `src/` for contracts, `test/` for tests with `.t.sol` suffix, `script/` for deployment scripts.

---

## Dependencies

### Command: `forge install foundry-rs/forge-std`
**Purpose:** Installs forge-std library (testing utilities and base contracts).

**What forge-std Provides:**
- `Test.sol` - Base test contract with assertions
- `console.sol` - Console logging for debugging
- `Vm.sol` - Cheatcodes interface (time manipulation, impersonation, etc.)
- `StdCheats.sol` - Common test utilities

**Why It's Needed:**
- Essential for writing Solidity tests
- Provides testing utilities similar to JavaScript testing frameworks
- Enables advanced testing features (fuzz, invariant tests)

**Interview Insight:** Foundry uses git submodules for dependencies instead of npm, providing:
- Version-locked dependencies
- No supply chain attacks (direct source access)
- Reproducible builds

### Command: `forge install OpenZeppelin/openzeppelin-contracts`
**Purpose:** Installs OpenZeppelin contracts library for battle-tested implementations.

**What We Use:**
- `ERC20.sol` - Standard token implementation for LP tokens
- `IERC20.sol` - Token interface for interactions
- `ReentrancyGuard.sol` - Protection against reentrancy attacks
- `Ownable.sol` - Basic access control (future use)
- `Pausable.sol` - Emergency pause functionality (future use)

**Why OpenZeppelin:**
- Industry standard for secure smart contracts
- Audited by multiple security firms
- Used by 1000+ projects with billions in TVL
- Active maintenance and security updates

**Interview Question:** "Why use OpenZeppelin instead of writing from scratch?"
- **Security:** Battle-tested, audited implementations
- **Time:** Don't reinvent the wheel
- **Standards:** Ensures ERC compliance
- **Trust:** Community-verified code

**Version Installed:** v5.5.0 (as of installation)

---

## Configuration

### File: `foundry.toml`
**Purpose:** Configures Foundry toolchain settings for compilation and testing.

**Current Configuration:**
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.20"           # Solidity compiler version
optimizer = true          # Enable optimizer
optimizer_runs = 200      # Balance deployment vs runtime costs
via_ir = false           # Standard compilation pipeline

remappings = [
    "@openzeppelin/=lib/openzeppelin-contracts/",
    "forge-std/=lib/forge-std/src/"
]
```

**Key Settings Explained:**

#### Solidity Version: `0.8.20`
**Why This Version:**
- Built-in overflow/underflow checks (no SafeMath needed)
- Recent enough for modern features
- Stable and widely supported
- Compatible with OpenZeppelin v5.x

**Interview Note:** Solidity 0.8.0+ added checked arithmetic by default, preventing integer overflow bugs that caused major exploits in DeFi history.

#### Optimizer: `true` with `200` runs
**What It Does:**
- Reduces bytecode size and gas costs
- Optimizes for frequently-called functions

**Trade-offs:**
- **More runs (1000+):** Optimizes runtime gas, increases deployment cost
- **Fewer runs (1):** Smaller deployment cost, higher runtime gas
- **200 runs:** Standard balance for most DeFi contracts

**Interview Question:** "Why 200 optimizer runs?"
- Industry standard for contracts with mixed usage patterns
- Balances deployment cost vs runtime efficiency
- Uniswap V2 uses 999999 (heavily optimized for swaps)
- Most DeFi protocols use 200-1000

#### Via IR: `false`
**What It Is:**
- Intermediate Representation compilation pipeline
- More aggressive optimization via Yul

**Why Not Enabled:**
- Slower compilation
- Potential edge case bugs (newer feature)
- 200 runs is sufficient for our use case
- Enable if contract size exceeds 24KB limit

#### Remappings
**Purpose:** Simplifies import paths in Solidity files.

**Before:**
```solidity
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
```

**After:**
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

**Interview Insight:** Remappings make code more readable and portable across different environments (Hardhat, Remix, etc.).

---

## Development Workflow

### Command: `forge build`
**Purpose:** Compiles all Solidity contracts in `src/` directory.

**What Happens:**
1. Reads `foundry.toml` for compiler settings
2. Compiles all `.sol` files in `src/`
3. Generates artifacts in `out/` directory:
   - ABI (Application Binary Interface) - for frontend integration
   - Bytecode - deployed contract code
   - Metadata - compiler version, optimization settings

**Output Structure:**
```
out/
├── DEXFactory.sol/
│   ├── DEXFactory.json         # Combined artifact
│   └── DEXFactory.abi.json     # ABI for frontend
├── DEXPair.sol/
│   ├── DEXPair.json
│   └── DEXPair.abi.json
└── MockERC20.sol/
    ├── MockERC20.json
    └── MockERC20.abi.json
```

**Common Build Flags:**
```bash
forge build --force          # Ignore cache, recompile everything
forge build --sizes          # Show contract sizes (24KB limit check)
forge build --via-ir         # Use IR pipeline (slower, better optimization)
```

**Interview Question:** "Why is contract size important?"
- **EIP-170:** 24KB (24,576 bytes) maximum per contract
- **Exceeding limit:** Contract cannot be deployed
- **Solutions:**
  - Enable optimizer with more runs
  - Split into multiple contracts
  - Use libraries for shared code
  - Use proxy patterns (separate logic/storage)

### Command: `forge clean`
**Purpose:** Removes build artifacts and cache.

**When to Use:**
- After changing compiler settings
- If builds are behaving unexpectedly
- Before measuring clean build times
- To save disk space

**Files Removed:**
- `out/` directory (build artifacts)
- `cache/` directory (compilation cache)

---

## Testing

### Command: `forge test`
**Purpose:** Runs all test contracts in `test/` directory.

**Test Discovery:**
- Files ending in `.t.sol`
- Functions starting with `test` prefix
- Contracts inheriting from `Test` (forge-std)

**Verbosity Levels:**
```bash
forge test           # Basic pass/fail
forge test -vv       # Show test names and results
forge test -vvv      # Add gas usage and console.log output
forge test -vvvv     # Add execution traces
forge test -vvvvv    # Add debug info
```

**Interview Insight:** Unlike Hardhat (JavaScript tests), Foundry tests are written in Solidity:
- **Pros:** Same language as contracts, faster execution, no JS wrapper
- **Cons:** Steeper learning curve if unfamiliar with Solidity testing

### Command: `forge test --match-test <pattern>`
**Purpose:** Runs specific tests matching the pattern.

**Examples:**
```bash
forge test --match-test testCreatePair        # Run specific test
forge test --match-test "test.*Factory"       # Run all factory tests
forge test --match-contract DEXFactoryTest    # Run all tests in contract
```

**Interview Tip:** Use pattern matching during development to iterate quickly on specific features.

### Command: `forge test --gas-report`
**Purpose:** Generates detailed gas usage report for all functions.

**What It Shows:**
- Gas used per function call
- Min/max/avg gas across test runs
- Identifies expensive operations

**Why It Matters:**
- Gas costs directly impact user experience
- High gas = fewer users willing to interact
- Critical for DEX competitiveness

**Interview Question:** "How do you optimize gas?"
1. **Storage optimization:** Pack variables, use uint128 instead of uint256
2. **Calldata over memory:** For function parameters
3. **Cache storage reads:** Load once into memory
4. **Unchecked math:** When overflow is impossible
5. **Short-circuit logic:** Order conditions by likelihood

### Command: `forge snapshot`
**Purpose:** Creates a gas snapshot for regression testing.

**What It Does:**
- Runs all tests and records gas usage
- Saves to `.gas-snapshot` file
- Future runs compare against baseline

**Usage:**
```bash
forge snapshot                    # Create baseline
forge snapshot --diff             # Compare with baseline
forge snapshot --check            # Fail if gas increased
```

**Interview Insight:** Gas regression testing ensures optimizations don't accidentally increase costs in future changes.

### Command: `forge coverage`
**Purpose:** Generates code coverage report.

**What It Shows:**
- Line coverage percentage
- Branch coverage
- Uncovered code sections

**Industry Standards:**
- **80%+ coverage:** Minimum for production DeFi
- **90%+ coverage:** Best practice
- **100% coverage:** Not necessary (diminishing returns)

**Interview Note:** Coverage doesn't guarantee no bugs, but <80% coverage is a red flag for financial contracts.

---

## Project Structure

### Core Contracts (Implemented)

#### `src/DEXFactory.sol`
**Purpose:** Factory for creating and managing liquidity pair contracts.

**Key Features:**
- Creates new pairs via `createPair(tokenA, tokenB)`
- Prevents duplicate pairs
- Registry for pair lookup: `getPair[token0][token1]`
- Uses CREATE2 for deterministic addresses
- Access control for fee management

**Interview Insight:** CREATE2 allows off-chain address calculation before deployment, enabling gasless transactions and counterfactual interactions.

#### `src/DEXPair.sol`
**Purpose:** Individual liquidity pool implementing constant product AMM (x * y = k).

**Key Features:**
- ERC20 LP token representing pool ownership
- `mint()` - Add liquidity, receive LP tokens
- `burn()` - Remove liquidity, burn LP tokens
- `swap()` - Execute token swaps with 0.3% fee
- `sync()` - Emergency reserve synchronization
- `skim()` - Recover excess tokens

**Math Formula:**
```
Constant Product: x * y = k
Swap with fee: amountOut = (amountIn * 997 * reserveOut) / (reserveIn * 1000 + amountIn * 997)
LP tokens on first mint: sqrt(amount0 * amount1)
```

**Security Features:**
- ReentrancyGuard on all state-changing functions
- Minimum liquidity lock (1000 wei) prevents manipulation
- TWAP oracle via cumulative prices
- Flash swap support (callback mechanism)

**Interview Question:** "Why minimum liquidity?"
- Prevents first LP from inflating token value
- Attacker can't mint tiny LP amount then manipulate price
- 1000 wei locked forever in address(0)
- Industry standard from Uniswap V2

#### `src/libraries/Math.sol`
**Purpose:** Mathematical utility functions.

**Functions:**
- `min(x, y)` - Returns minimum of two numbers
- `sqrt(y)` - Babylonian method square root

**Why Separate Library:**
- Code reusability across contracts
- Gas efficient (library code not duplicated)
- Easier to test and audit
- Can be shared across projects

**Interview Insight:** Babylonian square root (Newton's method) is gas-efficient and converges quickly: x_(n+1) = (x_n + a/x_n) / 2

#### `src/libraries/UQ112x112.sol`
**Purpose:** Fixed-point arithmetic for price representation.

**What Q112.112 Means:**
- 112 bits for integer part
- 112 bits for fractional part
- Total: 224 bits (uint224)

**Why Fixed-Point:**
- Solidity doesn't have native float/double
- Prices need fractional precision
- Used for TWAP oracle calculations

**Interview Question:** "Why not use decimals?"
- Fixed-point is more gas efficient than decimal math
- Prevents rounding errors in price calculations
- Industry standard for DEX oracles

#### `src/mocks/MockERC20.sol`
**Purpose:** Simple ERC20 token for testing.

**Features:**
- Inherits from OpenZeppelin ERC20
- Public `mint()` function for easy test setup
- Configurable name, symbol, initial supply

**Why Needed:**
- Can't deploy real tokens on local testnet
- Need controlled token supply for tests
- Faster than deploying complex tokens

---

## Deployment

### Local Deployment (Anvil)

#### Step 1: Start Local Node
```bash
anvil
```

**What This Does:**
- Starts local Ethereum node on http://127.0.0.1:8545
- Provides 10 test accounts with 10,000 ETH each
- Fast block times (instant or configurable)
- Clean state on each restart

**Interview Note:** Anvil is Foundry's equivalent to Ganache or Hardhat Node, but faster.

#### Step 2: Deploy Contracts
```bash
forge create src/DEXFactory.sol:DEXFactory \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --constructor-args <ADMIN_ADDRESS>
```

**⚠️ Security Warning:** The private key above is Anvil's default (public knowledge). **NEVER** use real private keys in commands or commit them to git!

**Better Approach:** Use environment variables
```bash
export PRIVATE_KEY="0x..."  # From .env file
forge create src/DEXFactory.sol:DEXFactory \
  --rpc-url http://127.0.0.1:8545 \
  --private-key $PRIVATE_KEY \
  --constructor-args $ADMIN_ADDRESS
```

### Testnet Deployment (Arbitrum Sepolia)

```bash
forge create src/DEXFactory.sol:DEXFactory \
  --rpc-url https://sepolia-rollup.arbitrum.io/rpc \
  --private-key $PRIVATE_KEY \
  --constructor-args $ADMIN_ADDRESS \
  --verify \
  --etherscan-api-key $ARBISCAN_API_KEY
```

**Environment Variables Required:**
```bash
export PRIVATE_KEY="0x..."           # Deployment account private key
export ARBISCAN_API_KEY="..."        # For contract verification
export ADMIN_ADDRESS="0x..."         # Fee setter address
```

**Interview Insight:** `--verify` flag automatically verifies contract source code on Arbiscan, making it readable and trustworthy for users.

### Script-Based Deployment (Recommended)

**Why Use Scripts:**
- Repeatable and version-controlled
- Can deploy multiple contracts in order
- Easier to test deployment flow
- Better for complex multi-contract deployments

**Example:** `script/Deploy.s.sol`
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DEXFactory.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.envAddress("ADMIN_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        DEXFactory factory = new DEXFactory(admin);
        console.log("Factory deployed at:", address(factory));
        
        vm.stopBroadcast();
    }
}
```

**Run Script:**
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify
```

---

## Troubleshooting

### Error: "Contract size exceeds limit"
**Cause:** Contract bytecode >24KB (EIP-170)

**Solutions:**
1. Enable optimizer with more runs:
```toml
optimizer = true
optimizer_runs = 1000
```

2. Enable via-ir:
```toml
via_ir = true
```

3. Split into libraries:
```solidity
library DEXLibrary {
    function calculateSwap(...) internal pure returns (...) {
        // Move complex logic here
    }
}
```

4. Use proxy pattern:
- Separate storage (proxy) and logic (implementation)
- Each contract <24KB

### Error: "Failed to resolve dependency"
**Cause:** Git submodules not initialized

**Solution:**
```bash
git submodule update --init --recursive
```

### Error: "Stack too deep"
**Cause:** Too many local variables in function

**Solutions:**
1. Reduce local variables:
```solidity
// Before
function swap(...) {
    uint256 var1 = ...;
    uint256 var2 = ...;
    // ... 20+ variables
}

// After - use scoped blocks
function swap(...) {
    {
        uint256 var1 = ...;
        // Use var1
    }
    {
        uint256 var2 = ...;
        // Use var2
    }
}
```

2. Enable via-ir (more stack slots available)

### Error: "Compilation failed"
**Common Causes:**
- Wrong Solidity version
- Missing imports
- Syntax errors

**Debug Steps:**
```bash
forge build --force           # Clean build
forge build -vvv             # Verbose output
solc --version               # Check compiler
```

---

## Gas Optimization Techniques

### 1. Storage Packing
**Before:**
```solidity
uint256 reserve0;    // 32 bytes
uint256 reserve1;    // 32 bytes
uint256 timestamp;   // 32 bytes
```

**After:**
```solidity
uint112 reserve0;         // 14 bytes
uint112 reserve1;         // 14 bytes
uint32 timestamp;         // 4 bytes
// Total: 32 bytes (1 storage slot)
```

**Savings:** 20,000 gas per storage write!

### 2. Use Calldata for Read-Only Parameters
```solidity
// Expensive (3 gas per word copy)
function swap(uint256[] memory amounts) external

// Cheap (direct access)
function swap(uint256[] calldata amounts) external
```

### 3. Cache Storage Reads
```solidity
// Expensive (200 gas per SLOAD)
function bad() external {
    require(reserve0 > 0);
    require(reserve1 > 0);
    uint256 k = reserve0 * reserve1;
}

// Cheap (1 SLOAD)
function good() external {
    uint112 _reserve0 = reserve0;  // Cache
    uint112 _reserve1 = reserve1;  // Cache
    require(_reserve0 > 0);
    require(_reserve1 > 0);
    uint256 k = uint256(_reserve0) * uint256(_reserve1);
}
```

### 4. Use Unchecked for Safe Math
```solidity
// Checked (overflow protection costs gas)
function increment(uint256 i) returns (uint256) {
    return i + 1;  // ~100 gas
}

// Unchecked (when overflow impossible)
function increment(uint256 i) returns (uint256) {
    unchecked {
        return i + 1;  // ~20 gas
    }
}
```

**Interview Warning:** Only use `unchecked` when you can **prove** overflow is impossible!

---

## Testing Best Practices & Common Issues

### Event Testing with `vm.expectEmit()`

**The Confusing API:**
```solidity
vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData)
```

**Parameters:**
- `checkTopic1-3`: Whether to check indexed parameters (topics)
- `checkData`: Whether to check non-indexed data parameters
  - ⚠️ **COUNTER-INTUITIVE:** `false` = DO check, `true` = DON'T check

**Common Error:**
```
PairCreated param mismatch at pair: expected=0x0000..., got=0xa07bf83c...
```

**What This Means:**
- You're checking a parameter that you don't have the correct value for
- Usually happens with dynamically generated values (addresses, timestamps, etc.)

**Example Problem:**
```solidity
// ❌ WRONG - This checks ALL parameters including the unknown pair address
vm.expectEmit(true, true, false, false);  // Last false = DO check data
emit PairCreated(token0, token1, address(0), 0);

factory.createPair(tokenA, tokenB);
```

**Solution 1: Skip Non-Indexed Parameters**
```solidity
// ✅ CORRECT - Only check indexed params (token0, token1)
vm.expectEmit(true, true, false, true);  // Last true = DON'T check data
emit PairCreated(token0, token1, address(0), 0);  // Values don't matter now

factory.createPair(tokenA, tokenB);
```

**Solution 2: Pre-compute Expected Values**
```solidity
// ✅ CORRECT - Check everything with correct values
address expectedPair = factory.pairFor(tokenA, tokenB);

vm.expectEmit(true, true, false, true);  // Check all
emit PairCreated(token0, token1, expectedPair, 1);

factory.createPair(tokenA, tokenB);
```

**Interview Tip:** Always explain why `vm.expectEmit()` has this confusing API:
- Foundry checks topics (indexed params) by matching event signatures
- Data parameters are checked separately via ABI decoding
- The boolean flags control which checks are performed

### Test Organization Best Practices

**Grouping Tests:**
```solidity
/* ========== INITIALIZATION TESTS ========== */
/* ========== PAIR CREATION TESTS ========== */
/* ========== FEE MANAGEMENT TESTS ========== */
/* ========== FUZZ TESTS ========== */
/* ========== GAS BENCHMARKING ========== */
```

**Why:** Makes test output readable, helps identify failing areas quickly

**Naming Convention:**
```solidity
testCreatePair()                    // Happy path
testCannotCreateDuplicatePair()     // Should revert
testFuzzCreatePair()                // Fuzz test
testGasCreatePair()                 // Gas benchmark
```

**Interview Note:** Consistent naming helps reviewers understand test intent immediately.

### Fuzz Testing Setup

**Basic Fuzz Test:**
```solidity
function testFuzzCreatePair(address token0, address token1) public {
    // Assumptions filter invalid inputs
    vm.assume(token0 != address(0));
    vm.assume(token1 != address(0));
    vm.assume(token0 != token1);
    
    // Test with random inputs
    factory.createPair(token0, token1);
}
```

**Why `vm.assume()`:**
- Filters out invalid test cases
- Prevents wasted fuzzing runs on known-invalid inputs
- More efficient than `require()` which counts as a failure

**Interview Question:** "What's the difference between `vm.assume()` and `require()`?"
- **`vm.assume()`:** Skips the test case (doesn't count as pass/fail)
- **`require()`:** Reverts the test (counts as failure)
- **Use case:** `vm.assume()` for input validation, `require()` for actual test assertions

**Fuzz Configuration:**
```toml
# In foundry.toml
[profile.default]
fuzz_runs = 256           # Number of random inputs (default)
fuzz_max_test_rejects = 65536  # Max rejections before giving up
```

**Interview Insight:** More fuzz runs = better coverage but slower tests. Balance based on test suite size.

### Gas Benchmarking

**Pattern:**
```solidity
function testGasCreatePair() public {
    uint256 gasBefore = gasleft();
    factory.createPair(tokenA, tokenB);
    uint256 gasUsed = gasBefore - gasleft();
    
    console.log("Gas used:", gasUsed);
}
```

**Why This Matters:**
- DEX operations happen frequently (every swap, every LP addition)
- High gas = poor UX, fewer users
- Competitors with lower gas win market share

**Typical Gas Costs (Reference):**
- Uniswap V2 swap: ~90,000 gas
- SushiSwap swap: ~95,000 gas
- Pair creation: ~3-4M gas (includes deployment)
- Pair lookup: ~2,000 gas (single SLOAD)

**Interview Question:** "How do you optimize gas?"
1. **Storage packing:** Combine variables into single slots
2. **Calldata over memory:** For read-only parameters
3. **Cache storage reads:** Load to memory once
4. **Unchecked math:** When overflow impossible
5. **Short-circuit conditions:** Check cheap conditions first

### Using `console.log` for Debugging

**Import:**
```solidity
import {console} from "forge-std/console.sol";
```

**Usage:**
```solidity
console.log("Pair address:", pair);
console.log("Reserve0:", reserve0, "Reserve1:", reserve1);
console.logUint(gasUsed);
console.logString("Test checkpoint");
```

**View Output:**
```bash
forge test -vv          # Show console.log output
forge test -vvv         # Show + gas usage
forge test -vvvv        # Show + execution traces
```

**Interview Tip:** `console.log` is Foundry's equivalent to Hardhat's console.log, but implemented in Solidity.

### Test Coverage Analysis

**Generate Coverage Report:**
```bash
forge coverage
```

**Generate Detailed HTML Report:**
```bash
forge coverage --report lcov
genhtml lcov.info -o coverage/
open coverage/index.html
```

**What to Look For:**
- **<80% coverage:** Red flag for production code
- **Uncovered lines:** Often edge cases or error paths
- **Branch coverage:** Every `if/else` path tested

**Interview Question:** "Is 100% coverage enough?"
**Answer:** No! Coverage shows what's tested, not what's tested *well*. You can have:
- 100% line coverage with poor assertions
- Missing edge cases within covered lines
- Logic errors in covered code

Coverage is necessary but not sufficient for quality.

### Common Test Failures & Solutions

#### 1. "Stack Too Deep" Error
```solidity
// ❌ Too many local variables
function testComplex() public {
    uint256 var1 = ...;
    uint256 var2 = ...;
    // ... 20 more variables
}

// ✅ Use scoped blocks
function testComplex() public {
    {
        uint256 var1 = ...;
        // Use var1
    }
    {
        uint256 var2 = ...;
        // Use var2
    }
}
```

#### 2. "Out of Gas" in Tests
```solidity
// ❌ Infinite loop or too many operations
function testBadLoop() public {
    for (uint i = 0; i < 10000000; i++) {
        // Gas intensive operation
    }
}

// ✅ Use realistic limits
function testGoodLoop() public {
    for (uint i = 0; i < 100; i++) {
        // Test with reasonable iterations
    }
}
```

#### 3. "Arithmetic Overflow" (Pre-0.8.0 behavior)
```solidity
// If using unchecked:
unchecked {
    uint256 result = type(uint256).max + 1;  // Overflows to 0
}

// Solution: Don't use unchecked unless you KNOW it's safe
```

#### 4. Reentrancy Not Caught in Tests
```solidity
// Test MUST call from external contract to trigger reentrancy
contract Attacker {
    function attack(DEXPair pair) external {
        pair.swap(...);  // This could reenter
    }
}

// In your test:
function testReentrancyProtection() public {
    Attacker attacker = new Attacker();
    vm.expectRevert();  // Should revert due to ReentrancyGuard
    attacker.attack(pair);
}
```

### Cheat Codes for Advanced Testing

**Time Manipulation:**
```solidity
vm.warp(block.timestamp + 1 days);  // Fast forward time
```

**Block Number:**
```solidity
vm.roll(block.number + 100);  // Fast forward blocks
```

**Impersonation:**
```solidity
vm.prank(address(0x123));  // Next call from this address
factory.setFeeTo(newAddress);  // Called as 0x123

vm.startPrank(address(0x123));  // All calls until stopPrank
factory.setFeeTo(addr1);
factory.setFeeToSetter(addr2);
vm.stopPrank();
```

**Expecting Reverts:**
```solidity
vm.expectRevert(CustomError.selector);  // Expect custom error
vm.expectRevert("Error message");        // Expect revert string
vm.expectRevert();                       // Expect any revert
```

**Deal ETH/Tokens:**
```solidity
vm.deal(user, 100 ether);  // Give user ETH
deal(address(token), user, 1000e18);  // Give user tokens
```

**Interview Insight:** These cheat codes make Foundry powerful for testing complex scenarios that would be impossible or expensive on real networks.

---

## Additional Resources

### Documentation
- **Foundry Book:** https://book.getfoundry.sh/
- **Solidity Docs:** https://docs.soliditylang.org/
- **OpenZeppelin Docs:** https://docs.openzeppelin.com/contracts/
- **Foundry Cheatcodes:** https://book.getfoundry.sh/cheatcodes/

### Security
- **Smart Contract Security Best Practices:** https://consensys.github.io/smart-contract-best-practices/
- **Solidity Patterns:** https://fravoll.github.io/solidity-patterns/
- **DeFi Security Summit:** https://www.defisecuritysummit.org/
- **Rekt News:** https://rekt.news/ (Learn from past exploits)

### Audits & Tools
- **Slither:** Static analysis tool (`pip install slither-analyzer`)
- **Mythril:** Security analysis (`pip install mythril`)
- **Echidna:** Fuzzing tool for Solidity
- **Certora:** Formal verification platform
- **Foundry Coverage:** Built-in coverage tool

### Testing Resources
- **Foundry Testing Guide:** https://book.getfoundry.sh/forge/tests
- **Solidity Test Patterns:** https://github.com/transmissions11/solmate (examples)
- **Uniswap V2 Tests:** https://github.com/Uniswap/v2-core/tree/master/test (reference implementation)

---

**Document Version:** 1.1  
**Last Updated:** 2024-11-10  
**Status:** Active Development

**Changelog:**
- v1.1: Added comprehensive testing section with event testing, fuzz testing, gas benchmarking, common failures
- v1.0: Initial version with setup, dependencies, configuration, deployment
