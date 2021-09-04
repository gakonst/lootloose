// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/LootLooseSetup.sol";

contract ERC721Callback is LootLooseTest {
    function testCannotCallOnERC721ReceivedDirectly() public {
        try lootLoose.onERC721Received(address(0), address(0), 0, "0x") {} catch
            Error(string memory error)
        {
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
