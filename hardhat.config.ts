import * as dotenv from "dotenv"; // Env
import "@nomiclabs/hardhat-waffle"; // Hardhat

// Hardhat plugins
import "hardhat-gas-reporter"; // Gas stats
import "hardhat-abi-exporter"; // ABI exports
import "@nomiclabs/hardhat-solhint"; // Solhint

// Setup env
dotenv.config();
const ALCHEMY_API_KEY: string = process.env.ALCHEMY_API_KEY ?? "";

// Export Hardhat params
export default {
  // Soldity ^0.8.0
  solidity: "0.8.4",
  networks: {
    // Fork mainnet for testing
    hardhat: {
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
        blockNumber: 13135486,
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
};
