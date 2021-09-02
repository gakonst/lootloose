import { expect } from "chai"; // Testing
import { BigNumber, Contract, Signer } from "ethers"; // Ethers
import { ethers, network } from "hardhat"; // Hardhat
const LootABI = require("./abi/loot.json");

// Setup global contracts
let LootLoose: Contract;
let LootLooseAddress: string;

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
  const LootLooseFactory = await ethers.getContractFactory("LootLoose");
  const contract = await LootLooseFactory.deploy();
  await contract.deployed();

  LootLoose = contract;
  LootLooseAddress = contract.address.toString();
}

async function getLootContract(address: string): Promise<Contract> {
  // Collect signer by address
  const signer = await impersonateSigner(address);
  // Return new contract w/ signer
  return new ethers.Contract(ADDRESSES.LOOT, LootABI, signer);
}

async function approve(): Promise<void> {
  const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
  await loot.approve(LootLooseAddress, TOKEN_IDS.LOOT_ONE);

  const robe2 = await impersonateSigner(ADDRESSES.OWNER_LOOT_TWO);
  await loot.connect(robe2).approve(LootLooseAddress, TOKEN_IDS.LOOT_TWO);
}

describe("LootLoose", () => {
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

    divineRobeId = await LootLoose.chestId(TOKEN_IDS.LOOT_ONE);
  });

  describe("Can claim 3rd party ERC721 airdrops", async () => {
    let airdrop: Contract;
    let robe1: Signer;

    beforeEach(async () => {
      // deploy the airdrop contract
      const factory = await ethers.getContractFactory("LootAirdrop");
      airdrop = await factory.deploy();

      // open a bag
      robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootLoose.connect(robe1).open(TOKEN_IDS.LOOT_ONE);

      // approve for all so that we can re-assemble
      await LootLoose.connect(robe1).setApprovalForAll(LootLooseAddress, true);
    });

    it("cannot claimAirdropForLootLoose if the contract doesn't own the NFT", async () => {
      await expect(
        LootLoose.claimAirdropForLootLoose(
          airdrop.address,
          TOKEN_IDS.LOOT_TWO,
          { value: ethers.utils.parseEther("1") }
        )
      ).revertedWith("you do not own the lootbag for this airdrop");
    });

    it("cannot claimAirdropForLootLoose if you do not pay", async () => {
      await expect(
        LootLoose.claimAirdropForLootLoose(
          airdrop.address,
          TOKEN_IDS.LOOT_ONE,
          { value: ethers.utils.parseEther("0.5") }
        )
      ).to.be.revertedWith("pay up");
    });

    it("can claimAirdropForLootLoose if the contract owns the NFT", async () => {
      await LootLoose.claimAirdropForLootLoose(
        airdrop.address,
        TOKEN_IDS.LOOT_ONE,
        { value: ethers.utils.parseEther("1") }
      );
      expect(await airdrop.ownerOf(TOKEN_IDS.LOOT_ONE)).equal(LootLooseAddress);
    });

    it("only the owner of the bag can claim the airdrop from the contract", async () => {
      await LootLoose.claimAirdropForLootLoose(
        airdrop.address,
        TOKEN_IDS.LOOT_ONE,
        { value: ethers.utils.parseEther("1") }
      );

      // it fails if we haven't reclaimed the bag
      await expect(
        LootLoose.connect(robe1).claimAirdrop(
          airdrop.address,
          TOKEN_IDS.LOOT_ONE
        )
      ).to.be.revertedWith("you do not own the lootbag for this airdrop");

      // reassemble it
      await LootLoose.connect(robe1).reassemble(TOKEN_IDS.LOOT_ONE);

      // claim
      await LootLoose.connect(robe1).claimAirdrop(
        airdrop.address,
        TOKEN_IDS.LOOT_ONE
      );
      expect(await airdrop.ownerOf(TOKEN_IDS.LOOT_ONE)).equal(
        ADDRESSES.OWNER_LOOT_ONE
      );
    });
  });

  describe("Opensea-compliant metadata", async () => {
    const checkMetadata = async (id: any, attributes: any, name: string) => {
      let meta = await LootLoose.tokenURI(id);
      meta = meta.replace("data:application/json;base64,", "");
      meta = new Buffer(meta, "base64").toString();
      meta = JSON.parse(meta);
      expect(meta.name).to.be.deep.equal(name);
      expect(meta.attributes).to.be.deep.equal(attributes);
    };

    it("Correct metadata for: 'Tempest Grasp' Gloves of Protection +1", async () => {
      const id = await LootLoose.handId(TOKEN_IDS.LOOT_TWO);
      const attributes = [
        {
          trait_type: "Slot",
          value: "Hand",
        },
        {
          trait_type: "Item",
          value: "Gloves",
        },
        {
          trait_type: "Suffix",
          value: "of Protection",
        },
        {
          trait_type: "Name Prefix",
          value: "Tempest",
        },
        {
          trait_type: "Name Suffix",
          value: "Grasp",
        },
        {
          trait_type: "Augmentation",
          value: "Yes",
        },
      ];
      checkMetadata(id, attributes, "'Tempest Grasp' Gloves of Protection +1");
    });

    it("Correct metadata for: Divine Robe", async () => {
      const id = await LootLoose.chestId(TOKEN_IDS.LOOT_TWO);
      const attributes = [
        {
          trait_type: "Slot",
          value: "Chest",
        },
        {
          trait_type: "Item",
          value: "Divine Robe",
        },
      ];
      checkMetadata(id, attributes, "Divine Robe");
    });

    it("Correct metadata for: Bronze Ring of Enlightenment", async () => {
      const id = await LootLoose.ringId(2169);
      const attributes = [
        {
          trait_type: "Slot",
          value: "Ring",
        },
        {
          trait_type: "Item",
          value: "Bronze Ring",
        },
        {
          trait_type: "Suffix",
          value: "of Enlightenment",
        },
      ];
      checkMetadata(id, attributes, "Bronze Ring of Enlightenment");
    });
  });

  describe("Name / Id meta", () => {
    const checkNames = (names: any, expected: any) => {
      expect(names.weapon).to.be.equal(expected.weapon);
      expect(names.chest).to.be.equal(expected.chest);
      expect(names.head).to.be.equal(expected.head);
      expect(names.waist).to.be.equal(expected.waist);
      expect(names.foot).to.be.equal(expected.foot);
      expect(names.neck).to.be.equal(expected.neck);
      expect(names.ring).to.be.equal(expected.ring);
    };

    it("Divine Robe", async () => {
      expect(await LootLoose.tokenName(divineRobeId)).to.be.equal(
        "Divine Robe"
      );
    });

    const bag1 = {
      weapon: "Katana",
      chest: "Divine Robe",
      head: "Great Helm",
      waist: "Wool Sash",
      foot: "Divine Slippers",
      hand: "Chain Gloves",
      neck: "Amulet",
      ring: "Gold Ring",
    };

    const bag2 = {
      weapon: "Falchion of Fury",
      chest: "Divine Robe",
      head: "Great Helm",
      waist: "'Grim Peak' Sash of Enlightenment +1",
      foot: "Linen Shoes of Titans",
      hand: "'Tempest Grasp' Gloves of Protection +1",
      neck: "Necklace of Protection",
      ring: "Bronze Ring",
    };

    it("Bag 1", async () => {
      const names = await LootLoose.names(TOKEN_IDS.LOOT_ONE);
      checkNames(names, bag1);
    });

    it("Bag 2", async () => {
      const names = await LootLoose.names(TOKEN_IDS.LOOT_TWO);
      checkNames(names, bag2);
    });

    it("Batched Bags", async () => {
      const names = await LootLoose.namesMany([
        TOKEN_IDS.LOOT_ONE,
        TOKEN_IDS.LOOT_TWO,
      ]);
      checkNames(names[0], bag1);
      checkNames(names[1], bag2);
    });
  });

  describe("User can split and re-unify their tokens", () => {
    it("Should open a bag w/ approve + transferfrom pattern", async () => {
      const robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootLoose.connect(robe1).open(TOKEN_IDS.LOOT_ONE);

      const robe2 = await impersonateSigner(ADDRESSES.OWNER_LOOT_TWO);
      await LootLoose.connect(robe2).open(TOKEN_IDS.LOOT_TWO);

      // transfer the 1155 to the owner
      await LootLoose.connect(robe2).safeTransferFrom(
        ADDRESSES.OWNER_LOOT_TWO,
        ADDRESSES.OWNER_LOOT_ONE,
        divineRobeId,
        1,
        "0x"
      );
      // now they have 2 divine robes
      expect(
        (
          await LootLoose.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
        ).toNumber()
      ).to.be.equal(2);
    });

    it("Should open a bag w/ simple transfer", async () => {
      const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
      await loot.functions["safeTransferFrom(address,address,uint256)"](
        ADDRESSES.OWNER_LOOT_ONE,
        LootLooseAddress,
        TOKEN_IDS.LOOT_ONE
      );
      expect(
        (
          await LootLoose.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
        ).toNumber()
      ).to.be.equal(1);
    });

    it("Can reassemble an opened bag into its 721 NFT", async () => {
      const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
      const robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootLoose.connect(robe1).open(TOKEN_IDS.LOOT_ONE);
      expect(await loot.ownerOf(TOKEN_IDS.LOOT_ONE)).to.be.equal(
        LootLooseAddress
      );

      // allow the contract to access our tokens
      await LootLoose.setApprovalForAll(LootLooseAddress, true);

      // do the recovery
      await LootLoose.connect(robe1).reassemble(TOKEN_IDS.LOOT_ONE);

      // we no longer own the divine robe 1155
      expect(
        (
          await LootLoose.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
        ).toNumber()
      ).to.be.equal(0);

      // but we now re-own the lootbox
      expect(await loot.ownerOf(TOKEN_IDS.LOOT_ONE)).to.be.equal(
        ADDRESSES.OWNER_LOOT_ONE
      );
    });
  });
});
