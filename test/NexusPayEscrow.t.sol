// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {NexusPayEscrow} from "../contracts/NexusPayEscrow.sol";
import {MockUSDC} from "../contracts/MockUSDC.sol";

contract NexusPayEscrowTest is Test {
    NexusPayEscrow internal escrow;
    MockUSDC internal token;
    address internal buyer = address(0xB0B);
    address internal seller = address(0x515);
    address internal arbitrator = address(0xA8B);

    uint128 internal constant AMOUNT = 1_000e6;
    bytes32 internal constant TASK_HASH = keccak256("translate document");
    bytes32 internal constant DELIVERY_HASH = keccak256("translation result");

    function setUp() public {
        token = new MockUSDC();
        escrow = new NexusPayEscrow(arbitrator);
        token.transfer(buyer, 10_000e6);
        vm.prank(buyer);
        token.approve(address(escrow), type(uint256).max);
    }

    function _createJob(uint64 workDeadline, uint64 reviewPeriod) internal returns (uint256 jobId) {
        vm.prank(buyer);
        jobId = escrow.createJob(seller, token, AMOUNT, workDeadline, reviewPeriod, TASK_HASH);
    }

    function testBuyerFundsSellerSubmitsAndBuyerApproves() public {
        uint256 sellerBefore = token.balanceOf(seller);
        uint256 jobId = _createJob(uint64(block.timestamp + 1 days), 1 days);
        assertEq(token.balanceOf(address(escrow)), AMOUNT);

        vm.prank(seller);
        escrow.submitWork(jobId, DELIVERY_HASH);
        vm.prank(buyer);
        escrow.approveAndPay(jobId);

        assertEq(token.balanceOf(seller), sellerBefore + AMOUNT);
        assertEq(uint256(escrow.getJob(jobId).status), uint256(NexusPayEscrow.Status.Released));
    }

    function testBuyerCanRefundIfSellerMissesDeadline() public {
        uint64 deadline = uint64(block.timestamp + 1 days);
        uint256 jobId = _createJob(deadline, 1 days);
        vm.warp(uint256(deadline) + 1);
        uint256 buyerBefore = token.balanceOf(buyer);

        vm.prank(buyer);
        escrow.refundExpired(jobId);

        assertEq(token.balanceOf(buyer), buyerBefore + AMOUNT);
        assertEq(uint256(escrow.getJob(jobId).status), uint256(NexusPayEscrow.Status.Refunded));
    }

    function testSellerCanClaimAfterReviewPeriodIfNoDispute() public {
        uint256 jobId = _createJob(uint64(block.timestamp + 1 days), 1 days);
        vm.prank(seller);
        escrow.submitWork(jobId, DELIVERY_HASH);
        NexusPayEscrow.Job memory job = escrow.getJob(jobId);
        vm.warp(uint256(job.reviewEndsAt) + 1);

        uint256 sellerBefore = token.balanceOf(seller);
        escrow.claimAfterReview(jobId);
        assertEq(token.balanceOf(seller), sellerBefore + AMOUNT);
    }

    function testArbitratorCanSplitDisputedFunds() public {
        uint256 jobId = _createJob(uint64(block.timestamp + 1 days), 1 days);
        vm.prank(seller);
        escrow.submitWork(jobId, DELIVERY_HASH);
        vm.prank(buyer);
        escrow.raiseDispute(jobId);

        uint128 buyerShare = 400e6;
        uint128 sellerShare = 600e6;
        uint256 buyerBefore = token.balanceOf(buyer);
        uint256 sellerBefore = token.balanceOf(seller);

        vm.prank(arbitrator);
        escrow.resolveDispute(jobId, buyerShare, sellerShare);

        assertEq(token.balanceOf(buyer), buyerBefore + buyerShare);
        assertEq(token.balanceOf(seller), sellerBefore + sellerShare);
        assertEq(uint256(escrow.getJob(jobId).status), uint256(NexusPayEscrow.Status.Resolved));
    }

    function testNonArbitratorCannotResolveDispute() public {
        uint256 jobId = _createJob(uint64(block.timestamp + 1 days), 1 days);
        vm.prank(seller);
        escrow.submitWork(jobId, DELIVERY_HASH);
        vm.prank(buyer);
        escrow.raiseDispute(jobId);

        vm.expectRevert(NexusPayEscrow.Unauthorized.selector);
        vm.prank(address(0xBAD));
        escrow.resolveDispute(jobId, 0, AMOUNT);
    }
}
