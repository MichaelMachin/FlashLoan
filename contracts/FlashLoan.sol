// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract FlashLoan is ReentrancyGuard {

    using SafeMath for uint256;

    Token public token;
    uint256 public poolBalance;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    function depositTokens(uint256 _amount) external nonReentrant{
        require(_amount > 0, "Must deposit at least one token");
        token.transferFrom(msg.sender, address(this), _amount);
        poolBalance = poolBalance.add(_amount);
    }

    function flashLoan(uint256 _borrowAmount) external nonReentrant{
        //check the amount is greater than zero
        require(_borrowAmount > 0, "Must borrow at least 1 token");

        //check that this contract has enough tokens to fulfil the loan
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= _borrowAmount, "Not enough tokens in pool");

        //check that this value is equal to the pool balance value
        assert(poolBalance == balanceBefore);

        //send tokens to receiver
        token.transfer(msg.sender, _borrowAmount);

        //use loan and get paid back
        IReceiver(msg.sender).receiveTokens(address(token), _borrowAmount);

        //check that the loan has been paid back
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }


}