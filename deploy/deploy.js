const fs = require('fs');
require("dotenv").config();

const { LSSVMPairFactoryAddr} = process.env;

module.exports = async ({ getNamedAccounts, deployments }) => {
 // const { deploy } = deployments;
  const {deploy, log} = deployments;
  const { deployer } = await getNamedAccounts();
  const collectionswap = await deploy("Collectionswap", {
    from: deployer,
    args: [LSSVMPairFactoryAddr],
    log: true,
  });

 if (collectionswap.newlyDeployed) {
      log(
        `contract collectionswap deployed at ${collectionswap.address} using ${collectionswap.receipt.gasUsed} gas`
      );
 }

 var CollectionswapAddr = collectionswap.address;

   const collectionstaker = await deploy("Collectionstaker", {
     from: deployer,
     args: [collectionswap.address],
     log: true,
   });

  if (collectionstaker.newlyDeployed) {
         log(
           `contract collectionstaker deployed at ${collectionstaker.address} using ${collectionstaker.receipt.gasUsed} gas`
         );
  }

  var CollectionstakerAddr = collectionstaker.address;

   let config = `
         const CollectionstakerAddr = "${CollectionstakerAddr}"
         const CollectionswapAddr = "${CollectionswapAddr}"
        `
    let data = JSON.stringify(config)
    fs.writeFileSync('deployment.js', JSON.parse(data))

};
