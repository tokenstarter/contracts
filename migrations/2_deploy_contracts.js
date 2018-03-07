const ERC20 = artifacts.require("just4tests/ERCToken");
const OptionFactory = artifacts.require('OptionFactory');
const OptionHub = artifacts.require('OptionHub');

module.exports = (deployer, a, accounts) => {
  const tokenstarter = accounts[0];
  const tokenstarterAdmin = accounts[1];
  const startup = accounts[2];

  return deployer.deploy(ERC20, {from: startup})
  .then(() => deployer.deploy(OptionHub, {from: tokenstarter}))
  .then(() => deployer.deploy(OptionFactory, OptionHub.address, {from: tokenstarter}));
};
