// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";

contract Custom {
    using Address for address;

    function execute (DamnValuableToken target, bytes calldata actionData) external returns (bytes memory) {
        return address(target).functionCall(actionData);

    }
}