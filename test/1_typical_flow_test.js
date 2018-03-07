const ERC20 = artifacts.require("just4tests/ERCToken");
const OptionToken = artifacts.require("OptionToken");
const OptionSale = artifacts.require('OptionSale');
const OptionFactory = artifacts.require('OptionFactory');
const OptionHub = artifacts.require('OptionHub');

const optionRate = 100;
const ercRate = 10;

contract('Typical flow test', async (accounts) => {

    let ercToken, factory, optionSale, optionToken, tokenstarter, tokenstarterAdmin, startup, startupBalance, investor;
  
    before(async () => {
        ercToken = await ERC20.deployed();
        factory  = await OptionFactory.deployed();
        hub      = await OptionHub.deployed();

        tokenstarter      = accounts[0];
        tokenstarterAdmin = accounts[1];
        startup           = accounts[2];
        investor          = accounts[3];
    });

    it('Configuring optionHub', async () => {
        await hub.setAdmin(tokenstarterAdmin, {from: tokenstarter});
        await hub.setFactory(factory.address, {from: tokenstarterAdmin});
    });

    it('Startup is creating new option smart-contract', async () => {
        // current timestamp
        const _now = web3.eth.getBlock(web3.eth.blockNumber).timestamp;

        // option configuration
        let params = [
            optionRate,       // Option's rate
            _now,              // Opening time
            _now + 100000,     // Closing time
            //'SimpleTokenOption', // Option token name
            //'SIM',             // Option token symbol
            //18,                // Decimals
            ercToken.address,  // Address of startup's ERC20 token
            ercRate,          // ERC20 token's rate
            false,             // No minting to reserve ERC-token
            false,             // ERC-token is not burnable
            0x0,               // No tokenHolder address
            _now,              // Option buyout time
            _now + 200000      // Option burning time
        ];

        // Call to receive option sale contract address
        let saleAddr = await factory.newOptionSale.call(...params, {from: startup});
        // Make transaction
        await factory.newOptionSale(...params, {from: startup});
        // Open selling
        await factory.open(saleAddr, 'SimpleTokenOption', 'SIM', 18, {from: tokenstarter});

        optionSale = await OptionSale.at(saleAddr);
        optionToken = await OptionToken.at(await optionSale.option());
    });

    it('Checking option contract address in OptionHub', async () => {
        let value = await hub.options(0);
        assert.equal(value.toString(), optionSale.address);
    });

    it('Startup transfered (minted) 500 erc-token to option sale contract', async () => {
        await ercToken.mint(optionSale.address, 500, {from: startup});

        let value = await ercToken.balanceOf(optionSale.address);
        assert.equal(value.toNumber(), 500);
    });


    it('Investor bought 100 options', async () => {
        await optionSale.sendTransaction({from: investor, value: 1});

        let value = await optionToken.balanceOf(investor);
        assert.equal(value.toNumber(), 100);
    });

    it('On balance of the option should be 100 erc-tokens', async () => {
        let value = await ercToken.balanceOf(optionToken.address);
        assert.equal(value.toNumber(), 100);
    });

    it('Investor buys out 50 options and gets 50 erc-tokens', async () => {
        await optionToken.sendTransaction({from: investor, value: 5});

        let value = await ercToken.balanceOf(investor);
        assert.equal(value.toNumber(), 50);
    });

    it('He also keep 50 options', async () => {
        let value = await optionToken.balanceOf(investor);
        assert.equal(value.toNumber(), 50);
    });
});
