//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// ============ Imports ============

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./LootComponents.sol";

import "hardhat/console.sol";

/**
 * @title Loot Remix
 * @author Georgios Konstantopoulos
 */
contract LootItems is ERC1155, LootComponents {
    IERC721 constant loot = IERC721(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);

    // TODOs:
    // 1. Override the URI to auto-generate the text for the item
    // 2. LootComponentsRemix -> takes the fragments and issues a new bag against them
    constructor() ERC1155("") {}

    function split(uint256 tokenId) external {
        // 1. receive the loot
        loot.safeTransferFrom(msg.sender, address(this), tokenId);

        // 2. mint all the items
        mintItem(tokenId, weaponComponents, "weapon");
        mintItem(tokenId, chestComponents, "chest");
        mintItem(tokenId, headComponents, "head");
        mintItem(tokenId, waistComponents, "waist");
        mintItem(tokenId, footComponents, "foot");
        mintItem(tokenId, handComponents, "hand");
        mintItem(tokenId, neckComponents, "neck");
        mintItem(tokenId, ringComponents, "ring");
    }

    // burn all the items from the msg.sender, calculating the components
    // from the id on the fly. doesn't care if it was the original item in the bag
    // i.e. accepts "used" items
    function recover(uint256 tokenId) external {
        burnItem(tokenId, weaponComponents, "weapon");
        burnItem(tokenId, chestComponents, "chest");
        burnItem(tokenId, headComponents, "head");
        burnItem(tokenId, waistComponents, "waist");
        burnItem(tokenId, footComponents, "foot");
        burnItem(tokenId, handComponents, "hand");
        burnItem(tokenId, neckComponents, "neck");
        burnItem(tokenId, ringComponents, "ring");

        // give it back
        loot.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function mintItem(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        string memory salt
    ) internal {
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = idFromComponents(components, salt);
        _mint(msg.sender, id, 1, "");
    }

    function burnItem(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        string memory salt
    ) internal {
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = idFromComponents(components, salt);
        _burn(msg.sender, id, 1);
    }

    // hashes together the components to generate a unique id. needs a salt to avoid
    // collisions between same components from different categories
    function idFromComponents(uint256[5] memory components, string memory salt)
        public
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(components, salt)));
    }

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

    function ids(uint256 tokenId) external view returns (ItemIds memory) {
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

    // View helpers for getting the item ID that corresponds to a bag's items
    function weaponId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(weaponComponents(tokenId), "weapon");
    }

    function chestId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(chestComponents(tokenId), "chest");
    }

    function headId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(headComponents(tokenId), "head");
    }

    function waistId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(waistComponents(tokenId), "waist");
    }

    function footId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(footComponents(tokenId), "foot");
    }

    function handId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(handComponents(tokenId), "hand");
    }

    function neckId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(neckComponents(tokenId), "neck");
    }

    function ringId(uint256 tokenId) public view returns (uint256) {
        return idFromComponents(ringComponents(tokenId), "ring");
    }

    // accept nfts - boilerplate
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return LootItems.onERC721Received.selector;
    }
}
