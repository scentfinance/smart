
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {
    uint8 public constant _decimals = 18;
    uint256 public initialStakingTokenSupply = 10000000000 * (10**uint256(_decimals));

    constructor() public ERC20("Staking Token", "STN") {
        _mint(msg.sender, initialStakingTokenSupply);
    }
}