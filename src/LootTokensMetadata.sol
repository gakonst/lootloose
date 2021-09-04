//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./LootComponents.sol";
import "./TokenId.sol";
import {Base64, toString} from "./MetadataUtils.sol";

struct ItemIds {
    uint256 weapon;
    uint256 chest;
    uint256 head;
    uint256 waist;
    uint256 foot;
    uint256 hand;
    uint256 neck;
    uint256 ring;
}

struct ItemNames {
    string weapon;
    string chest;
    string head;
    string waist;
    string foot;
    string hand;
    string neck;
    string ring;
}


/// @title Helper contract for generating ERC-1155 token ids and descriptions for
/// the individual items inside a Loot bag.
/// @author Georgios Konstantopoulos
/// @dev Inherit from this contract and use it to generate metadata for your tokens
contract LootTokensMetadata is LootComponents {
    uint256 internal constant WEAPON = 0x0;
    uint256 internal constant CHEST = 0x1;
    uint256 internal constant HEAD = 0x2;
    uint256 internal constant WAIST = 0x3;
    uint256 internal constant FOOT = 0x4;
    uint256 internal constant HAND = 0x5;
    uint256 internal constant NECK = 0x6;
    uint256 internal constant RING = 0x7;

    string[] internal itemTypes = [
        "Weapon",
        "Chest",
        "Head",
        "Waist",
        "Foot",
        "Hand",
        "Neck",
        "Ring"
    ];

    function name() external pure returns (string memory) {
        return "LootLoose";
    }

    function symbol() external pure returns (string memory) {
        return "LOL";
    }

    /// @dev Opensea contract metadata: https://docs.opensea.io/docs/contract-level-metadata
    function contractURI() external pure returns (string memory) {
      string memory json = '{"name": "LootLoose", "description": "LootLoose lets you unbundle your Loot Bags into individual ERC1155 NFTs or rebundle items into their original Loot Bags."}';
      string memory encodedJson = Base64.encode(bytes(json));
      string memory output = string(abi.encodePacked('data:application/json;base64,', encodedJson));

      return output;
    }

    /// @notice Returns an SVG for the provided token id
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string[4] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';

        parts[1] = tokenName(tokenId);

        parts[2] = '</text><text x="10" y="40" class="base">';

        parts[3] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3])
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "name": "', tokenName(tokenId),'", ', 
                        '"description" : ', '"LootLoose lets you unbundle your Loot Bags into individual ERC1155 NFTs or rebundle items into their original Loot Bags.", ',
                        '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '", ' 
                        '"attributes": ', attributes(tokenId),
                        '}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /// @notice Returns the attributes associated with this item.
    /// @dev Opensea Standards: https://docs.opensea.io/docs/metadata-standards
    function attributes(uint256 id) public view returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        // should we also use components[0] which contains the item name?
        string memory slot = itemTypes[itemType];
        string memory res = string(abi.encodePacked('[', trait("Slot", slot)));

        string memory item = itemName(itemType, components[0]);
        res = string(abi.encodePacked(res, ", ", trait("Item", item)));

        if (components[1] > 0) {
            string memory data = suffixes[components[1] - 1];
            res = string(abi.encodePacked(res, ", ", trait("Suffix", data)));
        }

        if (components[2] > 0) {
            string memory data = namePrefixes[components[2] - 1];
            res = string(abi.encodePacked(res, ", ", trait("Name Prefix", data)));
        }

        if (components[3] > 0) {
            string memory data = nameSuffixes[components[3] - 1];
            res = string(abi.encodePacked(res, ", ", trait("Name Suffix", data)));
        }

        if (components[4] > 0) {
            res = string(abi.encodePacked(res, ", ", trait("Augmentation", "Yes")));
        }

        res = string(abi.encodePacked(res, ']'));

        return res;
    }

    // Helper for encoding as json w/ trait_type / value from opensea
    function trait(string memory _traitType, string memory _value) internal pure returns (string memory) {
        return string(abi.encodePacked('{',
            '"trait_type": "', _traitType, '", ',
            '"value": "', _value, '"',
        '}'));
      }

    // @notice Given an ERC1155 token id, it returns its name by decoding and parsing
    // the id
    function tokenName(uint256 id) public view returns (string memory) {
        (uint256[5] memory components, uint256 itemType) = TokenId.fromId(id);
        return componentsToString(components, itemType);
    }

    // Returns the "vanilla" item name w/o any prefix/suffixes or augmentations
    function itemName(uint256 itemType, uint256 idx) public view returns (string memory) {
        string[] storage arr;
        if (itemType == WEAPON) {
            arr = weapons;
        } else if (itemType == CHEST) {
            arr = chestArmor;
        } else if (itemType == HEAD) {
            arr = headArmor;
        } else if (itemType == WAIST) {
            arr = waistArmor;
        } else if (itemType == FOOT) {
            arr = footArmor;
        } else if (itemType == HAND) {
            arr = handArmor;
        } else if (itemType == NECK) {
            arr = necklaces;
        } else if (itemType == RING) {
            arr = rings;
        } else {
            revert("Unexpected armor piece");
        }

        return arr[idx];
    }

    // Creates the token description given its components and what type it is
    function componentsToString(uint256[5] memory components, uint256 itemType)
        public
        view
        returns (string memory)
    {
        // item type: what slot to get
        // components[0] the index in the array
        string memory item = itemName(itemType, components[0]);

        // We need to do -1 because the 'no description' is not part of loot copmonents

        // add the suffix
        if (components[1] > 0) {
            item = string(
                abi.encodePacked(item, " ", suffixes[components[1] - 1])
            );
        }

        // add the name prefix / suffix
        if (components[2] > 0) {
            // prefix
            string memory namePrefixSuffix = string(
                abi.encodePacked("'", namePrefixes[components[2] - 1])
            );
            if (components[3] > 0) {
                namePrefixSuffix = string(
                    abi.encodePacked(namePrefixSuffix, " ", nameSuffixes[components[3] - 1])
                );
            }

            namePrefixSuffix = string(abi.encodePacked(namePrefixSuffix, "' "));

            item = string(abi.encodePacked(namePrefixSuffix, item));
        }

        // add the augmentation
        if (components[4] > 0) {
            item = string(abi.encodePacked(item, " +1"));
        }

        return item;
    }

    // View helpers for getting the item ID that corresponds to a bag's items
    function weaponId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(weaponComponents(tokenId), WEAPON);
    }

    function chestId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(chestComponents(tokenId), CHEST);
    }

    function headId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(headComponents(tokenId), HEAD);
    }

    function waistId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(waistComponents(tokenId), WAIST);
    }

    function footId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(footComponents(tokenId), FOOT);
    }

    function handId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(handComponents(tokenId), HAND);
    }

    function neckId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(neckComponents(tokenId), NECK);
    }

    function ringId(uint256 tokenId) public pure returns (uint256) {
        return TokenId.toId(ringComponents(tokenId), RING);
    }

    // Given an erc721 bag, returns the erc1155 token ids of the items in the bag
    function ids(uint256 tokenId) public pure returns (ItemIds memory) {
        return
            ItemIds({
                weapon: weaponId(tokenId),
                chest: chestId(tokenId),
                head: headId(tokenId),
                waist: waistId(tokenId),
                foot: footId(tokenId),
                hand: handId(tokenId),
                neck: neckId(tokenId),
                ring: ringId(tokenId)
            });
    }

    function idsMany(uint256[] memory tokenIds) public pure returns (ItemIds[] memory) {
        ItemIds[] memory itemids = new ItemIds[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            itemids[i] = ids(tokenIds[i]);
        }

        return itemids;
    }

    // Given an ERC721 bag, returns the names of the items in the bag
    function names(uint256 tokenId) public view returns (ItemNames memory) {
        ItemIds memory items = ids(tokenId);
        return
            ItemNames({
                weapon: tokenName(items.weapon),
                chest: tokenName(items.chest),
                head: tokenName(items.head),
                waist: tokenName(items.waist),
                foot: tokenName(items.foot),
                hand: tokenName(items.hand),
                neck: tokenName(items.neck),
                ring: tokenName(items.ring)
            });
    }

    function namesMany(uint256[] memory tokenNames) public view returns (ItemNames[] memory) {
        ItemNames[] memory itemNames = new ItemNames[](tokenNames.length);
        for (uint256 i = 0; i < tokenNames.length; i++) {
            itemNames[i] = names(tokenNames[i]);
        }

        return itemNames;
    }
}
