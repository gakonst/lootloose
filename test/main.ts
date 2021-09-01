import { expect } from "chai"; // Testing
import { BigNumber, Contract, Signer } from "ethers"; // Ethers
import { ethers, network } from "hardhat"; // Hardhat
const LootABI = require("./abi/loot.json");

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
  const LootItemsFactory = await ethers.getContractFactory("LootUnchained");
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

describe("LootTokens", () => {
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

    divineRobeId = await LootItems.chestId(TOKEN_IDS.LOOT_ONE);
  });

  describe("User can split and re-unify their tokens", () => {
    it("Tokens have expected names", async () => {
      const checkNames = (names: any, expected: any) => {
        expect(names.weapon).to.be.equal(expected.weapon);
        expect(names.chest).to.be.equal(expected.chest);
        expect(names.head).to.be.equal(expected.head);
        expect(names.waist).to.be.equal(expected.waist);
        expect(names.foot).to.be.equal(expected.foot);
        expect(names.neck).to.be.equal(expected.neck);
        expect(names.ring).to.be.equal(expected.ring);
      };

      expect(await LootItems.tokenName(divineRobeId)).to.be.equal(
        "Divine Robe"
      );
      const names = await LootItems.names(TOKEN_IDS.LOOT_TWO);
      let expected = {
        weapon: "Falchion of Fury",
        chest: "Divine Robe",
        head: "Great Helm",
        waist: "'Grim Peak' Sash of Enlightenment +1",
        foot: "Linen Shoes of Titans",
        hand: "'Tempest Grasp' Gloves of Protection +1",
        neck: "Necklace of Protection",
        ring: "Bronze Ring",
      };
      checkNames(names, expected);

      const names2 = await LootItems.names(TOKEN_IDS.LOOT_ONE);
      expected = {
        weapon: "Katana",
        chest: "Divine Robe",
        head: "Great Helm",
        waist: "Wool Sash",
        foot: "Divine Slippers",
        hand: "Chain Gloves",
        neck: "Amulet",
        ring: "Gold Ring",
      };
      checkNames(names2, expected);
    });

    it("Should open a bag w/ approve + transferfrom pattern", async () => {
      const robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootItems.connect(robe1).open(TOKEN_IDS.LOOT_ONE);

      const robe2 = await impersonateSigner(ADDRESSES.OWNER_LOOT_TWO);
      await LootItems.connect(robe2).open(TOKEN_IDS.LOOT_TWO);

      // transfer the 1155 to the owner
      await LootItems.connect(robe2).safeTransferFrom(
        ADDRESSES.OWNER_LOOT_TWO,
        ADDRESSES.OWNER_LOOT_ONE,
        divineRobeId,
        1,
        "0x"
      );
      // now they have 2 divine robes
      expect(
        (
          await LootItems.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
        ).toNumber()
      ).to.be.equal(2);
    });

    it("Should open a bag w/ simple transfer", async () => {
      const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
      await loot.functions["safeTransferFrom(address,address,uint256)"](
        ADDRESSES.OWNER_LOOT_ONE,
        LootItemsAddress,
        TOKEN_IDS.LOOT_ONE
      );
      expect(
        (
          await LootItems.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
        ).toNumber()
      ).to.be.equal(1);
    });

    it("Can reassemble an opened bag into its 721 NFT", async () => {
      const loot = await getLootContract(ADDRESSES.OWNER_LOOT_ONE);
      const robe1 = await impersonateSigner(ADDRESSES.OWNER_LOOT_ONE);
      await LootItems.connect(robe1).open(TOKEN_IDS.LOOT_ONE);
      expect(await loot.ownerOf(TOKEN_IDS.LOOT_ONE)).to.be.equal(
        LootItemsAddress
      );

      // allow the contract to access our tokens
      await LootItems.setApprovalForAll(LootItemsAddress, true);

      // do the recovery
      await LootItems.connect(robe1).reassemble(TOKEN_IDS.LOOT_ONE);

      // we no longer own the divine robe 1155
      expect(
        (
          await LootItems.balanceOf(ADDRESSES.OWNER_LOOT_ONE, divineRobeId)
        ).toNumber()
      ).to.be.equal(0);

      // but we now re-own the lootbox
      expect(await loot.ownerOf(TOKEN_IDS.LOOT_ONE)).to.be.equal(
        ADDRESSES.OWNER_LOOT_ONE
      );
    });

    describe("Opensea-compliant metadata", async () => {
      const checkMetadata = async (id: any, attributes: any, name: string) => {
        let meta = await LootItems.tokenURI(id);
        meta = meta.replace("data:application/json;base64,", "");
        meta = new Buffer(meta, "base64").toString();
        meta = JSON.parse(meta);
        expect(meta.name).to.be.deep.equal(name);
        expect(meta.attributes).to.be.deep.equal(attributes);
      };

      it("Correct metadata for: 'Tempest Grasp' Gloves of Protection +1", async () => {
        const id = await LootItems.handId(TOKEN_IDS.LOOT_TWO);
        const attributes = [
          {
            trait_type: "Slot",
            value: "Hand",
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
        checkMetadata(
          id,
          attributes,
          "'Tempest Grasp' Gloves of Protection +1"
        );
      });

      it("Correct metadata for: Divine Robe", async () => {
        const id = await LootItems.chestId(TOKEN_IDS.LOOT_TWO);
        const attributes = [
          {
            trait_type: "Slot",
            value: "Chest",
          },
        ];
        checkMetadata(id, attributes, "Divine Robe");
      });

      it("Correct metadata for: Bronze Ring of Enlightenment", async () => {
        const id = await LootItems.ringId(2169);
        const attributes = [
          {
            trait_type: "Slot",
            value: "Ring",
          },
          {
            trait_type: "Suffix",
            value: "of Enlightenment",
          },
        ];
        checkMetadata(id, attributes, "Bronze Ring of Enlightenment");
      });
    });

    // Just used as a pin on our code's functionality, maybe useless & should remove
    it("Expected token svg", async () => {
      const id = await LootItems.weaponId(TOKEN_IDS.LOOT_ONE);
      const meta = await LootItems.tokenURI(id);
      expect(meta).to.be.equal(
        "data:application/json;base64,eyAibmFtZSI6ICJLYXRhbmEiLCAiZGVzY3JpcHRpb24iIDogIkxvb3QgVG9rZW5zIGFyZSBpdGVtcyBleHRyYWN0ZWQgZnJvbSB0aGUgT0cgTG9vdCBiYWdzLiBGZWVsIGZyZWUgdG8gdXNlIExvb3QgVG9rZW5zIGluIGFueSB3YXkgeW91IHdhbnQuIiwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajQ4YzNSNWJHVStMbUpoYzJVZ2V5Qm1hV3hzT2lCM2FHbDBaVHNnWm05dWRDMW1ZVzFwYkhrNklITmxjbWxtT3lCbWIyNTBMWE5wZW1VNklERTBjSGc3SUgwOEwzTjBlV3hsUGp4eVpXTjBJSGRwWkhSb1BTSXhNREFsSWlCb1pXbG5hSFE5SWpFd01DVWlJR1pwYkd3OUltSnNZV05ySWlBdlBqeDBaWGgwSUhnOUlqRXdJaUI1UFNJeU1DSWdZMnhoYzNNOUltSmhjMlVpUGt0aGRHRnVZVHd2ZEdWNGRENDhkR1Y0ZENCNFBTSXhNQ0lnZVQwaU5EQWlJR05zWVhOelBTSmlZWE5sSWo0OEwzUmxlSFErUEM5emRtYysiLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAiU2xvdCIsICJ2YWx1ZSI6ICJXZWFwb24ifV19"
      );
    });
  });
});
