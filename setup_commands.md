# Project Setup Commands - Interview Guide# Project Setup Commands



This document provides a comprehensive guide to all setup commands used in this DEX project, with detailed explanations for reproducibility and interview preparation. Each section includes the command, its purpose, interview-relevant insights, and troubleshooting tips.This document provides a comprehensive guide to all setup commands used in this DEX project, with detailed explanations for reproducibility and interview preparation. Each section includes the command, its purpose, interview-relevant insights, and troubleshooting tips.



------



## Table of Contents## Table of Contents

1. [Prerequisites](#prerequisites)1. [Prerequisites](#prerequisites)

2. [Node.js Setup](#nodejs-setup)2. [Node.js Setup](#nodejs-setup)

3. [Foundry Installation](#foundry-installation)3. [Foundry Installation](#foundry-installation)

4. [Smart Contract Setup](#smart-contract-setup)4. [Smart Contract Setup](#smart-contract-setup)

5. [Frontend Setup](#frontend-setup)5. [Frontend Setup](#frontend-setup)

6. [Testing Infrastructure](#testing-infrastructure)6. [Testing Infrastructure](#testing-infrastructure)

7. [Linting & Code Quality](#linting--code-quality)7. [Linting & Code Quality](#linting--code-quality)

8. [CI/CD Setup](#cicd-setup)8. [CI/CD Setup](#cicd-setup)

9. [Git & Version Control](#git--version-control)9. [Version Control](#version-control)

10. [Deployment Commands](#deployment-commands)10. [Interview Tips](#interview-tips)

11. [Troubleshooting Guide](#troubleshooting-guide)

12. [Interview Tips & Common Questions](#interview-tips--common-questions)---



---## Prerequisites



## Prerequisites### System Requirements

- **OS:** Linux/macOS (Windows requires WSL)

### System Requirements- **Git:** Version 2.0+ for version control

- **OS:** Linux/macOS (Windows requires WSL2)- **curl:** For downloading installation scripts

- **Git:** Version 2.0+ for version control- **Build Tools:** gcc, make (for compiling native dependencies)

- **curl:** For downloading installation scripts

- **Build Tools:** gcc, make (for compiling native dependencies)**Interview Note:** Understanding system requirements demonstrates awareness of cross-platform compatibility and development environment setup, crucial for team collaboration.



**Interview Note:** Understanding system requirements demonstrates awareness of cross-platform compatibility and development environment setup, crucial for team collaboration and DevOps.---



### Verify Prerequisites## Node.js Setup

```bash

git --version        # Expected: ≥2.0### Command: `nvm install 20.9.0`

curl --version       # Expected: any recent version**Purpose:** Installs Node.js v20.9.0 using Node Version Manager (nvm).

gcc --version        # Expected: ≥7.0 (for native module compilation)

```**Why This Version:**

- Next.js 16+ requires Node.js ≥20.9.0 (LTS)

---- Ensures compatibility with latest React features

- Supports native ES modules and modern JavaScript syntax

## Node.js Setup

**Interview Insight:** Version management is critical in production. Using nvm allows:

### Why Node Version Management Matters- Multiple Node versions per system (different projects, different requirements)

- Easy switching: `nvm use 20.9.0`

**Interview Insight:** Different projects require different Node versions. Version managers like nvm prevent "works on my machine" problems and ensure team consistency.- Team consistency via `.nvmrc` file



### Command: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash`### Command: `nvm use 20.9.0`

**Purpose:** Installs Node Version Manager (nvm).**Purpose:** Switches current terminal session to Node.js v20.9.0.



**What This Does:****Alternative:** `nvm alias default 20.9.0` to set as system default.

1. Downloads nvm installation script

2. Installs nvm to `~/.nvm`### Command: `node --version && npm --version`

3. Adds nvm to shell configuration (`~/.bashrc`, `~/.zshrc`, etc.)**Purpose:** Verifies Node.js and npm installations.



**Security Note:** Always verify the source before piping to bash. Check the official repo: https://github.com/nvm-sh/nvm**Expected Output:**

```

### Command: `source ~/.bashrc`v20.9.0 (or higher)

**Purpose:** Reloads bash configuration to make nvm available in current session.npm 10.x.x

```

**Alternatives:**

- Bash: `source ~/.bashrc` or `. ~/.bashrc`**Troubleshooting:**

- Zsh: `source ~/.zshrc`- If version doesn't match: Run `nvm use 20.9.0` again

- Fish: `source ~/.config/fish/config.fish`- If nvm not found: Add to shell config (`~/.bashrc` or `~/.zshrc`)

- Or simply open a new terminal

---

### Command: `nvm install 20.9.0`

**Purpose:** Installs Node.js v20.9.0 using nvm.## Foundry Installation



**Why This Version:**### Command: `curl -L https://foundry.paradigm.xyz | bash`

- Next.js 16+ requires Node.js ≥20.9.0 (LTS)**Purpose:** Downloads and runs the official Foundry installation script. This installs `foundryup`, the Foundry toolchain installer, and updates your shell configuration to add Foundry to your PATH.

- Ensures compatibility with latest React features (React 19)

- Supports native ES modules and modern JavaScript syntax**What This Does:**

- Long-term support (LTS) until April 20261. Downloads the Foundry installer script

2. Installs `foundryup` binary to `~/.foundry/bin`

**Interview Question:** "Why use LTS versions?"3. Adds Foundry to PATH in shell config file

- **Stability:** Bug fixes and security patches for extended period4. Creates necessary directories for Foundry tools

- **Production Safety:** Tested, stable, predictable

- **Corporate Standard:** Most enterprises standardize on LTS**Interview Insight:** Piping curl to bash is common for installer scripts but has security implications. In production:

- Always verify the source (official Paradigm domain)

### Command: `nvm use 20.9.0`- Consider downloading script first, reviewing, then executing

**Purpose:** Switches current terminal session to Node.js v20.9.0.- Use checksums/signatures for verification



**Make Permanent:**### Command: `source ~/.bashrc`

```bash**Purpose:** Reloads bash configuration file to make Foundry tools available in current terminal session.

nvm alias default 20.9.0  # Set as system default

```**Why Needed:**

- Shell config files are read only at shell startup

**Project-Specific Version:**- `source` re-reads the file without restarting terminal

```bash- Alternative: Open new terminal window

echo "20.9.0" > .nvmrc     # Auto-switch when entering directory

nvm use                    # Reads version from .nvmrc**Shell-Specific Files:**

```- Bash: `~/.bashrc` or `~/.bash_profile`

- Zsh: `~/.zshrc`

**Interview Insight:** `.nvmrc` files ensure all team members use the same Node version, preventing version-related bugs.- Fish: `~/.config/fish/config.fish`



### Command: `node --version && npm --version`### Command: `foundryup`

**Purpose:** Verifies Node.js and npm installations.**Purpose:** Installs the complete Foundry toolchain to latest stable versions.



**Expected Output:****Tools Installed:**

```1. **forge** - Smart contract compilation, testing, deployment

v20.9.0 (or higher)2. **cast** - CLI for Ethereum RPC calls, transactions, encoding

npm 10.x.x3. **anvil** - Local Ethereum node for testing (similar to Ganache/Hardhat node)

```4. **chisel** - Solidity REPL for rapid prototyping



**Troubleshooting:****Version Verification:**

- Version doesn't match: Run `nvm use 20.9.0` again```bash

- nvm command not found: Reload shell or check installationforge --version  # Expected: forge 0.2.0+

- Permission errors: Never use `sudo` with nvm-installed Nodecast --version

anvil --version

---```



## Foundry Installation**Interview Insight:** Foundry is faster than Hardhat due to:

- Written in Rust (compiled language vs Node.js)

### Why Foundry?- Native Solidity compilation (no JavaScript overhead)

- Parallel test execution

**Interview Insight:** Foundry vs Hardhat comparison:- Minimal dependencies



| Feature | Foundry | Hardhat |**When to Use Foundry vs Hardhat:**

|---------|---------|---------|- **Foundry:** Speed-critical projects, Solidity-first teams, gas optimization work

| Language | Rust | JavaScript/TypeScript |- **Hardhat:** JavaScript ecosystem integration, extensive plugin needs, complex deployment scripts

| Test Speed | Very Fast | Moderate |

| Test Language | Solidity | JavaScript/TypeScript |---

| Gas Reports | Built-in | Plugin required |

| Fuzz Testing | Native | External tools |## Smart Contract Setup

| Ecosystem | Growing | Mature |

| Learning Curve | Steeper | Gentler |### Command: `forge init dex-contracts --force`

**Purpose:** Initializes a new Foundry project with standard directory structure.

**When to use Foundry:**

- Speed-critical projects**Directory Structure Created:**

- Solidity-first teams```

- Gas optimization workdex-contracts/

- Advanced testing (fuzz, invariant)├── foundry.toml       # Foundry configuration

├── src/               # Smart contracts

**When to use Hardhat:**├── test/              # Test files

- JavaScript ecosystem integration├── script/            # Deployment scripts

- Extensive plugin needs└── lib/               # Dependencies (forge-std)

- Complex deployment scripts```

- Team familiar with JS/TS

**Flags Explained:**

### Command: `curl -L https://foundry.paradigm.xyz | bash`- `--force`: Overwrites existing directory (useful for re-initialization)

**Purpose:** Downloads and installs Foundry toolchain installer.- Without flag: Fails if directory exists



**What This Does:****Interview Note:** Project structure follows Foundry conventions:

1. Downloads the Foundry installer script from official source- `src/` contains production contracts

2. Installs `foundryup` binary to `~/.foundry/bin`- `test/` mirrors `src/` structure with `.t.sol` suffix

3. Adds Foundry to PATH in shell config file- `script/` contains deployment/interaction scripts

4. Creates necessary directories for Foundry tools- `lib/` manages dependencies via git submodules



**Security Considerations:**### Command: `cd dex-contracts && forge install foundry-rs/forge-std --no-commit`

- Source is official Paradigm domain (creators of Foundry)**Purpose:** Installs forge-std library (testing utilities and base contracts).

- For extra safety: Download, inspect, then run separately

- Verify checksums in production environments**What forge-std Provides:**

- `Test.sol` - Base test contract with assertions

**Interview Note:** Piping curl to bash is common for installers (Node, Rust, etc.) but has risks. Discuss trade-offs between convenience and security.- `console.sol` - Console logging for debugging

- `Vm.sol` - Cheatcodes interface (time manipulation, impersonation, etc.)

### Command: `source ~/.bashrc`- `StdCheats.sol` - Common test utilities

**Purpose:** Reloads shell config to make `foundryup` available.

**Flags:**

### Command: `foundryup`- `--no-commit`: Doesn't auto-commit the submodule addition

**Purpose:** Installs the complete Foundry toolchain to latest stable versions.- Allows manual review before committing



**Tools Installed:****Interview Insight:** Foundry uses git submodules for dependencies instead of npm:

- **Pros:** Version-locked, no supply chain attacks, direct source access

#### 1. forge- **Cons:** Requires git knowledge, submodule management complexity

**Purpose:** Smart contract compilation, testing, deployment- **Alternative:** Soldeer (newer package manager for Solidity)

**Key Commands:**

```bash### Command: `forge build`

forge build              # Compile contracts**Purpose:** Compiles all Solidity contracts in `src/` directory.

forge test               # Run tests

forge test -vvv          # Verbose output with gas**Output:**

forge create Contract    # Deploy contract- Artifacts in `out/` directory (ABI, bytecode, metadata)

forge verify-contract    # Verify on Etherscan- Compilation errors/warnings

```- Contract size information



#### 2. cast**Common Flags:**

**Purpose:** CLI for Ethereum RPC calls and utilities- `--force`: Recompile all contracts (ignore cache)

**Key Commands:**- `--sizes`: Display contract sizes (useful for gas optimization)

```bash- `--optimize`: Enable optimizer with default 200 runs

cast call <addr> "balanceOf(address)" <user>    # Read contract

cast send <addr> "transfer(address,uint)" <to> <amt>  # Write**Interview Question:** "Why is contract size important?"

cast to-wei 1 ether      # Unit conversion- Ethereum has 24KB contract size limit (EIP-170)

cast block latest        # Get block info- Larger contracts cost more gas to deploy

```- Size optimization techniques: libraries, proxy patterns, bytecode optimization



#### 3. anvil### Command: `forge test`

**Purpose:** Local Ethereum node for testing (like Ganache/Hardhat Node)**Purpose:** Runs all test contracts in `test/` directory.

**Key Commands:**

```bash**Test Discovery:**

anvil                    # Start local node (http://127.0.0.1:8545)- Files ending in `.t.sol`

anvil --fork-url <rpc>   # Fork mainnet for testing- Functions starting with `test` prefix

```- Parallel execution by default



#### 4. chisel**Useful Flags:**

**Purpose:** Solidity REPL for rapid prototyping- `-vvv`: Verbose output (shows gas usage, logs)

**Use Case:** Test small code snippets interactively- `--match-test testSwap`: Run specific test

- `--match-contract DEXPairTest`: Run specific test contract

### Verify Installation- `--gas-report`: Show gas usage per function

```bash

forge --version    # Expected: forge 0.2.0 (or later)**Interview Insight:** Foundry tests run directly in Solidity (no JavaScript wrapper):

cast --version- Faster execution

anvil --version- Easier to write complex test scenarios

chisel --version- Direct access to EVM features

```- Built-in fuzz testing support



**Interview Insight:** Foundry is written in Rust, which provides:---

- Native performance (faster than Node.js-based tools)

- Memory safety (prevents crashes)## Frontend Setup

- Concurrent test execution

- Single binary distribution (easy CI/CD setup)**Command:** `npx create-next-app@latest dex-frontend --typescript`

**Explanation:** Creates a new Next.js app in the dex-frontend directory with TypeScript enabled for strict typing. Prompts for additional options (ESLint, Tailwind CSS, src directory, App Router, Turbopack, import alias). Note: Next.js 16+ requires Node.js >=20.9.0, but the app was created with Node.js 18.19.1. Some features may not work until Node is upgraded.

---

**Next.js Create App Prompts & Recommended Choices:**

## Smart Contract Setup

1. **ESLint:**

### Command: `forge init dex-contracts --force`	- *Prompt:* Which linter would you like to use?

**Purpose:** Initializes a new Foundry project with standard directory structure.	- *Recommended:* ESLint (industry standard for JS/TS linting)

	- *Interview Note:* Ensures code quality and consistency; highly customizable.

**Directory Structure Created:**

```2. **React Compiler:**

dex-contracts/	- *Prompt:* Would you like to use React Compiler?

├── foundry.toml       # Foundry configuration (compiler, paths, networks)	- *Recommended:* Yes (if using React 18+ and want advanced optimizations)

├── src/               # Smart contracts (production code)	- *Interview Note:* React Compiler can optimize rendering and improve performance, but may require latest React features and strict typing.

├── test/              # Test files (.t.sol suffix)

├── script/            # Deployment and interaction scripts3. **Tailwind CSS:**

├── lib/               # Dependencies (managed as git submodules)	- *Prompt:* Would you like to use Tailwind CSS?

└── out/               # Build artifacts (generated by forge build)	- *Recommended:* Yes (utility-first CSS framework, speeds up UI development)

```	- *Interview Note:* Tailwind is popular for rapid prototyping and maintainable styles; integrates well with Next.js.



**Flags Explained:**4. **src Directory:**

- `--force`: Overwrites existing directory if present	- *Prompt:* Would you like your code inside a `src/` directory?

- Without flag: Command fails if directory exists (safety measure)	- *Recommended:* Yes (keeps code organized and scalable)

	- *Interview Note:* Using a `src/` directory is a best practice for larger projects.

**Interview Note:** Foundry uses convention over configuration:

- `src/` for contracts mirrors industry standards5. **App Router:**

- `test/` files must end in `.t.sol` for auto-discovery	- *Prompt:* Would you like to use App Router? (recommended)

- `script/` for reproducible deployments	- *Recommended:* Yes (Next.js 13+ feature for file-based routing and layouts)

- `lib/` uses git submodules (version-locked dependencies)	- *Interview Note:* App Router enables advanced routing, layouts, and server components; recommended for new projects.



### Command: `cd dex-contracts`6. **Turbopack:**

**Purpose:** Navigate into project directory for subsequent commands.	- *Prompt:* Would you like to use Turbopack? (recommended)

	- *Recommended:* Yes (if you want faster builds and hot reloads)

### Command: `forge install foundry-rs/forge-std --no-commit`	- *Interview Note:* Turbopack is Next.js’s new bundler, replacing Webpack for better performance; still experimental but promising.

**Purpose:** Installs forge-std library (essential testing utilities and base contracts).

7. **Import Alias:**

**What forge-std Provides:**	- *Prompt:* Would you like to customize the import alias (`@/*` by default)?

- **Test.sol** - Base test contract with assertions (`assertTrue`, `assertEq`, etc.)	- *Recommended:* Default (`@/*`) unless you have a specific aliasing scheme.

- **console.sol** - Console logging for debugging (like Hardhat's console.log)	- *Interview Note:* Import aliases simplify module imports and refactoring; `@/*` is a common convention.

- **Vm.sol** - Cheatcodes interface (time travel, impersonation, etc.)

- **StdCheats.sol** - Common test utilities (deal, hoax, prank, etc.)**Command:** `cd dex-frontend && npm install --save-dev vitest @testing-library/react @testing-library/jest-dom jsdom`

- **Script.sol** - Base for deployment scripts**Explanation:** Installs Vitest (a fast, modern test runner for Vite/Next.js projects), React Testing Library (for component testing), Jest DOM (for DOM assertions), and jsdom (for simulating a browser environment in tests). This sets up the frontend for unit/component testing with TypeScript and React.



**Example Usage:****File Created:** `dex-frontend/vitest.config.ts`

```solidity**Explanation:** Vitest configuration file for frontend tests. Sets up jsdom environment, enables globals, and includes test files in `src/__tests__`.

import "forge-std/Test.sol";

import "forge-std/console.sol";**Command:** Add "test": "vitest" to package.json scripts

**Explanation:** Enables running frontend unit tests with `npm test` using Vitest.

contract MyTest is Test {

    function testSomething() public {**Command:** Add "type": "module" to dex-frontend/package.json

        console.log("Debug message");**Explanation:** Enables ES module support required by Vitest and Vite, resolving compatibility issues with Node.js and modern test runners.

        assertEq(1 + 1, 2);

    }**Command:** `mkdir -p .github/workflows`

}**Explanation:** Creates the directory structure for GitHub Actions workflows, which will be used for CI/CD automation (testing, deployment, etc.).

```

**File Created:** `.github/workflows/ci.yml`

**Flags:****Explanation:** This GitHub Actions workflow automates CI for both smart contracts and frontend:

- `--no-commit`: Doesn't auto-commit the submodule addition- Runs Foundry tests for contracts on every push/pull request.

- Allows manual review before committing (good practice)- Builds and tests the Next.js frontend using Node.js 20.9.0.

- Ensures code quality and fast feedback for both backend and frontend.

**Interview Insight:** Foundry dependency management:

- Uses **git submodules** instead of npm**Note:** ESLint and other tooling should be installed locally (as devDependencies) in your project. This ensures consistent versions and configuration for all contributors, reproducible builds, and compatibility with CI/CD. Global installs are discouraged for team or project workflows.

- **Pros:** Version-locked, no supply chain attacks, direct source access, reproducible builds

- **Cons:** Requires git knowledge, submodule update complexity**Command:** `npm install --save-dev eslint`

- **Alternative:** Soldeer (newer Solidity package manager, similar to npm)**Explanation:** Installs ESLint locally in the project as a devDependency, enabling consistent linting for all contributors and automated systems.



**Submodule Commands:****Command:** `npx eslint --init`

```bash**Explanation:** Runs the ESLint initialization wizard using the local install, allowing you to set up a configuration tailored for React, TypeScript, and Next.js.

git submodule update --init --recursive  # Initialize all submodules

git submodule update --remote            # Update to latest**Recommended ESLint Init Options and Differences:**

```- Lint: `javascript` (recommended for JS/TS projects; you can also choose `typescript` if only TS is used)

- Use: `problems` (recommended for catching code issues; `style` is for formatting, usually handled by Prettier)

### Command: `forge build`- Modules: `esm` (recommended for modern projects; `commonjs` is legacy)

**Purpose:** Compiles all Solidity contracts in `src/` directory.- Framework: `react` (recommended for React/Next.js projects)

- TypeScript: `Yes` (recommended for strict typing and modern frontend development)

**Compilation Process:**- Run: `browser` (recommended for frontend apps; choose `node` for backend)

1. Reads `foundry.toml` for compiler settings- Config language: `ts` (recommended for TypeScript projects; `js` is fine for JS-only)

2. Compiles all `.sol` files in `src/`- Install dependencies: `Yes` (recommended to ensure all required plugins and configs are present)

3. Generates artifacts in `out/` directory:- Package manager: `npm` (recommended unless you use yarn/pnpm)

   - ABI (Application Binary Interface)

   - Bytecode (deployed contract code)These options ensure ESLint is tailored for a modern React + TypeScript frontend, catching code issues and supporting best practices. Differences from defaults: enables TypeScript, ES modules, React, and browser environment, with a TypeScript config file.

   - Metadata (compiler version, optimization settings)

**Output Structure:**
```
out/
└── MyContract.sol/
    ├── MyContract.json      # Combined artifact
    ├── MyContract.abi.json  # ABI for frontend
    └── MyContract.metadata.json
```

**Common Flags:**
```bash
forge build --force          # Ignore cache, recompile everything
forge build --sizes          # Show contract sizes (important for 24KB limit)
forge build --optimize       # Enable optimizer (default 200 runs)
forge build --via-ir         # Use IR-based compiler (better optimization)
```

**Interview Question:** "Why is contract size important?"
- **EIP-170 Limit:** 24KB (24,576 bytes) per contract
- **Exceeding limit:** Contract cannot be deployed
- **Solutions:**
  - Libraries (external code)
  - Proxy patterns (split logic/storage)
  - Optimizer settings
  - Remove unnecessary code

**Gas Optimization:**
- More optimizer runs = smaller runtime gas, larger deploy size
- Fewer runs = larger runtime gas, smaller deploy size
- Default 200 runs balances both

### Command: `forge test`
**Purpose:** Runs all test contracts in `test/` directory.

**Test Discovery Rules:**
1. Files ending in `.t.sol`
2. Functions starting with `test` prefix
3. Must inherit from `Test` (forge-std)

**Example Test:**
```solidity
contract DEXPairTest is Test {
    function testMintLiquidity() public {
        // Test code here
    }
    
    function testFailUnauthorized() public {
        // Expected to revert
    }
}
```

**Useful Flags:**
```bash
forge test -vv                          # Show test results
forge test -vvv                         # Show gas usage and logs
forge test -vvvv                        # Show trace (execution steps)
forge test --match-test testSwap        # Run specific test
forge test --match-contract DEXPair     # Run specific test contract
forge test --gas-report                 # Detailed gas report
forge test --fuzz-runs 1000             # Fuzz test iterations
```

**Verbosity Levels:**
- `-v`: Basic (pass/fail)
- `-vv`: Logs from failed tests
- `-vvv`: Logs from all tests + gas
- `-vvvv`: Full execution trace
- `-vvvvv`: Debug info

**Interview Insight:** Foundry tests run directly in Solidity:
- **Faster:** No JavaScript wrapper, native EVM execution
- **Easier:** Write tests in same language as contracts
- **Powerful:** Direct access to EVM features
- **Fuzz Testing:** Built-in property-based testing

**Fuzz Testing Example:**
```solidity
function testSwapFuzz(uint256 amountIn) public {
    vm.assume(amountIn > 0 && amountIn < 1e30);
    // Test with random inputs
}
```

### Command: `forge coverage`
**Purpose:** Generates code coverage report for tests.

**Why Coverage Matters:**
- Industry standard: 80%+ coverage for production code
- Identifies untested code paths
- Helps find edge cases

**Interview Note:** 100% coverage doesn't mean bug-free, but <80% is risky for financial contracts.

---

## Frontend Setup

### Command: `npx create-next-app@latest dex-frontend --typescript`
**Purpose:** Creates a new Next.js application with TypeScript and interactive configuration.

**Why Next.js for DEX Frontend:**

| Feature | Benefit for DEX |
|---------|-----------------|
| **SSR/SSG** | Better SEO, faster initial load |
| **API Routes** | Backend endpoints without separate server |
| **File-Based Routing** | Intuitive URL structure (`/swap`, `/pool`) |
| **Image Optimization** | Automatic compression, lazy loading |
| **TypeScript** | Type safety for contract interactions |
| **React 19** | Latest features (use hook, suspense improvements) |

**Requirements:**
- Node.js ≥20.9.0 (enforced by Next.js 16+)
- npm 10+ or yarn/pnpm

**Interview Comparison:** Next.js vs Create React App vs Vite

| Feature | Next.js | CRA | Vite |
|---------|---------|-----|------|
| SSR | ✅ Built-in | ❌ No | ⚠️ Manual |
| Performance | 🟢 Excellent | 🟡 Good | 🟢 Excellent |
| Build Speed | 🟡 Good | 🔴 Slow | 🟢 Fast |
| Bundle Size | 🟢 Optimized | 🟡 Larger | 🟢 Optimized |
| Learning Curve | 🟡 Moderate | 🟢 Easy | 🟢 Easy |
| Production Use | 🟢 Widespread | ⚠️ Legacy | 🟢 Growing |

### Next.js Configuration Prompts

The `create-next-app` wizard asks several questions. Here are the recommended answers:

#### 1. TypeScript
- **Prompt:** "Would you like to use TypeScript?"
- **Recommended:** ✅ Yes
- **Why:** Type safety prevents runtime errors, better IDE support, self-documenting code
- **Interview Insight:** TypeScript catches ~15% of bugs at compile time (Microsoft research)

#### 2. ESLint
- **Prompt:** "Would you like to use ESLint?"
- **Recommended:** ✅ Yes
- **Why:** Industry-standard linting, catches common mistakes
- **Interview Insight:** ESLint + TypeScript = powerful bug prevention layer

#### 3. Tailwind CSS
- **Prompt:** "Would you like to use Tailwind CSS?"
- **Recommended:** ✅ Yes
- **Why:** Rapid UI development, consistent design system

**Interview Question:** "Tailwind vs traditional CSS?"

**Tailwind Pros:**
- Fast prototyping with utility classes
- Consistent spacing/colors (design system)
- No CSS bloat (PurgeCSS removes unused styles)
- Responsive design utilities (`md:`, `lg:`)

**Tailwind Cons:**
- Verbose HTML classes
- Learning curve for class names
- Harder to read for non-Tailwind developers

**Alternatives:**
- **CSS Modules:** Scoped styles, traditional CSS
- **Styled Components:** CSS-in-JS, dynamic styling
- **Emotion:** Similar to Styled Components
- **Vanilla CSS:** Maximum control, more boilerplate

#### 4. `src/` Directory
- **Prompt:** "Would you like your code inside a `src/` directory?"
- **Recommended:** ✅ Yes
- **Why:** Separates source code from config files, cleaner root

**Project Structure:**
```
dex-frontend/
├── src/              # All application code
│   ├── app/         # Next.js App Router
│   ├── components/  # React components
│   ├── hooks/       # Custom hooks
│   ├── lib/         # Utilities
│   └── types/       # TypeScript types
├── public/          # Static assets
└── [config files]   # Root stays clean
```

#### 5. App Router
- **Prompt:** "Would you like to use App Router?"
- **Recommended:** ✅ Yes (Next.js 13+ feature)
- **Why:** Modern routing, React Server Components, better performance

**Interview Insight:** App Router vs Pages Router

| Feature | App Router (New) | Pages Router (Legacy) |
|---------|------------------|----------------------|
| Directory | `app/` | `pages/` |
| Server Components | ✅ Default | ❌ Not supported |
| Layouts | ✅ Nested | ⚠️ Basic |
| Loading States | ✅ Built-in | ⚠️ Manual |
| Error Handling | ✅ Built-in | ⚠️ Manual |
| Streaming | ✅ Yes | ❌ No |
| Data Fetching | Server-first | Client-side |

**Migration Strategy:** Both routers can coexist during gradual migration.

#### 6. Turbopack
- **Prompt:** "Would you like to use Turbopack for `next dev`?"
- **Recommended:** ⚠️ Optional (experimental as of Nov 2024)
- **Why:** Rust-based bundler, dramatically faster than Webpack

**Interview Question:** "Turbopack vs Webpack?"
- **Speed:** 700x faster updates (Next.js claims)
- **Language:** Rust vs JavaScript
- **Maturity:** Beta vs Production-ready
- **Recommendation:** Webpack for production, Turbopack for experimentation

#### 7. Import Alias
- **Prompt:** "Would you like to customize the import alias?"
- **Recommended:** Default (`@/*`)
- **Why:** Cleaner imports, easier refactoring

**Before (relative paths):**
```typescript
import Button from '../../../../components/Button'
```

**After (alias):**
```typescript
import Button from '@/components/Button'
```

**Interview Note:** Import aliases prevent "relative path hell" and make code more maintainable.

### Command: `cd dex-frontend && npm install`
**Purpose:** Installs all dependencies listed in `package.json`.

**What Gets Installed:**
- next (framework)
- react, react-dom (UI library)
- typescript (type checker)
- tailwindcss, postcss, autoprefixer (styling)
- eslint, eslint-config-next (linting)
- @types/* (TypeScript definitions)

**Interview Insight:** `package-lock.json` ensures deterministic installs:
- Same versions across all environments
- Prevents "works on my machine" issues
- Security: Locks exact versions, including transitive dependencies

### Command: `npm run dev`
**Purpose:** Starts Next.js development server with hot reloading.

**What Happens:**
1. Starts server on http://localhost:3000
2. Enables Fast Refresh (HMR)
3. Shows compile errors in browser overlay
4. Type-checks on save

**Useful Variations:**
```bash
npm run dev              # Default (port 3000)
npm run dev -- -p 3001   # Custom port
npm run dev -- --turbo   # Use Turbopack (faster)
```

**Interview Question:** "What is Fast Refresh?"
- Hot Module Replacement (HMR) for React
- Preserves component state during edits
- Instant feedback without full reload
- Falls back to full reload if state can't be preserved

---

## Testing Infrastructure

### Why Vitest Over Jest?

**Interview Comparison:**

| Feature | Vitest | Jest |
|---------|--------|------|
| Speed | 🟢 Faster (uses esbuild) | 🟡 Moderate |
| ES Modules | ✅ Native | ⚠️ Experimental |
| Config | Vite-compatible | Separate |
| Watch Mode | 🟢 Very fast | 🟡 Good |
| Ecosystem | 🟡 Growing | 🟢 Mature |
| Learning Curve | 🟢 Easy (Jest-like) | 🟢 Easy |

**When to use Vitest:**
- Vite or Next.js projects
- Modern ES modules
- Speed is critical

**When to use Jest:**
- Large existing codebase
- Need specific Jest plugins
- Team familiar with Jest

### Command: `cd dex-frontend && npm install --save-dev vitest @testing-library/react @testing-library/jest-dom jsdom`
**Purpose:** Installs modern testing framework and utilities for React component testing.

**Packages Explained:**

#### 1. vitest
**Purpose:** Fast, modern test runner built on Vite
**Size:** ~600KB (vs Jest ~2MB)
**Speed:** 2-10x faster than Jest for most workloads

#### 2. @testing-library/react
**Purpose:** Test React components by behavior, not implementation

**Philosophy:** "The more your tests resemble the way your software is used, the more confidence they give you."

**Key APIs:**
```typescript
import { render, screen, fireEvent } from '@testing-library/react';

// Render component
const { container } = render(<Button>Click</Button>);

// Query by role (accessibility-focused)
const button = screen.getByRole('button', { name: /click/i });

// Simulate user interaction
fireEvent.click(button);

// Assertions
expect(button).toBeInTheDocument();
```

**Interview Insight:** Testing Library encourages:
- Querying by accessibility roles (`getByRole`)
- Testing user behavior, not implementation
- Avoiding testing internal state directly

#### 3. @testing-library/jest-dom
**Purpose:** Custom matchers for more readable DOM assertions

**Examples:**
```typescript
// Instead of:
expect(element.textContent).toBe('Hello');

// Use:
expect(element).toHaveTextContent('Hello');

// Other matchers:
expect(button).toBeDisabled();
expect(input).toHaveValue('text');
expect(element).toBeVisible();
expect(link).toHaveAttribute('href', '/page');
```

#### 4. jsdom
**Purpose:** JavaScript implementation of web standards (DOM, HTML, etc.)

**Why Needed:** Node.js doesn't have a DOM. jsdom simulates a browser environment for testing.

**Alternative:** happy-dom (lighter, faster, but less compatible)

**Interview Question:** "jsdom vs real browser testing?"
- **jsdom:** Fast, no browser overhead, good for unit tests
- **Real browser (Playwright/Cypress):** Slower, full browser API, good for E2E tests

### Command: Create `vitest.config.ts`
**Purpose:** Configures Vitest test runner.

**Configuration:**
```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',           // Simulate browser
    globals: true,                  // No imports needed for describe/it/expect
    setupFiles: './src/test/setup.ts',  // Run before each test file
    include: ['src/**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',               // Or 'istanbul'
      reporter: ['text', 'json', 'html'],
    },
  },
  resolve: {
    alias: {
      '@': '/src',                  // Match Next.js alias
    },
  },
});
```

**Interview Insight:** Configuration choices:
- `globals: true`: Reduces boilerplate but can cause naming conflicts
- `environment: 'jsdom'`: Needed for React testing
- `coverage.provider`: v8 is faster, istanbul more accurate

### Command: Update `package.json` - Add Scripts
**Purpose:** Enables running tests via npm commands.

**Add to `scripts` section:**
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest --coverage"
  }
}
```

**Script Explanations:**
- `test`: Run tests once (CI mode)
- `test:ui`: Open visual test UI
- `test:watch`: Watch mode (re-run on file changes)
- `test:coverage`: Generate coverage report

**Interview Note:** Consistent script names (`test`, `build`, `lint`) enable CI/CD to work across projects without modification.

### Command: Update `package.json` - Add Module Type
**Purpose:** Enables ES module support for modern JavaScript.

**Add to root level:**
```json
{
  "type": "module"
}
```

**Why Needed:**
- Vitest and modern tools use ES modules (`import/export`)
- Without this, Node.js defaults to CommonJS (`require/module.exports`)
- Next.js 16+ requires ES module compatibility

**Interview Question:** "CommonJS vs ES Modules?"

| Feature | CommonJS | ES Modules |
|---------|----------|------------|
| Syntax | `require()` | `import` |
| Loading | Synchronous | Asynchronous |
| Tree-shaking | ❌ No | ✅ Yes |
| Browser Support | ❌ No | ✅ Yes |
| Node Default | Legacy | Modern |
| Dynamic Imports | ❌ Limited | ✅ Full |

**Trade-offs:**
- ESM is the future, but migration can be challenging
- Some legacy packages only support CommonJS
- Can mix both with proper configuration

---

## Linting & Code Quality

### Why Local ESLint Installation?

**Interview Insight:** Local vs Global ESLint

| Aspect | Local (Recommended) | Global |
|--------|---------------------|--------|
| Version Control | ✅ Locked per project | ❌ System-wide |
| Team Consistency | ✅ Same for everyone | ❌ Varies per machine |
| CI/CD | ✅ Works automatically | ❌ Must install globally |
| Conflicts | ✅ Isolated | ❌ Version conflicts |

**Conclusion:** Always install linters locally as devDependencies.

### Command: `cd dex-frontend && npm install --save-dev eslint`
**Purpose:** Installs ESLint locally as a project dependency.

**Why ESLint:**
- Industry standard for JavaScript/TypeScript linting
- Catches common bugs and anti-patterns
- Enforces code style consistency
- Integrates with IDEs for real-time feedback

### Command: `npx eslint --init`
**Purpose:** Runs ESLint configuration wizard.

**Interactive Prompts & Recommendations:**

#### 1. How would you like to use ESLint?
- ✅ **To check syntax and find problems** (Recommended)
- ❌ To check syntax only (too basic)
- ❌ To check syntax, find problems, and enforce code style (use Prettier for style)

**Interview Note:** Separate concerns:
- **ESLint** for code quality (bugs, anti-patterns)
- **Prettier** for code formatting (spaces, line breaks)

#### 2. What type of modules does your project use?
- ✅ **JavaScript modules (import/export)** - ES Modules
- ❌ CommonJS (require/exports) - Legacy

#### 3. Which framework does your project use?
- ✅ **React**
- ❌ Vue
- ❌ None

#### 4. Does your project use TypeScript?
- ✅ **Yes**

#### 5. Where does your code run?
- ✅ **Browser** (for frontend)
- ❌ Node (for backend)

**Interview Note:** This affects which globals are available (e.g., `window`, `document` in browser).

#### 6. What format do you want your config file to be in?
- ✅ **TypeScript** (eslint.config.ts) - Recommended for TS projects
- ⚠️ JavaScript (eslint.config.js) - Fine for JS projects
- ❌ JSON (.eslintrc.json) - Harder to customize

#### 7. Install additional dependencies?
- ✅ **Yes** - Installs required plugins automatically

**Plugins Installed:**
- `@typescript-eslint/parser` - Parse TypeScript syntax
- `@typescript-eslint/eslint-plugin` - TypeScript-specific rules
- `eslint-plugin-react` - React best practices
- `eslint-plugin-react-hooks` - Hooks rules

### Command: Integrate Prettier (Optional but Recommended)
```bash
npm install --save-dev prettier eslint-config-prettier eslint-plugin-prettier
```

**Create `.prettierrc`:**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2
}
```

**Interview Question:** "Why Prettier + ESLint?"
- **ESLint:** Code quality (unused vars, potential bugs)
- **Prettier:** Code formatting (consistent style)
- **Integration:** eslint-config-prettier prevents conflicts

### Command: Add Lint Script
**Update `package.json`:**
```json
{
  "scripts": {
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,js,jsx,json,css,md}\""
  }
}
```

**Usage:**
```bash
npm run lint        # Check for issues
npm run lint:fix    # Auto-fix issues
npm run format      # Format with Prettier
```

**Interview Insight:** CI/CD should run `lint` (no fix) to catch issues before merge.

---

## CI/CD Setup

### Why CI/CD?

**Interview Answer:** Continuous Integration/Continuous Deployment ensures:
- Code quality gates before merge
- Automated testing prevents regressions
- Consistent build process
- Fast feedback on pull requests
- Automated deployments reduce human error

### Command: `mkdir -p .github/workflows`
**Purpose:** Creates directory structure for GitHub Actions workflows.

**Why `.github/workflows`:**
- GitHub Actions convention
- YAML files in this directory become workflows
- Triggers on push, PR, schedule, manual, etc.

### File: `.github/workflows/ci.yml`
**Purpose:** Defines CI pipeline for automated testing.

**Complete Configuration:**
```yaml
name: CI

on:
  push:
    branches: [main, master, develop]
  pull_request:
    branches: [main, master, develop]

jobs:
  contracts:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive  # Important for Foundry deps
      
      - name: Install Foundry
        uses: foundry-rs/foundry-toolchain@v1
        with:
          version: nightly
      
      - name: Run Forge tests
        run: |
          cd dex-contracts
          forge test -vvv
      
      - name: Check contract sizes
        run: |
          cd dex-contracts
          forge build --sizes
  
  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20.9.0'
          cache: 'npm'
          cache-dependency-path: dex-frontend/package-lock.json
      
      - name: Install dependencies
        run: |
          cd dex-frontend
          npm ci  # Faster, stricter than npm install
      
      - name: Run tests
        run: |
          cd dex-frontend
          npm test
      
      - name: Build
        run: |
          cd dex-frontend
          npm run build
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        if: always()
```

**Interview Insights:**

#### Why `npm ci` instead of `npm install`?
- **Faster:** Uses package-lock.json directly
- **Stricter:** Fails if lock file is out of sync
- **Cleaner:** Removes node_modules before install
- **Deterministic:** Guaranteed reproducible installs

#### Why `actions/checkout@v4` with submodules?
- Foundry dependencies (forge-std) are git submodules
- Without `submodules: recursive`, tests fail

#### Why separate jobs for contracts and frontend?
- **Parallel execution:** Faster CI
- **Isolation:** Contract bugs don't affect frontend tests
- **Clearer failures:** Know exactly what broke

#### Why cache Node modules?
- Speeds up CI by ~30-50%
- GitHub Actions caches `node_modules` between runs

### Command: `git add .github && git commit -m "Add CI pipeline"`
**Purpose:** Version control the CI configuration.

**Interview Note:** CI/CD as code ensures:
- Reproducible builds
- Version history of pipeline changes
- Easy rollback if pipeline breaks

---

## Git & Version Control

### Command: `git init`
**Purpose:** Initializes a new Git repository.

**What This Does:**
- Creates `.git/` directory (repository metadata)
- Sets up master/main branch
- Enables version control

### Command: `git add .`
**Purpose:** Stages all files for commit.

**Alternatives:**
```bash
git add src/          # Stage specific directory
git add *.sol         # Stage by pattern
git add -p            # Interactive staging (review each change)
```

**Interview Question:** "Staging vs working directory?"
- **Working Directory:** Current file state
- **Staging Area (Index):** Changes prepared for commit
- **Repository:** Committed history

### Command: `git commit -m "Initial commit"`
**Purpose:** Creates a commit with staged changes.

**Best Practices:**
- **Atomic commits:** One logical change per commit
- **Clear messages:** Explain what and why, not how
- **Conventional Commits:** Format for consistency

**Conventional Commit Format:**
```
type(scope): description

feat(dex): add swap functionality
fix(frontend): correct price calculation
docs(readme): update installation steps
test(pair): add fuzz tests for mint
refactor(router): simplify path finding logic
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `test`: Adding tests
- `refactor`: Code change without behavior change
- `perf`: Performance improvement
- `chore`: Build process or auxiliary tool changes

### Command: `git remote add origin <url>`
**Purpose:** Links local repository to GitHub remote.

```bash
git remote add origin git@github.com:0xviggy/vdapp.git
```

### Command: `git push -u origin master`
**Purpose:** Pushes commits to remote and sets upstream tracking.

**Flags:**
- `-u` or `--set-upstream`: Remember branch for future pushes
- After first push: `git push` works without specifying remote

### Create `.gitignore`
**Purpose:** Prevents committing unnecessary files.

**Recommended `.gitignore`:**
```gitignore
# Dependencies
node_modules/

# Build outputs
out/
dist/
build/
.next/
*.log

# Environment variables (NEVER commit secrets!)
.env
.env.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Foundry
cache/
broadcast/

# Testing
coverage/
.coverage/

# Temporary
*.tmp
*.temp
.cache/
```

**Interview Warning:** NEVER commit:
- Private keys
- API secrets
- `.env` files with sensitive data
- Database credentials

**If accidentally committed:**
```bash
git filter-repo --path .env --invert-paths  # Remove from history
# Then rotate all secrets immediately!
```

---

## Deployment Commands

### Smart Contract Deployment

#### Local Deployment (Anvil)
```bash
# Terminal 1: Start local node
anvil

# Terminal 2: Deploy
cd dex-contracts
forge create src/DEXFactory.sol:DEXFactory \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

**Interview Note:** The private key above is Anvil's default (public knowledge). Never use real private keys in commands!

#### Testnet Deployment (Arbitrum Sepolia)
```bash
forge create src/DEXFactory.sol:DEXFactory \
  --rpc-url https://sepolia-rollup.arbitrum.io/rpc \
  --private-key $PRIVATE_KEY \
  --verify \
  --etherscan-api-key $ARBISCAN_API_KEY
```

**Environment Variables:**
```bash
export PRIVATE_KEY="0x..."  # From .env, never hardcode!
export ARBISCAN_API_KEY="..."
```

#### Deploy Script (Recommended)
**Create `script/Deploy.s.sol`:**
```solidity
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DEXFactory.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        DEXFactory factory = new DEXFactory(msg.sender);
        console.log("Factory deployed at:", address(factory));
        
        vm.stopBroadcast();
    }
}
```

**Run:**
```bash
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify
```

**Interview Insight:** Script-based deployment:
- Repeatable and version-controlled
- Can deploy multiple contracts in order
- Easier to test deployment flow
- Better than manual `forge create` for complex deployments

### Frontend Deployment

#### Vercel (Recommended for Next.js)
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
cd dex-frontend
vercel --prod
```

**Or use GitHub integration:**
1. Connect repository to Vercel
2. Auto-deploys on push to main
3. Preview deployments for PRs

**Environment Variables in Vercel:**
- Set via Vercel dashboard or CLI
- `NEXT_PUBLIC_*` variables are embedded in build (safe for RPC URLs, contract addresses)
- Non-prefixed variables stay server-side (safe for API keys)

**Interview Question:** "NEXT_PUBLIC_ prefix?"
- **With prefix:** Embedded in client-side bundle, visible to users
- **Without prefix:** Server-side only, not exposed
- **Use case:** RPC URLs can be public, but admin API keys must not have prefix

---

## Troubleshooting Guide

### Node.js Issues

#### Error: "The engine 'node' is incompatible"
**Cause:** Wrong Node.js version
**Solution:**
```bash
nvm install 20.9.0
nvm use 20.9.0
```

#### Error: "ERR_REQUIRE_ESM"
**Cause:** Package requires ES modules, but project uses CommonJS
**Solution:**
1. Add `"type": "module"` to `package.json`
2. Update imports: `require()` → `import`
3. Or use dynamic import: `const mod = await import('package')`

### Foundry Issues

#### Error: "foundry: command not found"
**Cause:** PATH not updated or shell not reloaded
**Solution:**
```bash
source ~/.bashrc  # Or ~/.zshrc
foundryup
```

#### Error: "Failed to resolve dependency"
**Cause:** Git submodules not initialized
**Solution:**
```bash
git submodule update --init --recursive
```

#### Error: "Contract exceeds size limit"
**Cause:** Contract >24KB (EIP-170 limit)
**Solutions:**
1. Enable optimizer: Add to `foundry.toml`:
```toml
[profile.default]
optimizer = true
optimizer_runs = 200
```

2. Use libraries for shared code
3. Split into multiple contracts with proxy pattern

### Frontend Issues

#### Error: "Module not found: Can't resolve '@/components/...'"
**Cause:** Import alias not configured
**Solution:** Check `tsconfig.json`:
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

#### Error: "Hydration failed"
**Cause:** Server-rendered HTML doesn't match client render
**Common Causes:**
- `useEffect` for initial state
- Date/time formatting
- Random values

**Solution:**
```typescript
// Bad: Causes hydration error
const [id] = useState(Math.random());

// Good: Generate client-side only
const [id, setId] = useState<number>();
useEffect(() => {
  setId(Math.random());
}, []);
```

### Git Issues

#### Error: "Updates were rejected because the remote contains work"
**Cause:** Remote has commits not in local branch
**Solution:**
```bash
git pull --rebase origin master  # Rebase local commits on top
git push
```

#### Error: "fatal: not a git repository"
**Cause:** Not in a Git repository
**Solution:**
```bash
git init
```

### Testing Issues

#### Error: "ReferenceError: describe is not defined"
**Cause:** Missing test globals
**Solution:** Add to `vitest.config.ts`:
```typescript
export default defineConfig({
  test: {
    globals: true,  // Enables describe, it, expect
  }
});
```

---

## Interview Tips & Common Questions

### System Design Questions

**Q: "How would you architect a DEX frontend?"**

**A:** Layer approach:
1. **Smart Contract Layer:** Factory, Pair, Router (on-chain logic)
2. **Blockchain Interface:** ethers.js/viem for contract interaction
3. **State Management:** Context API or Zustand for wallet, balances
4. **UI Components:** React components with Tailwind
5. **API Layer:** Next.js API routes for off-chain data (prices, analytics)

**Q: "How do you handle private keys securely?"**

**A:**
- **Development:** Environment variables, never commit
- **Production:** Hardware wallets, KMS, MPC wallets
- **Users:** WalletConnect, MetaMask (never touch private keys)
- **Scripts:** Ledger integration for deployment scripts

### Testing Questions

**Q: "What's your testing strategy for smart contracts?"**

**A:** Test pyramid:
1. **Unit Tests:** Individual functions (90% coverage)
2. **Integration Tests:** Multiple contracts interacting
3. **Fuzz Tests:** Property-based testing with random inputs
4. **Invariant Tests:** Global state properties that should always hold
5. **Gas Tests:** Optimize expensive operations
6. **Upgrade Tests:** Test proxy upgrade paths

**Example:**
```solidity
// Unit test
function testMint() public { /* ... */ }

// Fuzz test
function testMintFuzz(uint256 amount) public { /* ... */ }

// Invariant test
function invariant_K() public {
    assertEq(pair.reserve0() * pair.reserve1(), K);
}
```

**Q: "How do you test frontend components?"**

**A:**
1. **Unit Tests:** Individual components (Vitest + Testing Library)
2. **Integration Tests:** Component interactions
3. **E2E Tests:** Full user flows (Playwright/Cypress)
4. **Visual Regression:** Screenshot comparison (Percy/Chromatic)

### Performance Questions

**Q: "How do you optimize gas usage?"**

**A:**
1. **Use `calldata` instead of `memory` for function params**
2. **Pack storage variables** (use uint128 instead of uint256 when possible)
3. **Cache storage reads** in memory
4. **Use `unchecked` blocks** for safe math operations
5. **Batch operations** to reduce transaction count

**Q: "How do you optimize frontend performance?"**

**A:**
1. **Code splitting:** Dynamic imports for large components
2. **Image optimization:** Next.js Image component
3. **Caching:** SWR or React Query for data fetching
4. **Lazy loading:** Load components on scroll
5. **Memoization:** `useMemo`, `useCallback` for expensive operations

### Security Questions

**Q: "What are common smart contract vulnerabilities?"**

**A:**
1. **Reentrancy:** Use ReentrancyGuard or checks-effects-interactions pattern
2. **Integer overflow:** Use Solidity 0.8+ (built-in checks) or SafeMath
3. **Front-running:** Use commit-reveal or batch auctions
4. **Access control:** Proper use of modifiers and role-based access
5. **Flash loan attacks:** Manipulated price oracles

**Q: "How do you secure API keys?"**

**A:**
- **Never commit to Git** (use .env, add to .gitignore)
- **Rotate regularly**
- **Use least privilege principle**
- **Server-side only** for sensitive keys (not NEXT_PUBLIC_)
- **Consider key management services** (AWS KMS, Vault)

### Debugging Questions

**Q: "Contract deployment fails. How do you debug?"**

**A:**
1. **Check gas:** Ensure enough ETH for deployment
2. **Verify bytecode size:** Must be <24KB
3. **Test locally first:** Deploy to Anvil before testnet
4. **Use verbose output:** `forge create --verify -vvvv`
5. **Check constructor params:** Verify types and values

**Q: "Frontend shows wrong data. How do you debug?"**

**A:**
1. **Check network:** Verify connected to correct chain
2. **Inspect RPC calls:** Browser DevTools → Network tab
3. **Console.log contract calls:** Log inputs/outputs
4. **Verify contract address:** Ensure using correct deployed address
5. **Check block number:** Ensure not reading stale data

---

## Quick Reference

### Common Commands

**Foundry:**
```bash
forge build                  # Compile contracts
forge test -vvv             # Run tests with gas
forge snapshot              # Gas snapshot
forge fmt                   # Format Solidity code
cast call <addr> "func()"   # Read contract
cast send <addr> "func()"   # Write contract
anvil                       # Start local node
```

**Next.js/Frontend:**
```bash
npm run dev                 # Start dev server
npm run build               # Production build
npm run test                # Run tests
npm run lint                # Lint code
npm run format              # Format code
```

**Git:**
```bash
git status                  # Check status
git add .                   # Stage all
git commit -m "msg"         # Commit
git push                    # Push to remote
git pull                    # Pull from remote
git log --oneline           # View history
```

### Key Files

**Smart Contracts:**
- `foundry.toml` - Foundry configuration
- `src/*.sol` - Contract source code
- `test/*.t.sol` - Test files
- `script/*.s.sol` - Deployment scripts

**Frontend:**
- `package.json` - Dependencies and scripts
- `next.config.ts` - Next.js configuration
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.ts` - Tailwind configuration
- `vitest.config.ts` - Test configuration
- `.env.local` - Environment variables (don't commit!)

**CI/CD:**
- `.github/workflows/*.yml` - GitHub Actions workflows

**Version Control:**
- `.gitignore` - Files to ignore
- `.gitmodules` - Git submodules (Foundry deps)

---

## Additional Resources

### Documentation
- **Foundry Book:** https://book.getfoundry.sh/
- **Next.js Docs:** https://nextjs.org/docs
- **Vitest Docs:** https://vitest.dev/
- **Testing Library:** https://testing-library.com/
- **Solidity Docs:** https://docs.soliditylang.org/

### Learning Resources
- **Foundry Tutorial:** https://github.com/dabit3/foundry-tutorial
- **Next.js Learn:** https://nextjs.org/learn
- **Smart Contract Security:** https://consensys.github.io/smart-contract-best-practices/
- **Uniswap V2 Docs:** https://docs.uniswap.org/contracts/v2/overview

### Tools
- **Arbiscan:** https://arbiscan.io/ (Arbitrum block explorer)
- **Remix IDE:** https://remix.ethereum.org/ (Browser Solidity IDE)
- **Tenderly:** https://tenderly.co/ (Debugging and monitoring)
- **OpenZeppelin Wizard:** https://wizard.openzeppelin.com/ (Generate contracts)

---

**Document Version:** 2.0  
**Last Updated:** 2024-11-10  
**Maintained By:** Development Team  
**Status:** Production Ready & Interview Optimized
