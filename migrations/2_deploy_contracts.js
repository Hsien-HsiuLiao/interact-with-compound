const MyDefiProject = artifacts.require("MyDefiProject");

module.exports = function (deployer, network) {
    let comptrollerAddress, priceOracleProxy;
    if (network === 'rinkeby' || network === 'rinkeby-fork') {
        comptrollerAddress = '0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb';
        priceOracleProxy = '0x5722A3F60fa4F0EC5120DCD6C386289A4758D1b2';
    }
  deployer.deploy(MyDefiProject, comptrollerAddress, priceOracleProxy);
};
