// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "ds-test/test.sol";

import "./Hevm.sol";
import "../../Loot.sol";
import { LootLoose } from "../../LootLoose.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

// NB: Using callbacks is hard, since we're a smart contract account we need
// to be implementing the callbacks
contract LootLooseUser is ERC721Holder, ERC1155Holder {
    DopeWarsLoot loot;
    LootLoose lootLoose;

    constructor(DopeWarsLoot _loot, LootLoose _lootLoose) {
        loot = _loot;
        lootLoose = _lootLoose;
    }

    function claim(uint256 tokenId) public {
        loot.claim(tokenId);
    }

    function open(uint256 tokenId) public {
        lootLoose.open(tokenId);
    }

    function transferERC1155(address to, uint256 tokenId, uint256 amount) public {
        lootLoose.safeTransferFrom(address(this), to, tokenId, amount, "0x");
    }
}

contract LootLooseTest is DSTest {
    uint256 internal constant BAG = 10;
    uint256 internal constant OTHER_BAG = 100;
    Hevm internal constant hevm =
        Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // contracts
    DopeWarsLoot internal loot;
    LootLoose internal lootLoose;

    // users
    LootLooseUser internal alice;

    function setUp() public virtual {
        // deploy contracts
        loot = new DopeWarsLoot();
        lootLoose = new LootLoose(address(loot));

        // create alice's account & claim a bag
        alice = new LootLooseUser(loot, lootLoose);
        alice.claim(BAG);
        assertEq(loot.ownerOf(BAG), address(alice));
    }
}
