// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1eth =10e17 
    uint256 constant STARTING_BALANCE = 10 ether;// Giving some initial eths so as to avout out of duns error for the user
    uint256 constant GAS_PRICE = 1;

    function setUp () external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal (USER, STARTING_BALANCE); //Giving some initial eths so as to avout out of duns error for the user
    }

    function testMinimumUSDisFIVE () public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsg_Sender () public view {
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testsFundUpdatesFundedDataStructure() public {
        vm.prank(USER);//the next TX will be sent by USER
        fundMe.fund{value:SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testgetFunder() public {
        vm.prank(USER);//the next TX will be sent by USER
        fundMe.fund{value:SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); 
    }

    modifier funded () {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        // vm.prank(USER);//since expectRevert used, the next line will be skipped//Not using this anymore since inclused funded modifier
        fundMe.withdrawCheaper();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange - a test - check what our balance is before and after the withdraw
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address (fundMe).balance;

         //Act - write the code to test
        vm.prank (fundMe.getOwner());
        fundMe.withdrawCheaper();

        //Assert - check the result 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address (fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunder() public funded {
        //Arange
        uint160 noOfFunders = 10;
        uint160 startingIndex = 1; // 0 for sanity checks
        for(uint160 i = startingIndex; i <= noOfFunders; i++){
            //vm.prank  \
            //vm.defaul / these 2 can be combined and hoax can be used
            //address()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        } 
        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address (fundMe).balance;
        vm.startPrank (fundMe.getOwner());//usinf start and stopPranks 
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
    function testWithdrawFromMultipleFunderCheaper() public funded {
        //Arange
        uint160 noOfFunders = 10;
        uint160 startingIndex = 1; // 0 for sanity checks
        for(uint160 i = startingIndex; i <= noOfFunders; i++){
            //vm.prank  \
            //vm.defaul / these 2 can be combined and hoax can be used
            //address()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        } 
        //Act
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address (fundMe).balance;
        vm.startPrank (fundMe.getOwner());//usinf start and stopPranks 
        fundMe.withdrawCheaper();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }
}       