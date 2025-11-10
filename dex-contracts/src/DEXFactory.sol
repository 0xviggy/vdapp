// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DEXPair.sol";

/**
 * @title DEXFactory
 * @notice Factory contract for creating and managing DEX liquidity pairs
 * @dev Implements the factory pattern for pair creation with registry management
 */
contract DEXFactory {
    /// @notice Address that can set the fee recipient
    address public feeTo;
    
    /// @notice Address that can change feeTo
    address public feeToSetter;

    /// @notice Mapping of token pairs to their pool addresses
    /// @dev token0 -> token1 -> pair address (tokens are ordered)
    mapping(address => mapping(address => address)) public getPair;
    
    /// @notice Array of all created pairs
    address[] public allPairs;

    /// @notice Emitted when a new pair is created
    /// @param token0 Address of the first token (ordered)
    /// @param token1 Address of the second token (ordered)
    /// @param pair Address of the created pair contract
    /// @param pairCount Total number of pairs after creation
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256 pairCount
    );

    /// @notice Emitted when feeTo address is updated
    event FeeToSet(address indexed previousFeeTo, address indexed newFeeTo);

    /// @notice Emitted when feeToSetter address is updated
    event FeeToSetterSet(address indexed previousSetter, address indexed newSetter);

    error IdenticalAddresses();
    error ZeroAddress();
    error PairExists();
    error Unauthorized();

    /**
     * @notice Initializes the factory with the fee setter
     * @param _feeToSetter Address that can modify the feeTo address
     */
    constructor(address _feeToSetter) {
        if (_feeToSetter == address(0)) revert ZeroAddress();
        feeToSetter = _feeToSetter;
    }

    /**
     * @notice Returns the total number of pairs created
     * @return Total number of pairs
     */
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    /**
     * @notice Creates a new liquidity pair for two tokens
     * @dev Tokens are ordered to ensure canonical pair address
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @return pair Address of the created pair contract
     */
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        // Validation: tokens must be different
        if (tokenA == tokenB) revert IdenticalAddresses();
        
        // Order tokens canonically (token0 < token1)
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        
        // Validation: neither token can be zero address
        if (token0 == address(0)) revert ZeroAddress();
        
        // Validation: pair must not already exist
        if (getPair[token0][token1] != address(0)) revert PairExists();

        // Deploy new pair contract
        bytes memory bytecode = type(DEXPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        // Initialize the pair with token addresses
        DEXPair(pair).initialize(token0, token1);

        // Store pair in registry (both directions for lookup)
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // bidirectional lookup
        
        // Add to pairs array
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    /**
     * @notice Sets the address that receives protocol fees
     * @dev Only callable by feeToSetter
     * @param _feeTo New fee recipient address (can be zero to disable fees)
     */
    function setFeeTo(address _feeTo) external {
        if (msg.sender != feeToSetter) revert Unauthorized();
        address previousFeeTo = feeTo;
        feeTo = _feeTo;
        emit FeeToSet(previousFeeTo, _feeTo);
    }

    /**
     * @notice Updates the address that can set the fee recipient
     * @dev Only callable by current feeToSetter
     * @param _feeToSetter New feeToSetter address
     */
    function setFeeToSetter(address _feeToSetter) external {
        if (msg.sender != feeToSetter) revert Unauthorized();
        if (_feeToSetter == address(0)) revert ZeroAddress();
        address previousSetter = feeToSetter;
        feeToSetter = _feeToSetter;
        emit FeeToSetterSet(previousSetter, _feeToSetter);
    }

    /**
     * @notice Computes the deterministic pair address for two tokens
     * @dev Useful for off-chain pair address calculation
     * @param tokenA Address of the first token
     * @param tokenB Address of the second token
     * @return pair Predicted pair address
     */
    function pairFor(address tokenA, address tokenB) external view returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint256(keccak256(abi.encodePacked(
            hex'ff',
            address(this),
            keccak256(abi.encodePacked(token0, token1)),
            keccak256(type(DEXPair).creationCode)
        )))));
    }
}
