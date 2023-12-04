require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");
require("@nomiclabs/hardhat-ethers")

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
  namedAccounts: {
     deployer: 0
  },
  networks: {
    shimmerevm: {
      url: "https://json-rpc.evm.shimmer.network",
      chainId: 148,
      accounts: [`${process.env.PRIVATE_KEY}`],
      timeout: 60000,
    },
    shimmerevmtestnet: {
      url: "https://json-rpc.evm.testnet.shimmer.network/",
      chainId: 1073,
      accounts: [`${process.env.PRIVATE_KEY}`],
      timeout: 60000,
    },
    goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/DUPGDHnXTGrPAm7K73wATu8U6HQfXnki",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: 5,
    },
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
 etherscan: {
    apiKey: {
      'shimmerevm': 'ABCDE12345ABCDE12345ABCDE123456789',
      'shimmerevmtestnet': 'ABCDE12345ABCDE12345ABCDE123456789',
      'goerli': 'D3NF56WIXRZKS4Z68VQ2TAGDFS4HU392W5',
    },
    customChains: [
      {
        apikey: "ABCDE12345ABCDE12345ABCDE123456789",
        network: "shimmerevmtestnet",
        chainId: 1073,
        urls: {
          apiURL: "https://explorer.evm.testnet.shimmer.network/api",
          browserURL: "https://explorer.evm.testnet.shimmer.network/"
        }
      },
      {
        network: 'shimmerevm',
        chainId: 148,
        urls: {
          apiURL: 'https://explorer.evm.shimmer.network/api',
          browserURL: 'https://explorer.evm.shimmer.network/',
        },
      },
    ],
  },
  solidity: {
    version: "0.8.17",
     settings: {
        optimizer: {
           enabled: true,
           runs: 200,
        },
        viaIR: true,
        outputSelection: {
          "*": {
            "*": [
              "abi",
              "evm.bytecode",
              "evm.deployedBytecode",
              "metadata",
            ]
          },
        },
     },
  },
};

