// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LootAirdrop is ERC721 {
    IERC721 constant loot = IERC721(0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7);

    constructor() ERC721("Test", "TST") {}

    function claimForLoot(uint256 tokenId) external payable {
        require(msg.value >= 1 ether, "pay up");
        require(loot.ownerOf(tokenId) == msg.sender, "you do not own the lootbag for this airdrop");
        _mint(msg.sender, tokenId);
    }
}
