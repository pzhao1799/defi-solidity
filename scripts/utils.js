const deploy = async (contractName) => {
    const contract = await ethers.getContractFactory(contractName);
    const contractInstance = await contract.deploy();
    console.log(`${contractName} deployed to:`, contractInstance.address);
  }

module.exports = {
  deploy
}