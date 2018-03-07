pragma solidity ^0.4.18;

contract OptionHub {
    address owner;
    address admin;
    address public factory;
    address[] public options;

    function OptionHub() public {
        owner = msg.sender;
    }

    function setAdmin(address _admin) public {
        require(msg.sender == owner);
        admin = _admin;
    }

    function setFactory(address _factory) public {
        require(msg.sender == admin);
        factory = _factory;
    }

    function addOption(address option) public {
        require(msg.sender == factory);
        options.push(option);
    }

    function optionsLen() public view returns(uint256) {
        return options.length;
    }
}