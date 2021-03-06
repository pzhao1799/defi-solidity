// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { deploy } = require("./utils.js");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.A
  const [deployer] = await ethers.getSigners();
  await hre.run('compile');

  await deploy('APRegistry');
  await deploy('ProxyAuth');
  
  await deploy('StrategyExecutor');
  await deploy('SubscriptionProxy');
  await deploy('Subscriptions');

  // aave actions
  await deploy('AaveSupply');
  await deploy('AaveWithdraw');
  await deploy('AaveBorrow');
  await deploy('AavePayback');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
