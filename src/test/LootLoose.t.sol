// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/LootLooseSetup.sol";
import "./utils/LootAirdrop.sol";
import {ILootAirdrop} from "../LootLoose.sol";
import {ItemIds} from "../LootTokensMetadata.sol";

contract ERC721Callback is LootLooseTest {
    function testCannotCallOnERC721ReceivedDirectly() public {
        try
            lootLoose.onERC721Received(address(0), address(0), 0, "0x")
        {} catch Error(string memory error) {
            assertEq(error, Errors.IsNotLoot);
        }
    }
}

contract Open is LootLooseTest {
    function testCanOpenBag() public {
        alice.open(BAG);
        assertEq(loot.ownerOf(BAG), address(lootLoose));
    }

    function testCanOpenBagWithApproval() public {
        alice.openWithApproval(BAG);
        assertEq(loot.ownerOf(BAG), address(lootLoose));
        checkOwns1155s(BAG, address(alice));
    }

    function testFailCannotOpenBagYouDoNotOwn() public {
        alice.open(OTHER_BAG);
    }

    // helper for checking ownership of erc1155 tokens after unbundling a bag
    function checkOwns1155s(uint256 tokenId, address who) private {
        ItemIds memory ids = lootLoose.ids(tokenId);
        assertEq(lootLoose.balanceOf(who, ids.weapon), 1);
        assertEq(lootLoose.balanceOf(who, ids.chest), 1);
        assertEq(lootLoose.balanceOf(who, ids.head), 1);
        assertEq(lootLoose.balanceOf(who, ids.waist), 1);
        assertEq(lootLoose.balanceOf(who, ids.foot), 1);
        assertEq(lootLoose.balanceOf(who, ids.hand), 1);
        assertEq(lootLoose.balanceOf(who, ids.neck), 1);
        assertEq(lootLoose.balanceOf(who, ids.ring), 1);
    }
}

contract Reassemble is LootLooseTest {
    LootLooseUser internal bob;

    function setUp() public override {
        super.setUp();

        bob = new LootLooseUser(loot, lootLoose);
        bob.claim(OTHER_BAG);
        bob.open(OTHER_BAG);

        alice.open(BAG);
    }

    // Reassembling does not require `setsApprovalForAll`
    function testCanReassemble() public {
        alice.reassemble(BAG);
        assertEq(loot.ownerOf(BAG), address(alice));

        bob.reassemble(OTHER_BAG);
        assertEq(loot.ownerOf(OTHER_BAG), address(bob));
    }

    function testCannotReassembleBagYouDoNotOwn() public {
        try alice.reassemble(OTHER_BAG) { fail(); } catch Error(string memory error) {
            assertEq(error, "ERC1155: burn amount exceeds balance");
        }
    }

    function testCannotReassembleWithoutOwningAllPieces() public {
        uint256 id = lootLoose.weaponId(BAG);
        alice.transferERC1155(address(bob), id, 1);
        try alice.reassemble(BAG) { fail(); } catch Error(string memory error) {
            assertEq(error, "ERC1155: burn amount exceeds balance");
        }
    }
}

contract Airdrop is LootLooseTest {
    LootAirdrop airdrop;

    function setUp() public override {
        super.setUp();
        airdrop = new LootAirdrop(address(loot));
        alice.open(BAG);
    }

    function testCanClaimAirdropForLootLoose() public {
        lootLoose.claimAirdropForLootLoose{value: 1 ether}(
            ILootAirdrop(address(airdrop)),
            BAG
        );
        assertEq(airdrop.ownerOf(BAG), address(lootLoose));
    }

    function testCanClaimAirdrop() public {
        lootLoose.claimAirdropForLootLoose{value: 1 ether}(
            ILootAirdrop(address(airdrop)),
            BAG
        );
        alice.reassemble(BAG);
        alice.claimAirdrop(address(airdrop), BAG);
        assertEq(airdrop.ownerOf(BAG), address(alice));
    }

    function testCannotClaimAirdropIfNotOwner() public {
        lootLoose.claimAirdropForLootLoose{value: 1 ether}(
            ILootAirdrop(address(airdrop)),
            BAG
        );

        try alice.claimAirdrop(address(airdrop), BAG) { fail(); } catch Error(
            string memory error
        ) {
            assertEq(error, Errors.DoesNotOwnLootbag);
        }
    }

    function testCannotClaimAirdropWithoutEnoughMoney() public {
        try
            lootLoose.claimAirdropForLootLoose{value: 0.8 ether}(
                ILootAirdrop(address(airdrop)),
                BAG
            )
        {} catch Error(string memory error) {
            assertEq(error, "pay up");
        }
    }

    function testCannotClaimAirdropForUnopenedBags() public {
        alice.claim(OTHER_BAG);
        try
            lootLoose.claimAirdropForLootLoose{value: 1 ether}(
                ILootAirdrop(address(airdrop)),
                OTHER_BAG
            )
        {} catch Error(string memory error) {
            assertEq(error, "you must own the bag");
        }
    }
}
