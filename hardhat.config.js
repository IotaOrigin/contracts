require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "alfajores",
  networks: {
    iotaOrigin: {
      url: "https://rpc.iotaorigin.de",
      chainId: 1074,
      accounts: [`${process.env.PRIVATE_KEY}`],
      timeout: 60000,
    },
/*    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/QRhHWlnPOL4P0bvKTR34_SJyOshiR9nG",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },*/
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 44787,
    },
    alfajoresDatahub: {
      url: "https://celo-alfajores--rpc.datahub.figment.io/apikey/<API KEY>",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 44787,
    },
    celo: {
      url: "https://forno.celo.org",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 42220,
    },
    celoDatahub: {
      url: "https://celo-mainnet--rpc.datahub.figment.io/apikey/<API KEY>",
      accounts: [process.env.PRIVATE_KEY],
      chainId: 42220,
    },
    localhost: {
       url: "http://127.0.0.1:8545/",
       accounts: [process.env.PRIVATE_KEY],
    },
  },
  solidity: {
    version: "0.8.17",
     settings: {
        optimizer: {
           enabled: true,
           runs: 200,
        },
        viaIR: true,
     },
  },
};

