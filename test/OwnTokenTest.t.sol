// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DeployOwnToken} from "../script/DeployOwnToken.s.sol";
import {OwnToken} from "../src/OwnToken.sol";

contract OwnTokenTest is Test {
    OwnToken public ownToken;
    DeployOwnToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address charlie = makeAddr("charlie");

    uint256 public constant STARTING_BAL = 100 ether;

    function setUp() public {
        deployer = new DeployOwnToken();
        ownToken = deployer.run();

        // Transfer initial balance to Bob for testing
        vm.prank(msg.sender);
        ownToken.transfer(bob, STARTING_BAL);
    }

    function testInitialSupply() public view {
        uint256 totalSupply = ownToken.totalSupply();
        assertGt(totalSupply, 0, "Total supply should be greater than zero");
    }

    function testBobBalance() public view {
        assertEq(
            ownToken.balanceOf(bob),
            STARTING_BAL,
            "Bob's balance mismatch"
        );
    }

    function testTransfer() public {
        uint256 transferAmount = 50 ether;

        vm.prank(bob);
        ownToken.transfer(alice, transferAmount);

        assertEq(
            ownToken.balanceOf(alice),
            transferAmount,
            "Alice did not receive correct amount"
        );
        assertEq(
            ownToken.balanceOf(bob),
            STARTING_BAL - transferAmount,
            "Bob's balance mismatch after transfer"
        );
    }

    function testAllowances() public {
        uint256 allowanceAmount = 200 ether;

        // Bob approves Alice to spend tokens
        vm.prank(bob);
        ownToken.approve(alice, allowanceAmount);

        assertEq(
            ownToken.allowance(bob, alice),
            allowanceAmount,
            "Allowance mismatch"
        );

        uint256 transferAmount = 100 ether;

        // Alice transfers tokens on behalf of Bob
        vm.prank(alice);
        ownToken.transferFrom(bob, alice, transferAmount);

        assertEq(
            ownToken.balanceOf(alice),
            transferAmount,
            "Alice's balance mismatch after transferFrom"
        );
        assertEq(
            ownToken.balanceOf(bob),
            STARTING_BAL - transferAmount,
            "Bob's balance mismatch after transferFrom"
        );
        assertEq(
            ownToken.allowance(bob, alice),
            allowanceAmount - transferAmount,
            "Remaining allowance mismatch"
        );
    }

    function testMinting() public {
        uint256 mintAmount = 100 ether;
        address minter = address(this);

        vm.prank(minter);
        ownToken.transfer(charlie, mintAmount);

        assertEq(
            ownToken.balanceOf(charlie),
            mintAmount,
            "Charlie's balance mismatch after minting"
        );
        assertEq(
            ownToken.totalSupply(),
            STARTING_BAL + mintAmount,
            "Total supply mismatch after minting"
        );
    }

    function testInsufficientBalance() public {
        uint256 excessiveTransferAmount = STARTING_BAL + 1 ether;

        vm.prank(bob);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        ownToken.transfer(alice, excessiveTransferAmount);
    }

    function testInsufficientAllowance() public {
        uint256 allowanceAmount = 50 ether;

        // Bob approves Alice to spend some tokens
        vm.prank(bob);
        ownToken.approve(alice, allowanceAmount);

        uint256 excessiveTransferAmount = allowanceAmount + 1 ether;

        // Alice tries to transfer more than allowed
        vm.prank(alice);
        vm.expectRevert("ERC20: insufficient allowance");
        ownToken.transferFrom(bob, alice, excessiveTransferAmount);
    }

    function testTransferWithoutAllowance() public {
        uint256 transferAmount = 10 ether;

        // Alice attempts to transfer without approval
        vm.prank(alice);
        vm.expectRevert("ERC20: insufficient allowance");
        ownToken.transferFrom(bob, alice, transferAmount);
    }
}
