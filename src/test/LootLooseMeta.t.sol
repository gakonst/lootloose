// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/LootLooseSetup.sol";
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
    function testAK47BagNames() public {
        ItemNames memory expected = ItemNames({
            weapon: "AK47",
            clothes: "White T Shirt",
            vehicle: "Tricycle",
            waist: "Taser Holster",
            foot: "White Forces",
            hand: "Fingerless Gloves",
            drugs: "Adderall",
            neck: "Silver Chain",
            ring: "Platinum Ring"
        });

        // https://opensea.io/assets/0x8707276df042e89669d69a177d3da7dc78bd8723/5726
        uint256 id = 5726;
        ItemNames memory names = lootLoose.names(id);
        assertEq(names, expected);
    }

    function testShovelFromSOMABagNames() public {
        ItemNames memory expected = ItemNames({
            weapon: "Shovel from SOMA",
            clothes: "'High on the Supply Contraband' Bulletproof Vest from Mob Town",
            vehicle: "'The Freelance Pharmacist Triggerman' Dodge from Compton +1",
            waist: "'Kid of the Game Smuggled' D Ring Belt from Queens +1",
            foot: "Barefoot from Chicago",
            hand: "'Street Queen Triggerman' Fingerless Gloves from Buffalo +1",
            drugs: "Shrooms",
            neck: "Bronze Chain from the Backwoods",
            ring: "Diamond Ring"
        });

        // https://opensea.io/assets/0x8707276df042e89669d69a177d3da7dc78bd8723/3686
        uint256 id = 3686;
        ItemNames memory names = lootLoose.names(id);
        assertEq(names, expected);
    }

    function testPlatinumRingFromAtlantaMetadata() public {
        uint256 id = lootLoose.ringId(2169);
        Attribute[] memory attributes = new Attribute[](3);
        attributes[0] = Attribute("Slot", "Ring");
        attributes[1] = Attribute("Item", "Platinum Ring");
        attributes[2] = Attribute("Suffix", "from Atlanta");
        assertMetadata(id, attributes, "Platinum Ring from Atlanta");
    }

    function testHighSupplyBloodStainedShirtFromMobTownMetadata() public {
        uint256 id = lootLoose.clothesId(3686);
        Attribute[] memory attributes = new Attribute[](5);
        attributes[0] = Attribute("Slot", "Clothes");
        attributes[1] = Attribute("Item", "Bulletproof Vest");
        attributes[2] = Attribute("Suffix", "from Mob Town");
        attributes[3] = Attribute("Name Prefix", "High on the Supply");
        attributes[4] = Attribute("Name Suffix", "Contraband");
        assertMetadata(
            id,
            attributes,
            "'High on the Supply Contraband' Bulletproof Vest from Mob Town"
        );
    }

    function testTriggermanFingerlessGlovesFromBuffaloPlusOneMetadata() public {
        uint256 id = lootLoose.handId(3686);
        Attribute[] memory attributes = new Attribute[](6);
        attributes[0] = Attribute("Slot", "Hand");
        attributes[1] = Attribute("Item", "Fingerless Gloves");
        attributes[2] = Attribute("Suffix", "from Buffalo");
        attributes[3] = Attribute("Name Prefix", "Street Queen");
        attributes[4] = Attribute("Name Suffix", "Triggerman");
        attributes[5] = Attribute("Augmentation", "Yes");
        assertMetadata(
            id,
            attributes,
            "'Street Queen Triggerman' Fingerless Gloves from Buffalo +1"
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
        assertEq(got.clothes, expected.clothes);
        assertEq(got.vehicle, expected.vehicle);
        assertEq(got.waist, expected.waist);
        assertEq(got.foot, expected.foot);
        assertEq(got.hand, expected.hand);
        assertEq(got.drugs, expected.drugs);
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
