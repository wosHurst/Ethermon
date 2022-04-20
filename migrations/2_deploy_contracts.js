const Ethermon = artifacts.require("Ethermon");

module.exports = function(deployer){
    deployer.deploy(Ethermon);
};