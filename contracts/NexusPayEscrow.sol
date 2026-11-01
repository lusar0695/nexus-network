// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title NexusPayEscrow
/// @notice Experimental escrow for paid work between AI agents or human users.
/// @dev MVP only. The immutable arbitrator is trusted to resolve disputed jobs.
contract NexusPayEscrow is ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum Status { None, Funded, Submitted, Disputed, Released, Refunded, Resolved }

    struct Job {
        address buyer;
        address seller;
        IERC20 token;
        uint128 amount;
        uint64 workDeadline;
        uint64 reviewPeriod;
        uint64 reviewEndsAt;
        bytes32 taskHash;
        bytes32 deliveryHash;
        Status status;
    }

    address public immutable arbitrator;
    uint256 public nextJobId = 1;
    mapping(uint256 => Job) private jobs;

    event JobCreated(uint256 indexed jobId, address indexed buyer, address indexed seller, address token, uint256 amount, bytes32 taskHash, uint64 workDeadline);
    event WorkSubmitted(uint256 indexed jobId, bytes32 deliveryHash, uint64 reviewEndsAt);
    event DisputeRaised(uint256 indexed jobId, address indexed raisedBy);
    event PaymentReleased(uint256 indexed jobId, address indexed seller, uint256 amount);
    event BuyerRefunded(uint256 indexed jobId, address indexed buyer, uint256 amount);
    event DisputeResolved(uint256 indexed jobId, uint256 buyerAmount, uint256 sellerAmount);

    error InvalidAddress();
    error InvalidAmount();
    error InvalidDeadline();
    error InvalidHash();
    error InvalidState();
    error Unauthorized();
    error ReviewPeriodNotOver();
    error AmountMismatch();

    constructor(address arbitrator_) {
        if (arbitrator_ == address(0)) revert InvalidAddress();
        arbitrator = arbitrator_;
    }

    function createJob(address seller, IERC20 token, uint128 amount, uint64 workDeadline, uint64 reviewPeriod, bytes32 taskHash)
        external nonReentrant returns (uint256 jobId)
    {
        if (seller == address(0) || address(token) == address(0) || seller == msg.sender) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();
        if (workDeadline <= block.timestamp || reviewPeriod == 0) revert InvalidDeadline();
        if (taskHash == bytes32(0)) revert InvalidHash();

        jobId = nextJobId++;
        jobs[jobId] = Job(msg.sender, seller, token, amount, workDeadline, reviewPeriod, 0, taskHash, bytes32(0), Status.Funded);

        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        if (token.balanceOf(address(this)) - balanceBefore != amount) revert AmountMismatch();

        emit JobCreated(jobId, msg.sender, seller, address(token), amount, taskHash, workDeadline);
    }

    function submitWork(uint256 jobId, bytes32 deliveryHash) external {
        Job storage job = jobs[jobId];
        if (msg.sender != job.seller) revert Unauthorized();
        if (job.status != Status.Funded) revert InvalidState();
        if (block.timestamp > job.workDeadline) revert InvalidDeadline();
        if (deliveryHash == bytes32(0)) revert InvalidHash();

        job.deliveryHash = deliveryHash;
        job.reviewEndsAt = uint64(block.timestamp) + job.reviewPeriod;
        job.status = Status.Submitted;
        emit WorkSubmitted(jobId, deliveryHash, job.reviewEndsAt);
    }

    function approveAndPay(uint256 jobId) external nonReentrant {
        Job storage job = jobs[jobId];
        if (msg.sender != job.buyer) revert Unauthorized();
        if (job.status != Status.Submitted) revert InvalidState();
        _release(jobId, job);
    }

    function claimAfterReview(uint256 jobId) external nonReentrant {
        Job storage job = jobs[jobId];
        if (job.status != Status.Submitted) revert InvalidState();
        if (block.timestamp <= job.reviewEndsAt) revert ReviewPeriodNotOver();
        _release(jobId, job);
    }

    function refundExpired(uint256 jobId) external nonReentrant {
        Job storage job = jobs[jobId];
        if (msg.sender != job.buyer) revert Unauthorized();
        if (job.status != Status.Funded || block.timestamp <= job.workDeadline) revert InvalidState();
        job.status = Status.Refunded;
        job.token.safeTransfer(job.buyer, job.amount);
        emit BuyerRefunded(jobId, job.buyer, job.amount);
    }

    function raiseDispute(uint256 jobId) external {
        Job storage job = jobs[jobId];
        if (msg.sender != job.buyer && msg.sender != job.seller) revert Unauthorized();
        if (job.status != Status.Submitted || block.timestamp > job.reviewEndsAt) revert InvalidState();
        job.status = Status.Disputed;
        emit DisputeRaised(jobId, msg.sender);
    }

    function resolveDispute(uint256 jobId, uint128 buyerAmount, uint128 sellerAmount) external nonReentrant {
        if (msg.sender != arbitrator) revert Unauthorized();
        Job storage job = jobs[jobId];
        if (job.status != Status.Disputed) revert InvalidState();
        if (uint256(buyerAmount) + uint256(sellerAmount) != job.amount) revert AmountMismatch();
        job.status = Status.Resolved;
        if (buyerAmount > 0) job.token.safeTransfer(job.buyer, buyerAmount);
        if (sellerAmount > 0) job.token.safeTransfer(job.seller, sellerAmount);
        emit DisputeResolved(jobId, buyerAmount, sellerAmount);
    }

    function getJob(uint256 jobId) external view returns (Job memory) { return jobs[jobId]; }

    function _release(uint256 jobId, Job storage job) private {
        job.status = Status.Released;
        job.token.safeTransfer(job.seller, job.amount);
        emit PaymentReleased(jobId, job.seller, job.amount);
    }
}
