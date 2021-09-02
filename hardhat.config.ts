import * as dotenv from "dotenv"; // Env

// Hardhat plugins
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter"; // Gas stats
import "hardhat-abi-exporter"; // ABI exports
import "@nomiclabs/hardhat-etherscan";

// Setup env
dotenv.config();
const ALCHEMY_API_KEY: string = process.env.ALCHEMY_API_KEY ?? "";
const RINKEBY_DEPLOY_PK: string = process.env.RINKEBY_DEPLOY_PK ?? "";
const MAINNET_DEPLOY_PK: string = process.env.MAINNET_DEPLOY_PK ?? "";

// Export Hardhat params
export default {
  networks: {
    // Fork mainnet for testing
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
        blockNumber: 13135486,
      },
    },
     // Deploy to Rinkeby
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${RINKEBY_DEPLOY_PK}`],
    },
    mainnet: {
      url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`${MAINNET_DEPLOY_PK}`],
    },
  },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      metadata: {
        bytecodeHash: 'none',
      },
      outputSelection: {
        '*': {
          '*': ['storageLayout'],
        },
      },
    },
  },
  // Gas reporting
  gasReporter: {
    currency: "USD",
    gasPrice: 20,
  },
  // Export ABIs
  abiExporter: {
    path: "./abi",
    clear: true,
  },
  etherscan: {
    apiKey: "I5BXNZYP5GEDWFINGVEZKYIVU2695NPQZB"
  }
};
