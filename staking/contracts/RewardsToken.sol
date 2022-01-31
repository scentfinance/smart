
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardsToken is ERC20 {
    uint8 public constant _decimals = 18;
    uint256 public initialSupply = 10000000000 * (10**uint256(_decimals));

    constructor() public ERC20("Reward Token", "RTN") {
        _mint(msg.sender, initialSupply);
    }
}