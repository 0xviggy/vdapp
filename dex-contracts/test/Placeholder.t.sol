// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Placeholder.sol";

contract PlaceholderTest is Test {
    function testAlwaysTrue() public {
        Placeholder p = new Placeholder();
        assertTrue(p.alwaysTrue());
    }
}
