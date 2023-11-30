//SPDX-License-Identifier; Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    mapping(address => mapping(address => uint256)) public tokens;
    mapping(uint256 => _Order) public orders;
    uint256 public orderCount;


    event Deposit(
        address token,
        address user,
        uint256 amount,
        uint256 balance
        );
    event Withdraw(
        address token,
        address user,
        uint256 amount,
        uint256 balance
        );
    event Order (
        uint256 id, 
        address user, 
        address tokenGet, 
        uint256 amountGet,
        address tokenGive, 
        uint256 amountGive, 
        uint256 timestamp 
    );

    struct _Order {
        // Attributes of an order
        uint256 id; // unique identifier for order
        address user; // user who made order
        address tokenGet; // address of token they receive
        uint256 amountGet; // amount they receive
        address tokenGive; // address of token they give
        uint256 amountGive; //amount they give
        uint256 timestamp; // when order was created
    }

    constructor(address _feeAccount, uint256 _feePercent) {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    // Deposit AND withdraw token
    function depositToken(address _token, uint256 _amount) public {
        // Transfer tokens to exchange
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));

        // update balance 
        tokens[_token][msg.sender] = tokens[_token][msg.sender] + _amount;

        // emit an event
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function withdrawToken(address _token, uint256 _amount) public {
        //ensure userr has enough tokens to withdraw
        require(tokens[_token][msg.sender] >= _amount);

        // transfer tokens to user
        Token(_token).transfer(msg.sender, _amount);

        // update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount;

        //emit an evnt
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function balanceOf(address _token, address _user) 
        public
        view
        returns (uint256)
    {
        return tokens[_token][_user];
    }


    // -----------------
    // MAKE AND CANCEL ORDERS

    //Token give (token they want to spend) - which token and how much?
    //Token get (token they want to receive)
    function makeOrder(
    address _tokenGet,
    uint256 _amountGet,
    address _tokenGive,
    uint256 _amountGive
    ) public {
        // require orders
        require(balanceOf(_tokenGive, msg.sender) >= _amountGive);

        orderCount = orderCount + 1;
        orders[orderCount] = _Order(
            orderCount, // id
            msg.sender, // user '0x0...abc123'
            _tokenGet, // tokenGet
            _amountGet, // amountGet
            _tokenGive, // tokenGive
            _amountGive, // amountGive
            block.timestamp // timestamp 
        );

        //emit event
        emit Order(
            orderCount,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            block.timestamp
        );
    }


}

