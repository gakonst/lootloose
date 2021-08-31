import { ethers } from "hardhat"; // Hardhat

async function main(): Promise<void> {
  // Collect deployer
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy LootItems
  const LootItems = await ethers.getContractFactory("LootItems");
  const lootitems = await LootItems.deploy();

  console.log("Deployed LootItems address:", lootitems.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
