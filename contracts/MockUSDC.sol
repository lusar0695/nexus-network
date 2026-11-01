// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Test-only mock token. Never deploy this as a real stablecoin.
contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USD Coin", "mUSDC") { _mint(msg.sender, 1_000_000 * 10 ** decimals()); }
    function decimals() public pure override returns (uint8) { return 6; }
}
