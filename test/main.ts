import { expect } from "chai"; // Testing
import { BigNumber, Contract, Signer, Transaction } from "ethers"; // Ethers
import { ethers, waffle, network } from "hardhat"; // Hardhat
const LootABI = require("./abi/loot.json");

// Potential revert error messages
// const ERROR_MESSAGES: Record<string, Record<string, string>> = {
// };

// Setup global contracts
let LootItems: Contract;
let LootItemsAddress: string;

const ADDRESSES: Record<string, string> = {
  // https://opensea.io/0x3fae7d59a245527fc09f2c274e18a3834e027708
  OWNER_LOOT_ONE: "0x3Fae7D59a245527Fc09F2c274E18A3834E027708",
  // https://opensea.io/0x930af7923b8b5f8d3461ad1999ceeb8a62884b19
  OWNER_LOOT_TWO: "0x930af7923b8b5f8d3461ad1999ceeb8a62884b19",
  // Loot contract
  LOOT: "0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7",
  ZERO: "0x0000000000000000000000000000000000000000",
};

const TOKEN_IDS: Record<string, number> = {
  LOOT_ONE: 5726,
  LOOT_TWO: 3686,
};

async function impersonateSigner(account: string): Promise<Signer> {
  // Impersonate account
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [account],
  });

  // Return ethers signer
  return await ethers.provider.getSigner(account);
}

async function deploy(): Promise<void> {
  const LootItemsFactory = await ethers.getContractFactory("LootItems");
  const contract = await LootItemsFactory.deploy();
  await contract.deployed();

  LootItems = contract;
  LootItemsAddress = contract.address.toString();
}

async function getLootContract(address: string): Promise<Contract> {
  // Collect signer by address
  const signer = await impersonateSigner(address);
  // Return new contract w/ signer
  return new ethers.Contract(ADDRESSES.LOOT, LootABI, signer);
}

async function approve(): Promise<void> {
  const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
  await loot.approve(LootItemsAddress, TOKEN_IDS.LOOT_ONE);

  const robe2 = await impersonateSigner(ADDRESSES.OWNER_LOOT_TWO);
  await loot.connect(robe2).approve(LootItemsAddress, TOKEN_IDS.LOOT_TWO);
}

describe("LootItems", () => {
  let divineRobeId: BigNumber;

  // Pre-setup
  beforeEach(async () => {
    // Reset hardhat forknet
    await network.provider.request({
      method: "hardhat_reset",
      params: [
        {
          forking: {
            jsonRpcUrl: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
            blockNumber: 13135486,
          },
        },
      ],
    });

    // Deploy contract
    await deploy();

    await approve();

    divineRobeId = await LootItems.chestId(TOKEN_IDS.DIVINE_ROBE_ONE);
  });

  describe("User can split and re-unify their tokens", () => {
    it("Should split a bag into its components and use them as erc1155s", async () => {
      const robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootItems.connect(robe1).split(TOKEN_IDS.LOOT_ONE);

      const robe2 = await impersonateSigner(ADDRESSES.OWNER_LOOT_TWO);
      await LootItems.connect(robe2).split(TOKEN_IDS.LOOT_TWO);

      // transfer the 1155 to the owner
      await LootItems.connect(robe2).safeTransferFrom(
        ADDRESSES.OWNER_LOOT_ONE,
        ADDRESSES.OWNER_LOOT_TWO,
        divineRobeId,
        1,
        "0x"
      );
      // now they have 2 divine robes
      expect(
        await LootItems.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
      ).to.be.equal(2);
    });

    it("Can recombine a split bag into its 721 NFT", async () => {
      const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
      const robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootItems.connect(robe1).split(TOKEN_IDS.DIVINE_ROBE_ONE);
      expect(await loot.ownerOf(TOKEN_IDS.DIVINE_ROBE_ONE)).to.be.equal(
        LootItemsAddress
      );

      // allow the contract to access our tokens
      await LootItems.setApprovalForAll(LootItemsAddress, true);

      // do the recovery
      await LootItems.connect(robe1).recover(TOKEN_IDS.DIVINE_ROBE_ONE);

      // we no longer own the divine robe 1155
      expect(
        await LootItems.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
      ).to.be.equal(0);

      // but we now re-own the lootbox
      expect(await loot.ownerOf(TOKEN_IDS.LOOT_ONE)).to.be.equal(
        ADDRESSES.OWNER_LOOT_ONE
      );
    });
  });
});
