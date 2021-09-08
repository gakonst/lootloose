// SPDX-License-Identifier: Unlicense

/*

    LootComponents.sol
    
    This is a utility contract to make it easier for other
    contracts to work with Loot properties.
    
    Call weaponComponents(), clothesComponents(), etc. to get 
    an array of attributes that correspond to the item. 
    
    The return format is:
    
    uint256[5] =>
        [0] = Item ID
        [1] = Suffix ID (0 for none)
        [2] = Name Prefix ID (0 for none)
        [3] = Name Suffix ID (0 for none)
        [4] = Augmentation (0 = false, 1 = true)
    
    See the item and attribute tables below for corresponding IDs.

*/

pragma solidity ^0.8.4;

contract LootComponents {
    string[] internal weapons = [
        "Pocket Knife", // 0
        "Chain", // 1
        "Knife", // 2
        "Crowbar", // 3
        "Handgun", // 4
        "AK47", // 5
        "Shovel", // 6
        "Baseball Bat", // 7
        "Tire Iron", // 8
        "Police Baton", // 9
        "Pepper Spray", // 10
        "Razor Blade", // 11
        "Chain", // 12
        "Taser", // 13
        "Brass Knuckles", // 14
        "Shotgun", // 15
        "Glock", // 16
        "Uzi" // 17
    ];
    uint256 constant weaponsLength = 18;

    string[] internal clothes = [
        "White T Shirt", // 0
        "Black T Shirt", // 1
        "White Hoodie", // 2
        "Black Hoodie", // 3
        "Bulletproof Vest", // 4
        "3 Piece Suit", // 5
        "Checkered Shirt", // 6
        "Bikini", // 7
        "Golden Shirt", // 8
        "Leather Vest", // 9
        "Blood Stained Shirt", // 10
        "Police Uniform", // 11
        "Combat Jacket", // 12
        "Basketball Jersey", // 13
        "Track Suit", // 14
        "Trenchcoat", // 15
        "White Tank Top", // 16
        "Black Tank Top", // 17
        "Shirtless", // 18
        "Naked" // 19
    ];
    uint256 constant clothesLength = 20;

    string[] internal vehicle = [
        "Dodge", // 0
        "Porsche", // 1
        "Tricycle", // 2
        "Scooter", // 3
        "ATV", // 4
        "Push Bike", // 5
        "Electric Scooter", // 6
        "Golf Cart", // 7
        "Chopper", // 8
        "Rollerblades", // 9
        "Lowrider", // 10
        "Camper", // 11
        "Rolls Royce", // 12
        "BMW M3", // 13
        "Bike", // 14
        "C63 AMG", // 15
        "G Wagon" // 16
    ];
    uint256 constant vehicleLength = 17;

    string[] internal waistArmor = [
        "Gucci Belt", // 0
        "Versace Belt", // 1
        "Studded Belt", // 2
        "Taser Holster", // 3
        "Concealed Holster", // 4
        "Diamond Belt", // 5
        "D Ring Belt", // 6
        "Suspenders", // 7
        "Military Belt", // 8
        "Metal Belt", // 9
        "Pistol Holster", // 10
        "SMG Holster", // 11
        "Knife Holster", // 12
        "Laces", // 13
        "Sash", // 14
        "Fanny Pack" // 15
    ];
    uint256 constant waistLength = 16;

    string[] internal footArmor = [
        "Black Air Force 1s", // 0
        "White Forces", // 1
        "Air Jordan 1 Chicagos", // 2
        "Gucci Tennis 84", // 3
        "Air Max 95", // 4
        "Timberlands", // 5
        "Reebok Classics", // 6
        "Flip Flops", // 7
        "Nike Cortez", // 8
        "Dress Shoes", // 9
        "Converse All Stars", // 10
        "White Slippers", // 11
        "Gucci Slides", // 12
        "Alligator Dress Shoes", // 13
        "Socks", // 14
        "Open Toe Sandals", // 15
        "Barefoot" // 16
    ];
    uint256 constant footLength = 17;

    string[] internal handArmor = [
        "Rubber Gloves", // 0
        "Baseball Gloves", // 1
        "Boxing Gloves", // 2
        "MMA Wraps", // 3
        "Winter Gloves", // 4
        "Nitrile Gloves", // 5
        "Studded Leather Gloves", // 6
        "Combat Gloves", // 7
        "Leather Gloves", // 8
        "White Gloves", // 9
        "Black Gloves", // 10
        "Kevlar Gloves", // 11
        "Surgical Gloves", // 12
        "Fingerless Gloves" // 13
    ];
    uint256 constant handLength = 14;

    string[] internal necklaces = [
        "Bronze Chain", // 0
        "Silver Chain", // 1
        "Gold Chain" // 2
    ];
    uint256 constant necklacesLength = 3;

    string[] internal rings = [
        "Gold Ring", // 0
        "Silver Ring", // 1
        "Diamond Ring", // 2
        "Platinum Ring", // 3
        "Titanium Ring", // 4
        "Pinky Ring", // 5
        "Thumb Ring" // 6
    ];
    uint256 constant ringsLength = 7;

    string[] internal drugs = [
        "Weed", // 0
        "Cocaine", // 1
        "Ludes", // 2
        "Acid", // 3
        "Speed", // 4
        "Heroin", // 5
        "Oxycontin", // 6
        "Zoloft", // 7
        "Fentanyl", // 8
        "Krokodil", // 9
        "Coke", // 10
        "Crack", // 11
        "PCP", // 12
        "LSD", // 13
        "Shrooms", // 14
        "Soma", // 15
        "Xanax", // 16
        "Molly", // 17
        "Adderall" // 18
    ];
    uint256 constant drugsLength = 19;

    string[] internal suffixes = [
        // <no suffix>          // 0
        "from the Bayou", // 1
        "from Atlanta", // 2
        "from Compton", // 3
        "from Oakland", // 4
        "from SOMA", // 5
        "from Hong Kong", // 6
        "from London", // 7
        "from Chicago", // 8
        "from Brooklyn", // 9
        "from Detroit", // 10
        "from Mob Town", // 11
        "from Murdertown", // 12
        "from Sin City", // 13
        "from Big Smoke", // 14
        "from the Backwoods", // 15
        "from the Big Easy", // 16
        "from Queens", // 17
        "from BedStuy", // 18
        "from Buffalo" // 19
    ];
    uint256 constant suffixesLength = 19;

    string[] internal namePrefixes = [
        // <no name>            // 0
        "OG", // 1
        "King of the Street", // 2
        "Cop Killer", // 3
        "Blasta", // 4
        "Lil", // 5
        "Big", // 6
        "Tiny", // 7
        "Playboi", // 8
        "Snitch boi", // 9
        "Kingpin", // 10
        "Father of the Game", // 11
        "Son of the Game", // 12
        "Loose Trigger Finger", // 13
        "Slum Prince", // 14
        "Corpse", // 15
        "Mother of the Game", // 16
        "Daughter of the Game", // 17
        "Slum Princess", // 18
        "Da", // 19
        "Notorious", // 20
        "The Boss of Bosses", // 21
        "The Dog Killer", // 22
        "The Killer of Dog Killer", // 23
        "Slum God", // 24
        "Candyman", // 25
        "Candywoman", // 26
        "The Butcher", // 27
        "Yung Capone", // 28
        "Yung Chapo", // 29
        "Yung Blanco", // 30
        "The Fixer", // 31
        "Jail Bird", // 32
        "Corner Cockatoo", // 33
        "Powder Prince", // 34
        "Hippie", // 35
        "John E. Dell", // 36
        "The Burning Man", // 37
        "The Burning Woman", // 38
        "Kid of the Game", // 39
        "Street Queen", // 40
        "The Killer of Dog Killers Killer", // 41
        "Slum General", // 42
        "Mafia Prince", // 43
        "Crooked Cop", // 44
        "Street Mayor", // 45
        "Undercover Cop", // 46
        "Oregano Farmer", // 47
        "Bloody", // 48
        "High on the Supply", // 49
        "The Orphan", // 50
        "The Orphan Maker", // 51
        "Ex Boxer", // 52
        "Ex Cop", // 53
        "Ex School Teacher", // 54
        "Ex Priest", // 55
        "Ex Engineer", // 56
        "Street Robinhood", // 57
        "Hell Bound", // 58
        "SoundCloud Rapper", // 59
        "Gang Leader", // 60
        "The CEO", // 61
        "The Freelance Pharmacist", // 62
        "Soccer Mom", // 63
        "Soccer Dad" // 64
    ];
    uint256 constant namePrefixesLength = 64;

    string[] internal nameSuffixes = [
        // <no name>            // 0
        "Feared", // 1
        "Baron", // 2
        "Vicious", // 3
        "Killer", // 4
        "Fugitive", // 5
        "Triggerman", // 6
        "Conman", // 7
        "Outlaw", // 8
        "Assassin", // 9
        "Shooter", // 10
        "Hitman", // 11
        "Bloodstained", // 12
        "Punishment", // 13
        "Sin", // 14
        "Smuggled", // 15
        "LastResort", // 16
        "Contraband", // 17
        "Illicit" // 18
    ];
    uint256 constant nameSuffixesLength = 18;

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function weaponComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "WEAPON", weaponsLength);
    }

    function clothesComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "CLOTHES", clothesLength);
    }

    function vehicleComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "VEHICLE", vehicleLength);
    }

    function waistComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "WAIST", waistLength);
    }

    function footComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "FOOT", footLength);
    }

    function handComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "HAND", handLength);
    }

    function drugsComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "DRUGS", drugsLength);
    }

    function neckComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "NECK", necklacesLength);
    }

    function ringComponents(uint256 tokenId)
        internal
        pure
        returns (uint256[5] memory)
    {
        return pluck(tokenId, "RING", ringsLength);
    }

    function pluck(
        uint256 tokenId,
        string memory keyPrefix,
        uint256 sourceArrayLength
    ) internal pure returns (uint256[5] memory) {
        uint256[5] memory components;

        uint256 rand = random(
            string(abi.encodePacked(keyPrefix, toString(tokenId)))
        );

        components[0] = rand % sourceArrayLength;
        components[1] = 0;
        components[2] = 0;

        uint256 greatness = rand % 21;
        if (greatness > 14) {
            components[1] = (rand % suffixesLength) + 1;
        }
        if (greatness >= 19) {
            components[2] = (rand % namePrefixesLength) + 1;
            components[3] = (rand % nameSuffixesLength) + 1;
            if (greatness == 19) {
                // ...
            } else {
                components[4] = 1;
            }
        }

        return components;
    }

    // TODO: This costs 2.5k gas per invocation. We call it a lot when minting.
    // How can this be improved?
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
