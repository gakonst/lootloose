import { ethers } from "hardhat"; // Hardhat

async function main(): Promise<void> {
  // Collect deployer
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy LootLoose
  const LootLoose = await ethers.getContractFactory("LootLoose");
  const lootloose = await LootLoose.deploy();

  console.log("Deployed LootLoose address:", lootloose.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
