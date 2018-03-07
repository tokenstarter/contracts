pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "../node_modules/zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol";
import "./OptionToken.sol";

contract OptionSale {
    using SafeMath for uint256;
    address factory;
    address startup;
    bool closed = false;
    uint256 public optionRate;
    uint256 public openingTime;
    uint256 public closingTime;
    OptionToken public option;
    ERC20 public erc20;
    address public tokenHolder;
    bool public mintable;
    bool public burnable;
    uint256 tokenRate;
    uint256 buyoutTime;
    uint256 burningTime;

	function OptionSale (
        address _startup,
        uint256 _optionRate,
        uint256 _openingTime,
        uint256 _closingTime,
        address _ercToken,
        uint256 _tokenRate,
        bool _mintable,
        bool _burnable,
        address _tokenHolder,
        uint256 _buyoutTime,
        uint256 _burningTime
        ) public
    {
        require(_closingTime > _openingTime);
        require(_buyoutTime >= _openingTime);
        require(_burningTime > _buyoutTime && _burningTime > _closingTime);

        factory = msg.sender;
        startup = _startup;
        optionRate = _optionRate;
        openingTime = _openingTime;
        closingTime = _closingTime;
        erc20 = ERC20(_ercToken);
        tokenHolder = _tokenHolder;
        mintable = _mintable;
        burnable = _burnable;
        tokenRate = _tokenRate;
        buyoutTime = _buyoutTime;
        burningTime = _burningTime;
	}

    modifier onlyFactory {
        require(msg.sender == factory);
        _;
    }

    modifier onlyStartup {
        require(msg.sender == startup);
        _;
    }

    modifier onlyWhileOpen {
        require(address(option) != 0x0 && !closed && now >= openingTime && now <= closingTime);
        _;
    }

    function open(string name, string symbol, uint8 decimals) public onlyFactory {
        require(address(option) == 0x0);
        option = new OptionToken(name, symbol, decimals, address(erc20), tokenRate, buyoutTime, burningTime);
    }

    function () public payable onlyWhileOpen {
        uint optionCount = msg.value.mul(optionRate);

        if (mintable) {
            MintableToken t = MintableToken(address(erc20));
            t.mint(option, optionCount);

        } else if (tokenHolder != address(0)) {
            require(erc20.allowance(tokenHolder, this) >= optionCount);
            erc20.transferFrom(tokenHolder, option, optionCount);

        } else {
            require(erc20.balanceOf(this) >= optionCount);
            erc20.transfer(option, optionCount);
            
        }

        option.mint(msg.sender, optionCount);
    }

    function close() public onlyStartup {
        if (!mintable && tokenHolder == 0x0) {
            if (burnable) {
                BurnableToken t = BurnableToken(address(erc20));
                t.burn(erc20.balanceOf(this));
            } else {
                erc20.transfer(startup, erc20.balanceOf(this));
            }
        }
        closed = true;
    }
}
