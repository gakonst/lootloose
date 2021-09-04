// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import "./utils/Hevm.sol";
import "./utils/Loot.sol";
import "../LootLoose.sol";

contract LootUser {
    Loot loot;

    constructor(Loot _loot) {
        loot = _loot;
    }

    function claim(uint256 tokenId) {
        loot.claim(tokenId);
    }
}

contract LootLooseTest is DSTest {
    Hevm hevm;
    Loot loot;
    LootLoose lootLoose;

    function setUp() public {
        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        loot = new Loot();
        alice = new LootUser(loot);

        lootLoose = new LootLooseTest();
    }

    function testCanOpenBag() {

    }
}
