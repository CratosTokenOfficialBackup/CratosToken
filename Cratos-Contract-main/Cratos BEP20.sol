pragma solidity ^0.4.26;

library SafeMath {
    
/**
 * @dev Multiplies two unsigned integers, reverts on overflow.
 */
 
function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

if (_a == 0) {
return 0;
}

uint256 c = _a * _b;
 require(c / _a == _b, "SafeMath: multiplication overflow");
return c;
}

/**
 * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
 */
 
function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
// Solidity only automatically asserts when dividing by 0
 require(_b > 0, "SafeMath: division by zero");
uint256 c = _a / _b;
 // assert(a == b * c + a % b); // There is no case in which this doesn't hold
return c;

}

/**
 * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
 */
     
function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

require(_b <= _a, "SafeMath: subtraction overflow");
return _a - _b;
}

/**
 * @dev Adds two unsigned integers, reverts on overflow.
 */
 
function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

uint256 c = _a + _b;
require(c >= _a, "SafeMath: addition overflow");
return c;

}

/**
  * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
   */
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
}
}

/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
*/

contract Ownable {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


constructor() public {
owner = msg.sender;
newOwner = address(0);
}

// allows execution by the owner only

modifier onlyOwner() {
require(msg.sender == owner, "Ownable: caller is not the owner");
_;
}

modifier onlyNewOwner() {
require(msg.sender != address(0), "Ownable: zero address");
require(msg.sender == newOwner, "Ownable: caller is not new owner");
_;
}

/**
    @dev allows transferring the contract ownership
    the new owner still needs to accept the transfer
    can only be called by the contract owner
    @param _newOwner    new contract owner
*/

function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0));
newOwner = _newOwner;
}

/**
    @dev used by a new owner to accept an ownership transfer
*/

function acceptOwnership() public onlyNewOwner {
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}

/*
    BEP20 Token interface
*/

contract BEP20 {

function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function allowance(address owner, address spender) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);

event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
}

interface TokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract Cratos_BEP20 is BEP20, Ownable {
using SafeMath for uint256;

string public name;
string public symbol;
uint8 public decimals;
uint256 internal totalSupply_;
mapping(address => uint256) internal balances;
mapping(address => mapping(address => uint256)) internal allowed;

event Mint(address indexed owner, uint256 value);
event Burn(address indexed owner, uint256 value);

constructor() public {
name = "Cratos BEP20";
symbol = "CRTS";
decimals = 18;
totalSupply_ = 36e26;
balances[owner] = totalSupply_;
emit Transfer(address(0), owner, totalSupply_);
}

function () public payable {
revert();
}

/**
  * @dev Total number of tokens in existence
  */
   
function totalSupply() public view returns (uint256) {
return totalSupply_;
}

/**
 * @dev Transfer token for a specified addresses
 * @param _from The address to transfer from.
 * @param _to The address to transfer to.
 * @param _value The amount to be transferred.
 */ 

function _transfer(address _from, address _to, uint _value) internal {

require(_to != address(0), "Transfer to the zero address");
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
}

/**
 * @dev Transfer token for a specified address
 * @param _to The address to transfer to.
 * @param _value The amount to be transferred.
 */
     
 
function transfer(address _to, uint256 _value) public returns (bool) {

require(_to != address(0), "Transfer to the zero address");
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}

/**
 * @dev Gets the balance of the specified address.
 * @param _holder The address to query the balance of.
 * @return An uint256 representing the amount owned by the passed address.
 */
 
function balanceOf(address _holder) public view returns (uint256 balance) {
return balances[_holder];
}

/**
 * @dev Transfer tokens from one address to another.
 * Note that while this function emits an Approval event, this is not required as per the specification,
 * and other compliant implementations may not emit the event.
 * @param _from address The address which you want to send tokens from
 * @param _to address The address which you want to transfer to
 * @param _value uint256 the amount of tokens to be transferred
 */
     
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
_transfer(_from, _to, _value);
return true;
}

/**
 * @dev Approve the passed address to _spender the specified amount of tokens on behalf of msg.sender.
 * Beware that changing an allowance with this method brings the risk that someone may use both the old
 * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
 * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
 * @param _spender The address which will spend the funds.
 * @param _value The amount of tokens to be spent.
 */ 

function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}

/**
 * @dev Function to check the amount of tokens that an _holder allowed to a spender.
 * @param _holder address The address which owns the funds.
 * @param _spender address The address which will spend the funds.
 * @return A uint256 specifying the amount of tokens still available for the spender.
*/
     
function allowance(address _holder, address _spender) public view returns (uint256) {
return allowed[_holder][_spender];

}

/**
  * Token Mint.
 */

function mint(uint256 _value) public onlyOwner returns (bool) {
    
require(_value <= balances[msg.sender]);
address minter = msg.sender;
balances[minter] = balances[minter].add(_value);
totalSupply_ = totalSupply_.add(_value);
emit Mint(minter, _value);

return true;
}

/**
  * Token Burn.
 */

function burn(uint256 _value) public onlyOwner returns (bool) {
    
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(burner, _value);

return true;
}
 

}
