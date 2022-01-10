require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
let secrets = require("./secrets");
// require("hardhat-gas-reporter");
// require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.6",
  networks: {
    fuji: {
      url: secrets.url,
      accounts:[secrets.key] 
    }
  },
  etherscan: {
    apiKey: {
      avalanche: "TUQPXNWFDRXQSUATTTQ629HF4B1WDM6U5A",
      avalancheFujiTestnet: "TUQPXNWFDRXQSUATTTQ629HF4B1WDM6U5A",
    }
  }
};
