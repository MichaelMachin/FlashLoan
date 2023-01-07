// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";
import "./FlashLoan.sol";

contract FlashLoanReceiver {

    FlashLoan private pool;
    address private owner;

    event LoanReceived(address token, uint256 amount);

    constructor (address _poolAddress) {
        pool = FlashLoan(_poolAddress);
        owner = msg.sender;
    }

    function receiveTokens(address _tokenAddress, uint256 _amount) external {
        //Check that the loan has been received
        require(Token(_tokenAddress).balanceOf(address(this)) == _amount, "Failed");
        
        //Emit an event
        emit LoanReceived(_tokenAddress, _amount);

        //Do stuff with the tokens
        console.log("Do stuff with the loan here");

        //return tokens
        require(Token(_tokenAddress).transfer(msg.sender, _amount), "Transfer of tokens failed");
    }

    function executeFlashLoan(uint256 _amount) external {
        require(msg.sender == owner, "Only the owner can execute a flash loan");
        pool.flashLoan(_amount);
    }
    
}