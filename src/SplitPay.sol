// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract SplitPay {
    using SafeERC20 for IERC20;

    IERC20 public immutable IDRX;

    struct Split {
        address recipient;
        uint256 totalExpected;
        uint256 totalReceived;
        bool completed;
    }

    mapping(uint256 => Split) public splits;

    event SplitCreated(
        uint256 indexed splitId,
        address recipient,
        uint256 totalExpected
    );
    event PaymentReceived(
        uint256 indexed splitId,
        address payer,
        uint256 amount
    );
    event PaymentCompleted(
        uint256 indexed splitId,
        address recipient,
        uint256 totalAmount
    );

    error SplitAlreadyExists();
    error SplitCompleted();
    error InvalidAmount();
    error TransferFailed();

    constructor(address _idrx) {
        IDRX = IERC20(_idrx);
    }

    function createSplit(
        uint256 splitId,
        address recipient,
        uint256 totalExpected
    ) external {
        if (splits[splitId].recipient != address(0))
            revert SplitAlreadyExists();
        if (totalExpected == 0) revert InvalidAmount();
        if (recipient == address(0)) revert InvalidAmount();

        splits[splitId] = Split({
            recipient: recipient,
            totalExpected: totalExpected,
            totalReceived: 0,
            completed: false
        });

        emit SplitCreated(splitId, recipient, totalExpected);
    }

    function pay(
        uint256 splitId,
        uint256 amount,
        address recipient,
        uint256 totalExpected
    ) external {
        Split storage split = splits[splitId];

        if (split.recipient == address(0)) {
            // Lazy create
            if (recipient == address(0) || totalExpected == 0)
                revert InvalidAmount();
            split.recipient = recipient;
            split.totalExpected = totalExpected;
            emit SplitCreated(splitId, recipient, totalExpected);
        } else {
            // Validate matches existing
            // Optional: require(split.recipient == recipient, "Mismatch");
        }

        if (split.completed) revert SplitCompleted();
        if (amount == 0) revert InvalidAmount();

        // user must have approved this contract to spend 'amount' of IDRX
        IDRX.safeTransferFrom(msg.sender, address(this), amount);

        split.totalReceived += amount;
        emit PaymentReceived(splitId, msg.sender, amount);

        if (split.totalReceived >= split.totalExpected) {
            split.completed = true;
            IDRX.safeTransfer(split.recipient, split.totalReceived);
            emit PaymentCompleted(
                splitId,
                split.recipient,
                split.totalReceived
            );
        }
    }

    function getSplit(uint256 splitId) external view returns (Split memory) {
        return splits[splitId];
    }
}
