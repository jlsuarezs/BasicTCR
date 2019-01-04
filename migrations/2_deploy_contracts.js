var TCR = artifacts.require("contracts/tcr/TCR.sol");
var TCRToken = artifacts.require("contracts/tcr/TCRToken.sol");

module.exports = async function(deployer, network, accounts) {

  if (network == "main") {


  } else if (network == "rinkeby" || network == "ropsten") {

    deployer.deploy(TCRToken).then(function() {
      return deployer.deploy(TCR, "Simple TCR", TCRToken.address, [100, 60, 60]).then(async function() {



    }) })

  } else if (network == "development") {

    deployer.deploy(TCRToken, {from: accounts[0]}).then(function() {
          return deployer.deploy(TCR, "Simple TCR", TCRToken.address, [100, 60, 60],
            {from: accounts[0]}).then(async function() {



    }) })

  }

}
