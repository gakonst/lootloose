// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/token/ERC721/ERC721.sol";

contract LootAirdrop is ERC721 {
    IERC721 immutable loot;

    constructor(address _loot) ERC721("Test", "TST") {
        loot = IERC721(_loot);
    }

    function claimForLoot(uint256 tokenId) external payable {
        require(msg.value >= 1 ether, "pay up");
        require(loot.ownerOf(tokenId) == msg.sender, "you must own the bag");
        _mint(msg.sender, tokenId);
    }
}
