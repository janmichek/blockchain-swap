pragma solidity ^0.5.0;

import "./Token.sol";

contract EthSwap {
    string public name = "EthSwap Instant Exchange";
    Token public token;
    uint public rate = 100;

    event TokenPurchased(
        address account,
        address token,
        uint amount,
        uint rate
    );

    event TokenSold(
        address account,
        address token,
        uint amount,
        uint rate
    );

    constructor(Token _token) public {
        token = _token;
    }

    function buyTokens() public payable {
        //        msg.value how much ether was send
        uint tokenAmount = msg.value * rate;

        //check available balance
        require(token.balanceOf(address(this)) >= tokenAmount);

        // msg.sender is recipient who calls this function
        // msg is global variable inside solidity
        token.transfer(msg.sender, tokenAmount);
        emit TokenPurchased(msg.sender, address(token), tokenAmount, rate);
    }

    function sellTokens(uint _amount) public {
        // user can't sell more tokens than they have
        require(token.balanceOf(msg.sender) >= _amount);

        uint etherAmount = _amount / rate;

        // check ethswap has enough ether
        require(address(this).balance >= etherAmount);

        //swap
        token.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        emit TokenSold(msg.sender, address(token), _amount, rate);


    }
}
