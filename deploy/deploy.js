const fs = require('fs');
require("dotenv").config();

const { LSSVMPairFactoryAddr} = process.env;

module.exports = async ({ getNamedAccounts, deployments }) => {
 // const { deploy } = deployments;
  const {deploy, log} = deployments;
  const { deployer } = await getNamedAccounts();
//  await deploy("Aureus", {
//      from: deployer,
//      log: true,
//    });

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

//  var CollectionstakerAddr = collectionstaker.address;

//  const ERC721Contract = await deploy("ERC721Contract", {
//      from: deployer,
//      args: ["ipfs://QmVfmV7Kn2cYfJLjwwtHBNkphDHZmMPkEWgxcCdF4qXnNx/", "Snippool testnet", "SNIP", 200],
//      log: true,
//    });
//
//   if (ERC721Contract.newlyDeployed) {
//        log(
//          `contract ERC721Contract deployed at ${ERC721Contract.address} using ${ERC721Contract.receipt.gasUsed} gas`
//        );
//   }

//   let config = `
//         const CollectionstakerAddr = "${CollectionstakerAddr}"
//         const CollectionswapAddr = "${CollectionswapAddr}"
//        `
//    let data = JSON.stringify(config)
//    fs.writeFileSync('deployment.js', JSON.parse(data))

};
