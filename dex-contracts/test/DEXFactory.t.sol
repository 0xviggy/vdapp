// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DEXFactory} from "../src/DEXFactory.sol";
import {DEXPair} from "../src/DEXPair.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

/**
 * @title DEXFactoryTest
 * @notice Comprehensive test suite for DEXFactory contract
 */
contract DEXFactoryTest is Test {
    DEXFactory public factory;
    MockERC20 public tokenA;
    MockERC20 public tokenB;
    MockERC20 public tokenC;
    
    address public admin = address(this);
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256 pairCount
    );
    
    event FeeToSet(address indexed previousFeeTo, address indexed newFeeTo);
    event FeeToSetterSet(address indexed previousSetter, address indexed newSetter);

    function setUp() public {
        // Deploy factory
        factory = new DEXFactory(admin);
        
        // Deploy test tokens with different addresses
        tokenA = new MockERC20("Token A", "TKA", 1000000 ether);
        tokenB = new MockERC20("Token B", "TKB", 1000000 ether);
        tokenC = new MockERC20("Token C", "TKC", 1000000 ether);
        
        // Ensure token addresses are ordered for testing
        if (address(tokenA) > address(tokenB)) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }
    }

    /* ========== INITIALIZATION TESTS ========== */

    function testFactoryInitialization() public view {
        assertEq(factory.feeToSetter(), admin, "Fee setter should be admin");
        assertEq(factory.feeTo(), address(0), "feeTo should be zero initially");
        assertEq(factory.allPairsLength(), 0, "Should have no pairs initially");
    }

    function testCannotInitializeWithZeroAddress() public {
        vm.expectRevert(DEXFactory.ZeroAddress.selector);
        new DEXFactory(address(0));
    }

    /* ========== PAIR CREATION TESTS ========== */

    function testCreatePair() public {
        address pair = factory.createPair(address(tokenA), address(tokenB));
        
        assertNotEq(pair, address(0), "Pair address should not be zero");
        assertEq(factory.allPairsLength(), 1, "Should have 1 pair");
        assertEq(factory.allPairs(0), pair, "Pair should be in array");
        
        // Test bidirectional lookup
        assertEq(factory.getPair(address(tokenA), address(tokenB)), pair, "Should find pair A->B");
        assertEq(factory.getPair(address(tokenB), address(tokenA)), pair, "Should find pair B->A");
        
        // Verify pair is initialized correctly
        DEXPair pairContract = DEXPair(pair);
        (address token0, address token1) = address(tokenA) < address(tokenB) 
            ? (address(tokenA), address(tokenB))
            : (address(tokenB), address(tokenA));
        assertEq(pairContract.token0(), token0, "Token0 should be set correctly");
        assertEq(pairContract.token1(), token1, "Token1 should be set correctly");
        assertEq(pairContract.factory(), address(factory), "Factory should be set");
    }

    function testCreatePairEmitsEvent() public {
        (address token0, address token1) = address(tokenA) < address(tokenB) 
            ? (address(tokenA), address(tokenB))
            : (address(tokenB), address(tokenA));
        
        // Pre-compute the expected pair address using CREATE2
        address expectedPair = factory.pairFor(address(tokenA), address(tokenB));
        
        // Check that PairCreated event is emitted with correct values
        vm.expectEmit(true, true, false, true);
        emit PairCreated(token0, token1, expectedPair, 1);
        
        factory.createPair(address(tokenA), address(tokenB));
    }

    function testCreatePairReverseOrder() public {
        // Create pair with tokens in reverse order
        address pair1 = factory.createPair(address(tokenA), address(tokenB));
        
        // Should return same pair regardless of token order
        address pair2Query = factory.getPair(address(tokenB), address(tokenA));
        assertEq(pair1, pair2Query, "Should return same pair for reverse order");
    }

    function testCreateMultiplePairs() public {
        address pair1 = factory.createPair(address(tokenA), address(tokenB));
        address pair2 = factory.createPair(address(tokenA), address(tokenC));
        address pair3 = factory.createPair(address(tokenB), address(tokenC));
        
        assertEq(factory.allPairsLength(), 3, "Should have 3 pairs");
        assertNotEq(pair1, pair2, "Pairs should have different addresses");
        assertNotEq(pair2, pair3, "Pairs should have different addresses");
        assertNotEq(pair1, pair3, "Pairs should have different addresses");
    }

    function testCannotCreateDuplicatePair() public {
        factory.createPair(address(tokenA), address(tokenB));
        
        vm.expectRevert(DEXFactory.PairExists.selector);
        factory.createPair(address(tokenA), address(tokenB));
    }

    function testCannotCreateDuplicatePairReverseOrder() public {
        factory.createPair(address(tokenA), address(tokenB));
        
        // Should fail even with reverse order
        vm.expectRevert(DEXFactory.PairExists.selector);
        factory.createPair(address(tokenB), address(tokenA));
    }

    function testCannotCreatePairWithIdenticalTokens() public {
        vm.expectRevert(DEXFactory.IdenticalAddresses.selector);
        factory.createPair(address(tokenA), address(tokenA));
    }

    function testCannotCreatePairWithZeroAddress() public {
        vm.expectRevert(DEXFactory.ZeroAddress.selector);
        factory.createPair(address(0), address(tokenB));
        
        vm.expectRevert(DEXFactory.ZeroAddress.selector);
        factory.createPair(address(tokenA), address(0));
    }

    /* ========== FEE MANAGEMENT TESTS ========== */

    function testSetFeeTo() public {
        address newFeeTo = address(0x123);
        
        vm.expectEmit(true, true, false, true);
        emit FeeToSet(address(0), newFeeTo);
        
        factory.setFeeTo(newFeeTo);
        assertEq(factory.feeTo(), newFeeTo, "feeTo should be updated");
    }

    function testSetFeeToZeroAddress() public {
        // Should allow setting to zero (disabling fees)
        address newFeeTo = address(0x123);
        factory.setFeeTo(newFeeTo);
        
        factory.setFeeTo(address(0));
        assertEq(factory.feeTo(), address(0), "feeTo should be zero");
    }

    function testCannotSetFeeToUnauthorized() public {
        vm.prank(user1);
        vm.expectRevert(DEXFactory.Unauthorized.selector);
        factory.setFeeTo(address(0x123));
    }

    function testSetFeeToSetter() public {
        address newSetter = address(0x456);
        
        vm.expectEmit(true, true, false, true);
        emit FeeToSetterSet(admin, newSetter);
        
        factory.setFeeToSetter(newSetter);
        assertEq(factory.feeToSetter(), newSetter, "feeToSetter should be updated");
    }

    function testCannotSetFeeToSetterZeroAddress() public {
        vm.expectRevert(DEXFactory.ZeroAddress.selector);
        factory.setFeeToSetter(address(0));
    }

    function testCannotSetFeeToSetterUnauthorized() public {
        vm.prank(user1);
        vm.expectRevert(DEXFactory.Unauthorized.selector);
        factory.setFeeToSetter(address(0x456));
    }

    function testNewFeeToSetterCanSetFeeTo() public {
        address newSetter = address(0x456);
        address newFeeTo = address(0x789);
        
        // Admin sets new fee setter
        factory.setFeeToSetter(newSetter);
        
        // New setter can set feeTo
        vm.prank(newSetter);
        factory.setFeeTo(newFeeTo);
        
        assertEq(factory.feeTo(), newFeeTo, "New setter should be able to set feeTo");
    }

    /* ========== PAIR LOOKUP TESTS ========== */

    function testGetPairReturnsZeroForNonexistentPair() public view {
        address pair = factory.getPair(address(tokenA), address(tokenB));
        assertEq(pair, address(0), "Should return zero for nonexistent pair");
    }

    function testAllPairsLengthIncrements() public {
        assertEq(factory.allPairsLength(), 0);
        
        factory.createPair(address(tokenA), address(tokenB));
        assertEq(factory.allPairsLength(), 1);
        
        factory.createPair(address(tokenA), address(tokenC));
        assertEq(factory.allPairsLength(), 2);
    }

    function testAllPairsArray() public {
        address pair1 = factory.createPair(address(tokenA), address(tokenB));
        address pair2 = factory.createPair(address(tokenA), address(tokenC));
        address pair3 = factory.createPair(address(tokenB), address(tokenC));
        
        assertEq(factory.allPairs(0), pair1, "First pair should match");
        assertEq(factory.allPairs(1), pair2, "Second pair should match");
        assertEq(factory.allPairs(2), pair3, "Third pair should match");
    }

    /* ========== PAIR ADDRESS COMPUTATION TESTS ========== */

    function testPairForComputesCorrectAddress() public {
        // Create pair
        address actualPair = factory.createPair(address(tokenA), address(tokenB));
        
        // Compute expected address
        address computedPair = factory.pairFor(address(tokenA), address(tokenB));
        
        assertEq(actualPair, computedPair, "Computed address should match actual");
    }

    function testPairForWorksBeforeCreation() public view {
        // Should be able to compute address before pair is created
        address computedPair = factory.pairFor(address(tokenA), address(tokenB));
        assertNotEq(computedPair, address(0), "Should compute non-zero address");
    }

    function testPairForReverseOrder() public view {
        // Should return same address regardless of token order
        address pair1 = factory.pairFor(address(tokenA), address(tokenB));
        address pair2 = factory.pairFor(address(tokenB), address(tokenA));
        
        assertEq(pair1, pair2, "Should compute same address for reverse order");
    }

    /* ========== FUZZ TESTS ========== */

    function testFuzzCreatePair(address token0, address token1) public {
        // Assumptions for valid test cases
        vm.assume(token0 != address(0));
        vm.assume(token1 != address(0));
        vm.assume(token0 != token1);
        vm.assume(token0.code.length == 0); // Not a contract (for this test)
        vm.assume(token1.code.length == 0);
        
        // Create pair should not revert
        address pair = factory.createPair(token0, token1);
        
        assertNotEq(pair, address(0), "Pair should be created");
        assertEq(factory.allPairsLength(), 1, "Should have 1 pair");
    }

    function testFuzzSetFeeTo(address newFeeTo) public {
        // Should accept any address including zero
        factory.setFeeTo(newFeeTo);
        assertEq(factory.feeTo(), newFeeTo, "feeTo should be set");
    }

    /* ========== GAS BENCHMARKING ========== */

    function testGasCreateFirstPair() public {
        uint256 gasBefore = gasleft();
        factory.createPair(address(tokenA), address(tokenB));
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Gas used for first pair creation:", gasUsed);
        // Typical: ~3-4M gas for first pair (includes pair contract deployment)
    }

    function testGasCreateAdditionalPair() public {
        // Create first pair
        factory.createPair(address(tokenA), address(tokenB));
        
        // Measure second pair
        uint256 gasBefore = gasleft();
        factory.createPair(address(tokenA), address(tokenC));
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Gas used for additional pair creation:", gasUsed);
    }

    function testGasPairLookup() public {
        factory.createPair(address(tokenA), address(tokenB));
        
        uint256 gasBefore = gasleft();
        factory.getPair(address(tokenA), address(tokenB));
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Gas used for pair lookup:", gasUsed);
        // Should be very low (single storage read)
    }
}
