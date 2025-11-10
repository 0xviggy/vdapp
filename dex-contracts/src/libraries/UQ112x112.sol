// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UQ112x112
 * @notice Fixed point Q112.112 library for price calculations
 * @dev Stores prices as Q112.112 format (112 bits for integer, 112 bits for fraction)
 * This allows precise price representation and TWAP oracle functionality
 */
library UQ112x112 {
    uint224 constant Q112 = 2**112;

    /**
     * @notice Encodes a uint112 as a UQ112x112
     * @param y The number to encode
     * @return z The encoded number
     */
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // Never overflows
    }

    /**
     * @notice Divides a UQ112x112 by a uint112, returning a UQ112x112
     * @param x The dividend (UQ112x112)
     * @param y The divisor (uint112)
     * @return z The quotient (UQ112x112)
     */
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}
