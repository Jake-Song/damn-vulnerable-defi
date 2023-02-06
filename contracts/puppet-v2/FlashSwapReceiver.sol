pragma solidity =0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';

import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IWETH.sol';
import "hardhat/console.sol";

contract FlashSwapReceiver is IUniswapV2Callee {
    address immutable factory;
    address immutable lendingPool;
    IWETH immutable WETH;
    IERC20 immutable ERC20;
    address playerAddress;
    
    constructor(address _factory, address _weth, address _lendingPool, address _token, address _playerAdderss) public {
        factory = _factory;
        lendingPool = _lendingPool;
        WETH = IWETH(_weth);
        ERC20 = IERC20(_token);
        playerAddress = _playerAdderss;
    }

    receive() external payable {}

    // gets tokens/WETH via a V2 flash swap, swaps for the ETH/tokens on V1, repays V2, and keeps the rest!
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external override {
        console.log("amount1", amount1);
        (bool balanceOf, bytes memory result) = address(WETH).call(
            abi.encodeWithSignature(
                "balanceOf(address)",
                address(this)
            )
        );
        console.log("balanceOf", balanceOf);
        uint wethBal = abi.decode(result, (uint));
        console.log("wethBal", wethBal / 10 ** 18);

        (bool successSync, ) = address(sender).call(
            abi.encodeWithSignature(
                "sync()"
            )
        );
        console.log("successSync", successSync);
        
        (bool success, ) = lendingPool.call(data);
        console.log("success", success);
        ERC20.transfer(sender, ERC20.balanceOf(address(this)));
        
        WETH.transfer(msg.sender, amount1); // return WETH to V2 pair
           
       
    
    }
}