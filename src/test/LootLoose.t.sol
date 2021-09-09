// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/LootLooseSetup.sol";
import {ItemIds} from "../LootTokensMetadata.sol";

contract Open is LootLooseTest {
    function testCanOpenBag() public {
        alice.open(BAG);
    }

    function testFailCannotOpenBagTwice() public {
        alice.open(BAG);
        alice.open(BAG);
    }

    function testFailCannotOpenBagYouDoNotOwn() public {
        alice.open(OTHER_BAG);
    }

    // helper for checking ownership of erc1155 tokens after unbundling a bag
    function checkOwns1155s(uint256 tokenId, address who) private {
        ItemIds memory ids = lootLoose.ids(tokenId);
        assertEq(lootLoose.balanceOf(who, ids.weapon), 1);
        assertEq(lootLoose.balanceOf(who, ids.clothes), 1);
        assertEq(lootLoose.balanceOf(who, ids.vehicle), 1);
        assertEq(lootLoose.balanceOf(who, ids.waist), 1);
        assertEq(lootLoose.balanceOf(who, ids.foot), 1);
        assertEq(lootLoose.balanceOf(who, ids.hand), 1);
        assertEq(lootLoose.balanceOf(who, ids.drugs), 1);
        assertEq(lootLoose.balanceOf(who, ids.neck), 1);
        assertEq(lootLoose.balanceOf(who, ids.ring), 1);
    }
}
