# Foundry Project Structure Details

## Top-level files and folders
- `.git/` : Git repository data
- `.github/` : GitHub workflows and configuration
- `.gitignore` : Files/folders to ignore in git
- `.gitmodules` : Git submodules configuration
- `README.md` : Project overview and instructions
- `foundry.lock` : Foundry dependency lock file
- `foundry.toml` : Foundry project configuration
- `lib/` : External libraries (e.g., forge-std)
- `script/` : Solidity scripts for deployment/interactions
- `src/` : Main Solidity contract sources
- `test/` : Solidity tests

## lib/forge-std
- Standard library for testing and utilities
- Contains its own README, licenses, scripts, sources, and tests

## script/
- Example: `Counter.s.sol` (sample deployment/interactions)

## src/
- Example: `Counter.sol` (sample contract)

## test/
- Example: `Counter.t.sol` (sample test for Counter)

---
This file will be updated as the project evolves to capture the structure and purpose of each component.
