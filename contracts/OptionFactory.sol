pragma solidity ^0.4.18;

import "./OptionSale.sol";
import "./OptionHub.sol";

contract OptionFactory {
    address admin;
    OptionHub hub;

    function OptionFactory(address _hub) public {
        admin = msg.sender;
        hub = OptionHub(_hub);
    }

    function newOptionSale (
        uint256 optionRate,
        uint256 openingTime,
        uint256 closingTime,
        address ercToken,
        uint256 tokenRate,
        bool mintable,
        bool burnable,
        address tokenHolder,
        uint256 buyoutTime,
        uint256 burningTime
        ) public returns(address)
    {
        OptionSale sale = new OptionSale(
            msg.sender,
            optionRate,
            openingTime,
            closingTime,
            ercToken,
            tokenRate,
            mintable,
            burnable,
            tokenHolder,
            buyoutTime,
            burningTime
        );
        return address(sale);
    }
    
    function open(address sale, string name, string symbol, uint8 decimals) public {
        require(msg.sender == admin);
        OptionSale s = OptionSale(sale);
        s.open(name, symbol, decimals);
        hub.addOption(sale);
    }
}