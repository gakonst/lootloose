// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/LootLooseSetup.sol";
import "./utils/LootAirdrop.sol";
import {ILootAirdrop} from "../LootLoose.sol";
import {ItemNames} from "../LootTokensMetadata.sol";

struct Attribute {
    string traitType;
    string value;
}

struct Data {
    string name;
    string description;
    string image;
    Attribute[] attributes;
}

contract Metadata is LootLooseTest {
    function testKatanaBagNames() public {
        ItemNames memory expected = ItemNames({
            weapon: "Katana",
            chest: "Divine Robe",
            head: "Great Helm",
            waist: "Wool Sash",
            foot: "Divine Slippers",
            hand: "Chain Gloves",
            neck: "Amulet",
            ring: "Gold Ring"
        });

        // https://opensea.io/assets/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7/5726
        uint256 id = 5726;
        ItemNames memory names = lootLoose.names(id);
        assertEq(names, expected);
    }

    function testDivineRobeBagNames() public {
        ItemNames memory expected = ItemNames({
            weapon: "Falchion of Fury",
            chest: "Divine Robe",
            head: "Great Helm",
            waist: "'Grim Peak' Sash of Enlightenment +1",
            foot: "Linen Shoes of Titans",
            hand: "'Tempest Grasp' Gloves of Protection +1",
            neck: "Necklace of Protection",
            ring: "Bronze Ring"
        });

        // https://opensea.io/assets/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7/5726
        uint256 id = 3686;
        ItemNames memory names = lootLoose.names(id);
        assertEq(names, expected);
    }

    function testBronzeRingOfEnlightenmentMetadata() public {
        uint256 id = lootLoose.ringId(2169);
        Attribute[] memory attributes = new Attribute[](3);
        attributes[0] = Attribute("Slot", "Ring");
        attributes[1] = Attribute("Item", "Bronze Ring");
        attributes[2] = Attribute("Suffix", "of Enlightenment");
        assertMetadata(id, attributes, "Bronze Ring of Enlightenment");
    }

    function testDivineRobeMetadata() public {
        uint256 id = lootLoose.chestId(3686);
        Attribute[] memory attributes = new Attribute[](2);
        attributes[0] = Attribute("Slot", "Chest");
        attributes[1] = Attribute("Item", "Divine Robe");
        assertMetadata(id, attributes, "Divine Robe");
    }

    function testTempestGraspGlovesOfProtectionPlusOneMetadata() public {
        uint256 id = lootLoose.handId(3686);
        Attribute[] memory attributes = new Attribute[](6);
        attributes[0] = Attribute("Slot", "Hand");
        attributes[1] = Attribute("Item", "Gloves");
        attributes[2] = Attribute("Suffix", "of Protection");
        attributes[3] = Attribute("Name Prefix", "Tempest");
        attributes[4] = Attribute("Name Suffix", "Grasp");
        attributes[5] = Attribute("Augmentation", "Yes");
        assertMetadata(
            id,
            attributes,
            "'Tempest Grasp' Gloves of Protection +1"
        );
    }

    function assertMetadata(
        uint256 tokenId,
        Attribute[] memory attributes,
        string memory name
    ) private {
        string memory meta = lootLoose.uri(tokenId);
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "scripts/metadata.js";
        inputs[2] = meta;
        bytes memory res = hevm.ffi(inputs);
        Data memory data = abi.decode(res, (Data));
        assertEq(data.name, name);
        for (uint256 i = 0; i < attributes.length; i++) {
            assertEq(data.attributes[i], attributes[i]);
        }
    }

    // Would be nice if we had some Rust-like derive macro for this :/ wen Solidity generics
    function assertEq(ItemNames memory got, ItemNames memory expected) private {
        assertEq(got.weapon, expected.weapon);
        assertEq(got.chest, expected.chest);
        assertEq(got.head, expected.head);
        assertEq(got.waist, expected.waist);
        assertEq(got.foot, expected.foot);
        assertEq(got.hand, expected.hand);
        assertEq(got.neck, expected.neck);
        assertEq(got.ring, expected.ring);
    }

    function assertEq(Attribute memory attribute, Attribute memory expected)
        private
    {
        assertEq(attribute.traitType, expected.traitType);
        assertEq(attribute.value, expected.value);
    }
}
