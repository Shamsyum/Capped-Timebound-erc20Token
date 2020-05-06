pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";

contract MyToken is IERC20{
    using SafeMath for uint256;
    mapping (address => uint)balances;
    mapping (address => mapping(address => uint)) allowances;
    mapping(address => uint)boundedTimeLimit;
    
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;
    uint256 private _totalSupply;
    uint256 private cap;
    
    constructor() public{
        name = "My Token";
        symbol  = "MTC";
        decimals = 8;
        owner = msg.sender;
        _totalSupply = 1000 * 10**uint256(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(this),owner, _totalSupply);
        cap = 1500 * 10 ** uint256(decimals);
    }
    
    modifier OnlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function totalSupply() external override view returns (uint256){
        return _totalSupply;
    }
    
    function balanceOf(address account) external override view returns (uint256){
        return balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external  override returns (bool){
        address sender = msg.sender;
        require(now > boundedTimeLimit[recipient], "The recipient is Under 30 days restriction");
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(balances[sender] > amount, "Transfer amount exceeds balance");
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) external override view returns (uint256){
        return allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) external  override returns (bool){
        address sender = msg.sender;
        require(sender != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero adddress");
        require(balances[sender] >= amount, "Not enough balance");
        allowances[sender][spender] = allowances[sender][spender].add(amount);
        emit Approval(sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external  override returns (bool){
        address _sender = msg.sender;
        require(now > boundedTimeLimit[recipient], "The recipient is Under 30 days restriction");
        require(allowances[sender][_sender] >= amount, "Not enough allowed");
        require(balances[sender] >= amount, "Not enough balance");
        require(recipient != address(0), "Transfer to zero address");
        balances[sender] = balances[sender].sub(amount);
        allowances[sender][_sender] = allowances[sender][_sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender,recipient, amount);
        return true;
    }
    
    
    function mint(address account, uint256 amount) public OnlyOwner returns(uint256){
        require(amount > 0, "MTC: Amount should be greater than 0");
        require(account != address(0), "My Token: Mint to the zero address");
        require(_totalSupply.add(amount) <= cap, "Total supply exceeds total capped");
        balances[account] = balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    function lockFor30Days(address account) public OnlyOwner returns(bool){
        boundedTimeLimit[account] = block.timestamp + 30 days;
        return true;
    }
    
}