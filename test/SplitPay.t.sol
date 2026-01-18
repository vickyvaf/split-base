// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SplitPay} from "../src/SplitPay.sol";
import {MockIDRX} from "./MockIDRX.sol";

contract SplitPayTest is Test {
    SplitPay public splitPay;
    MockIDRX public idrx;

    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public recipient = address(0x3);

    function setUp() public {
        idrx = new MockIDRX();
        splitPay = new SplitPay(address(idrx));

        // Fund users
        idrx.transfer(user1, 1000 * 10 ** 18);
        idrx.transfer(user2, 1000 * 10 ** 18);

        vm.prank(user1);
        idrx.approve(address(splitPay), type(uint256).max);

        vm.prank(user2);
        idrx.approve(address(splitPay), type(uint256).max);
    }

    function testCreateSplit() public {
        uint256 splitId = 123;
        uint256 total = 100 * 10 ** 18;

        splitPay.createSplit(splitId, recipient, total);

        (address r, uint256 e, uint256 received, bool c) = splitPay.splits(
            splitId
        );
        assertEq(r, recipient);
        assertEq(e, total);
        assertEq(received, 0);
        assertEq(c, false);
    }

    function testLazyPay() public {
        uint256 splitId = 999;
        uint256 total = 100 * 10 ** 18;
        uint256 payAmount = 10 * 10 ** 18;

        vm.prank(user1);
        splitPay.pay(splitId, payAmount, recipient, total);

        (address r, uint256 e, uint256 received, bool c) = splitPay.splits(
            splitId
        );
        assertEq(r, recipient);
        assertEq(e, total);
        assertEq(received, payAmount);
        assertEq(c, false);
    }

    function testPayAndForward() public {
        uint256 splitId = 1;
        uint256 total = 100 * 10 ** 18;

        splitPay.createSplit(splitId, recipient, total);

        // User 1 pays half
        vm.prank(user1);
        splitPay.pay(splitId, 50 * 10 ** 18, recipient, total);

        // Check state
        (, , uint256 received, bool c) = splitPay.splits(splitId);
        assertEq(received, 50 * 10 ** 18);
        assertEq(c, false);
        assertEq(idrx.balanceOf(recipient), 0); // Not forwarded yet

        // User 2 pays remaining half
        vm.prank(user2);
        splitPay.pay(splitId, 50 * 10 ** 18, recipient, total);

        // Check completed
        (, , received, c) = splitPay.splits(splitId);
        assertEq(received, 100 * 10 ** 18);
        assertEq(c, true);

        // Check funds forwarded
        assertEq(idrx.balanceOf(recipient), 100 * 10 ** 18);
        assertEq(idrx.balanceOf(address(splitPay)), 0);
    }
}
