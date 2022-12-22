// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
require("@nomicfoundation/hardhat-toolbox");
const hre = require("hardhat");
const fs = require('fs');
require("dotenv").config();

const { LSSVMPairFactoryAddr} = process.env;


async function main() {

  const [deployer] = await hre.ethers.getSigners();

  // Deploy Collectionswap
  const Collectionswap = await hre.ethers.getContractFactory("Collectionswap");
  const collectionswap = await Collectionswap.deploy(LSSVMPairFactoryAddr);
  await collectionswap.deployed();
  var CollectionswapAddr = collectionswap.address;
  console.log("Collectionswap deployed at:", CollectionswapAddr);

  // Deploy Collectionstaker
  const Collectionstaker = await hre.ethers.getContractFactory("Collectionstaker");
  const collectionstaker = await Collectionstaker.deploy(CollectionswapAddr);
  await collectionstaker.deployed();
  var CollectionstakerAddr = collectionstaker.address;
  console.log("Collectionstaker deployed at:", CollectionstakerAddr);


  let config = `
       const CollectionstakerAddr = "${CollectionstakerAddr}"
       const CollectionswapAddr = "${CollectionswapAddr}"
      `
  let data = JSON.stringify(config)
  fs.writeFileSync('deployment.js', JSON.parse(data))

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
