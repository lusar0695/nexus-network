// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {NexusPayEscrow} from "../contracts/NexusPayEscrow.sol";

contract DeployNexusPay is Script {
    function run() external returns (NexusPayEscrow escrow) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address arbitrator = vm.envAddress("ARBITRATOR_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        escrow = new NexusPayEscrow(arbitrator);
        vm.stopBroadcast();
    }
}
