import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

import { HardhatUserConfig } from "hardhat/types";

import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-deploy";
import "hardhat-deploy-ethers";

const DEPLOYER_PRIVATE_KEY = process.env.RINKEBY_PRIVATE_KEY!;
const INFURA_KEY = process.env.INFURA_KEY || "";

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  namedAccounts: {
    deployer: 0,
  },
  networks: {
    hardhat: {},
    localhost: {},
    development: {
      url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
      accounts: [DEPLOYER_PRIVATE_KEY],
      live: true,
      saveDeployments: true,
    },
    testnet: {
      url: `https://rinkeby.infura.io/v3/${INFURA_KEY}`,
      accounts: [DEPLOYER_PRIVATE_KEY],
    },
  },
  mocha: {
    timeout: 2000000,
  },
  external: process.env.HARDHAT_FORK
    ? {
        deployments: {
          // process.env.HARDHAT_FORK will specify the network that the fork is made from.
          // these lines allow it to fetch the deployments from the network being forked from both for node and deploy task
          hardhat: ["deployments/" + process.env.HARDHAT_FORK],
          localhost: ["deployments/" + process.env.HARDHAT_FORK],
        },
      }
    : undefined,
};

export default config;
