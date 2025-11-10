// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./libraries/Math.sol";
import "./libraries/UQ112x112.sol";

/**
 * @title DEXPair
 * @notice Liquidity pool pair implementing constant product AMM (x * y = k)
 * @dev ERC20 LP token representing liquidity shares in the pool
 */
contract DEXPair is ERC20, ReentrancyGuard {
    using UQ112x112 for uint224;

    /// @notice Minimum liquidity locked forever in the pool
    /// @dev First 1000 LP tokens are burned to prevent inflation attacks
    uint256 public constant MINIMUM_LIQUIDITY = 1000;
    
    /// @notice Selector for token transfer function
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    /// @notice Address of the factory that created this pair
    address public factory;
    
    /// @notice Address of token0 (ordered)
    address public token0;
    
    /// @notice Address of token1 (ordered)
    address public token1;

    /// @notice Reserve of token0
    uint112 private reserve0;
    
    /// @notice Reserve of token1
    uint112 private reserve1;
    
    /// @notice Timestamp of last reserve update
    uint32 private blockTimestampLast;

    /// @notice Cumulative price of token0 (for TWAP oracle)
    uint256 public price0CumulativeLast;
    
    /// @notice Cumulative price of token1 (for TWAP oracle)
    uint256 public price1CumulativeLast;
    
    /// @notice Product of reserves at last fee collection (k)
    uint256 public kLast;

    /// @notice Emitted on each swap
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    /// @notice Emitted when liquidity is added
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    /// @notice Emitted when liquidity is removed
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

    /// @notice Emitted when reserves are synced
    event Sync(uint112 reserve0, uint112 reserve1);

    error Locked();
    error Overflow();
    error InsufficientLiquidity();
    error InsufficientLiquidityMinted();
    error InsufficientLiquidityBurned();
    error InsufficientOutputAmount();
    error InsufficientInputAmount();
    error InvalidTo();
    error InsufficientAmount();
    error K();
    error AlreadyInitialized();
    error Unauthorized();

    /**
     * @notice Initializes the ERC20 LP token
     */
    constructor() ERC20("DEX LP Token", "DEX-LP") {
        factory = msg.sender;
    }

    /**
     * @notice Initializes the pair with token addresses
     * @dev Called once by the factory at time of deployment
     * @param _token0 Address of token0
     * @param _token1 Address of token1
     */
    function initialize(address _token0, address _token1) external {
        if (msg.sender != factory) revert Unauthorized();
        if (token0 != address(0)) revert AlreadyInitialized();
        token0 = _token0;
        token1 = _token1;
    }

    /**
     * @notice Returns current reserves and last block timestamp
     * @return _reserve0 Reserve of token0
     * @return _reserve1 Reserve of token1
     * @return _blockTimestampLast Timestamp of last update
     */
    function getReserves() public view returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 _blockTimestampLast
    ) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    /**
     * @notice Safely transfers tokens
     * @param token Token address
     * @param to Recipient address
     * @param value Amount to transfer
     */
    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'DEXPair: TRANSFER_FAILED');
    }

    /**
     * @notice Updates reserves and cumulative prices
     * @dev Called on every liquidity change
     * @param balance0 Current balance of token0
     * @param balance1 Current balance of token1
     * @param _reserve0 Previous reserve of token0
     * @param _reserve1 Previous reserve of token1
     */
    function _update(uint256 balance0, uint256 balance1, uint112 _reserve0, uint112 _reserve1) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) revert Overflow();
        
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;
        
        // Update price accumulators
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // Overflow is desired here for accumulator
            unchecked {
                price0CumulativeLast += uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
                price1CumulativeLast += uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
            }
        }
        
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        
        emit Sync(reserve0, reserve1);
    }

    /**
     * @notice Mints protocol fee if enabled
     * @param _reserve0 Reserve of token0
     * @param _reserve1 Reserve of token1
     * @return feeOn Whether fee is enabled
     */
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IDEXFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast;
        
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0) * uint256(_reserve1));
                uint256 rootKLast = Math.sqrt(_kLast);
                
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * (rootK - rootKLast);
                    uint256 denominator = rootK * 5 + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    /**
     * @notice Mints LP tokens to liquidity provider
     * @dev Should be called after transferring tokens to the pair
     * @param to Address to receive LP tokens
     * @return liquidity Amount of LP tokens minted
     */
    function mint(address to) external nonReentrant returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply();
        
        if (_totalSupply == 0) {
            // First liquidity provider
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // Lock minimum liquidity forever
        } else {
            // Subsequent liquidity additions
            liquidity = Math.min(
                (amount0 * _totalSupply) / _reserve0,
                (amount1 * _totalSupply) / _reserve1
            );
        }
        
        if (liquidity == 0) revert InsufficientLiquidityMinted();
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * uint256(reserve1);
        
        emit Mint(msg.sender, amount0, amount1);
    }

    /**
     * @notice Burns LP tokens and returns underlying tokens
     * @param to Address to receive underlying tokens
     * @return amount0 Amount of token0 returned
     * @return amount1 Amount of token1 returned
     */
    function burn(address to) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        address _token0 = token0;
        address _token1 = token1;
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply();
        
        // Calculate proportional amounts
        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;
        
        if (amount0 == 0 || amount1 == 0) revert InsufficientLiquidityBurned();
        
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * uint256(reserve1);
        
        emit Burn(msg.sender, amount0, amount1, to);
    }

    /**
     * @notice Swaps tokens using constant product formula
     * @dev Requires tokens to be sent to pair before calling
     * @param amount0Out Amount of token0 to receive
     * @param amount1Out Amount of token1 to receive
     * @param to Address to receive output tokens
     * @param data Callback data for flash swaps (not implemented yet)
     */
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external nonReentrant {
        if (amount0Out == 0 && amount1Out == 0) revert InsufficientOutputAmount();
        
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
        if (amount0Out >= _reserve0 || amount1Out >= _reserve1) revert InsufficientLiquidity();

        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = token0;
            address _token1 = token1;
            if (to == _token0 || to == _token1) revert InvalidTo();
            
            // Transfer output tokens
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out);
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out);
            
            // Flash swap callback (if data provided)
            if (data.length > 0) {
                IDEXCallee(to).dexCall(msg.sender, amount0Out, amount1Out, data);
            }
            
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        
        // Calculate input amounts
        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        if (amount0In == 0 && amount1In == 0) revert InsufficientInputAmount();
        
        {
            // Verify constant product with 0.3% fee
            uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
            if (balance0Adjusted * balance1Adjusted < uint256(_reserve0) * uint256(_reserve1) * (1000**2)) {
                revert K();
            }
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    /**
     * @notice Forces reserves to match current token balances
     * @dev Useful for recovering from token transfer errors
     */
    function sync() external nonReentrant {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }

    /**
     * @notice Forces balances to match reserves
     * @dev Emergency function to recover stuck tokens
     * @param to Address to receive excess tokens
     */
    function skim(address to) external nonReentrant {
        address _token0 = token0;
        address _token1 = token1;
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)) - reserve0);
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - reserve1);
    }
}

/**
 * @notice Interface for factory fee configuration
 */
interface IDEXFactory {
    function feeTo() external view returns (address);
}

/**
 * @notice Interface for flash swap callback
 */
interface IDEXCallee {
    function dexCall(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external;
}
