//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// ============ Imports ============

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "./LootTokensMetadata.sol";
import {Base64, toString} from "./MetadataUtils.sol";

/// @title Loot Tokens
/// @author Georgios Konstantopoulos
/// @notice Allows "opening" your ERC721 Loot bags and extracting the items inside it
/// The created tokens are ERC1155 compatible, and their on-chain SVG is their name
contract LootTokens is ERC1155, LootTokensMetadata {
    // The OG Loot bags contract
    IERC721 constant loot = IERC721(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);

    // No need for a URI since we're doing everything onchain
    constructor() ERC1155("") {}

    /// @notice Transfers the erc721 bag from your account to the contract and then
    /// opens it. Use it if you have already approved the transfer, else consider
    /// just transferring directly to the contract and letting the `onERC721Received`
    /// do its part
    function open(uint256 tokenId) public {
        loot.safeTransferFrom(msg.sender, address(this), tokenId);
        open(msg.sender, tokenId);
    }

    /// @notice Opens your Loot bag and mints you 8 ERC-1155 tokens for each item
    /// in that bag
    function open(address who, uint256 tokenId) private {
        // NB: We patched ERC1155 to expose `_balances` so
        // that we can manually mint to a user, and manually emit a `TransferBatch`
        // event. If that is unsafe, we could alternatively use the following which
        // will default to OZ's internal method.
        // mintItem(tokenId, weaponComponents, WEAPON);
        // mintItem(tokenId, chestComponents, CHEST);
        // mintItem(tokenId, headComponents, HEAD);
        // mintItem(tokenId, waistComponents, WAIST);
        // mintItem(tokenId, footComponents, FOOT);
        // mintItem(tokenId, handComponents, HAND);
        // mintItem(tokenId, neckComponents, NECK);
        // mintItem(tokenId, ringComponents, RING);
        uint256[] memory ids = new uint256[](8);
        uint256[] memory amounts = new uint256[](8);
        ids[0] = itemId(tokenId, weaponComponents, WEAPON);
        ids[1] = itemId(tokenId, chestComponents, CHEST);
        ids[2] = itemId(tokenId, headComponents, HEAD);
        ids[3] = itemId(tokenId, waistComponents, WAIST);
        ids[4] = itemId(tokenId, footComponents, FOOT);
        ids[5] = itemId(tokenId, handComponents, HAND);
        ids[6] = itemId(tokenId, neckComponents, NECK);
        ids[7] = itemId(tokenId, ringComponents, RING);
        for (uint256 i = 0; i < ids.length; i++) {
            amounts[i] = 1;
            // +21k per call / unavoidable - requires patching OZ
            _balances[ids[i]][who] += 1;
        }

        emit TransferBatch(_msgSender(), address(0), who, ids, amounts);
    }

    /// @notice Re-assembles the original Loot bag by burning all the ERC1155 tokens
    /// which were inside of it. Because ERC1155 tokens are fungible, you can give it
    /// any token that matches the one that was originally in it (i.e. you don't need to
    /// give it the exact e.g. Divine Robe that was created during minting.
    function reassemble(uint256 tokenId) external {
        // 1. burn the items
        burnItem(tokenId, weaponComponents, WEAPON);
        burnItem(tokenId, chestComponents, CHEST);
        burnItem(tokenId, headComponents, HEAD);
        burnItem(tokenId, waistComponents, WAIST);
        burnItem(tokenId, footComponents, FOOT);
        burnItem(tokenId, handComponents, HAND);
        burnItem(tokenId, neckComponents, NECK);
        burnItem(tokenId, ringComponents, RING);

        // 2. give back the bag
        loot.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice Extracts the components associated with the ERC721 Loot bag using
    /// dhof's LootComponents utils and proceeds to mint a token for the corresponding
    /// token id to the msg.sender.
    function mintItem(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private {
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = TokenId.toId(components, itemType);
        _mint(msg.sender, id, 1, "");
    }

    function itemId(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private view returns (uint256) {
        uint256[5] memory components = componentsFn(tokenId);
        return TokenId.toId(components, itemType);
    }

    /// @notice Extracts the components associated with the ERC721 Loot bag using
    /// dhof's LootComponents utils and proceeds to burn a token for the corresponding
    /// item from the msg.sender.
    function burnItem(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private {
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = TokenId.toId(components, itemType);
        _burn(msg.sender, id, 1);
    }

    /// @notice Returns an SVG for the provided token id that
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
                        '{"name": "Sheet #',
                        toString(tokenId),
                        // TODO
                        '", "description": "Loot Tokens are items extracted from the OG Loot bags. Feel free to use Loot Tokens in any way you want.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function onERC721Received(
        // sender of the tx
        address,
        // the user that sent in the nft
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        // only supports callback from the Loot contract
        require(msg.sender == address(loot));
        open(from, tokenId);
        return LootTokens.onERC721Received.selector;
    }
}
