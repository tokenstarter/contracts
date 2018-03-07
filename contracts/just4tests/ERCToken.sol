pragma solidity ^0.4.18;

import "../../node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

contract ERCToken is MintableToken {
  string public constant name = "SimpleToken";
  string public constant symbol = "SIM";
  uint8 public constant decimals = 18;
}
