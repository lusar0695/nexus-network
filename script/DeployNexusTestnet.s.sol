// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {NexusPayEscrow} from "../contracts/NexusPayEscrow.sol";
import {MockUSDC} from "../contracts/MockUSDC.sol";

/// @notice Testnet-only convenience deployment. MockUSDC has no real value.
contract DeployNexusTestnet is Script {
    function run() external returns (MockUSDC mockToken, NexusPayEscrow escrow) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address arbitrator = vm.envAddress("ARBITRATOR_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);
        mockToken = new MockUSDC();
        escrow = new NexusPayEscrow(arbitrator);
        vm.stopBroadcast();
    }
}
