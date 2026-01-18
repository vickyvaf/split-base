// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SplitPay} from "../src/SplitPay.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address idrxAddress = vm.envAddress("IDRX_ADDRESS"); // Must be set in .env

        vm.startBroadcast(deployerPrivateKey);

        new SplitPay(idrxAddress);

        vm.stopBroadcast();
    }
}
