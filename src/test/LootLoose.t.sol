// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/LootLooseSetup.sol";
import "./utils/LootAirdrop.sol";
import {ILootAirdrop} from "../LootLoose.sol";

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
    }

    function testFailCannotOpenBagYouDoNotOwn() public {
        alice.open(OTHER_BAG);
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
        bob.reassemble(OTHER_BAG);
    }

    function testFailCannotReassembleBagYouDoNotOwn() public {
        alice.reassemble(OTHER_BAG);
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

        try alice.claimAirdrop(address(airdrop), BAG) {} catch Error(
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
