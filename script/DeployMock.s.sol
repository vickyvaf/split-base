// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockIDRX} from "../test/MockIDRX.sol";

contract DeployMock is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MockIDRX token = new MockIDRX();
        console.log("MockIDRX deployed at:", address(token));

        vm.stopBroadcast();
    }
}
