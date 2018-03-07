pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract OptionToken is MintableToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    ERC20 public erc;
    uint256 public tokenRate;
    uint256 public buyoutTime;
    uint256 public burningTime;

	function OptionToken (
        string _name,
        string _symbol,
        uint8 _decimals,
        address _erc,
        uint256 rate,
        uint256 _buyoutTime,
        uint256 _burningTime) public
    {
        require(_buyoutTime < _burningTime);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        erc = ERC20(_erc);

        tokenRate = rate;
        buyoutTime = _buyoutTime;
        burningTime = _burningTime;
	}

    modifier onlyWhileBuyout {
        require(now >= buyoutTime && now < burningTime);
        _;
    }

    // buyouts erc-tokens when received eth
    // less or equal to the buyer's options
    function () public payable onlyWhileBuyout {
        uint tokenCount = msg.value.mul(tokenRate);
        require(balances[msg.sender] >= tokenCount);
        balances[msg.sender] = balances[msg.sender].sub(tokenCount);
        erc.transfer(msg.sender, tokenCount);
    }
}
