# L2 Bridge Mechanisms

## 1. Lock and Mint/Burn
- On deposit: User's tokens are locked in an L1 contract.
- Equivalent tokens are minted for the user on L2.
- On withdrawal: L2 tokens are burned, and L1 tokens are unlocked and sent to the user.
- Most common and secure for ERC20 tokens.

## 2. Canonical Bridge (Message Relay)
- Uses cross-chain messaging to relay deposit/withdrawal events.
- Bridge contracts on both L1 and L2 coordinate state changes.

## 3. Liquidity-based Bridge
- Uses liquidity pools on both chains.
- Users swap tokens across chains using available liquidity, not direct locking/minting.

---

For this project, the lock-and-mint/burn mechanism is recommended for ERC20 bridging.
