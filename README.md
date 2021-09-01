# <h1 align="center"> Loot Unchained </h1>

**Open your Loot bags and see what's inside**

![Github Actions](https://github.com/gakonst/loot-unchained/workflows/Tests/badge.svg)

Loots Unchained is an ERC-1155 contract which allows you to:
1. Open your [Loot bags](https://www.lootrng.com/) and mint 8 ERC-1155 tokens, corresponding to each item
in the bag
2. Re-assemble your ERC721 bag by giving back the ERC-1155 tokens to the contract

Each ERC1155's token URI is a b64 encoded SVG image, with the item's name (just that item's, not
any other item from the bag that contained it).

You can mint the 8 ERC-1155 tokens via 2 ways:
1. `approve` the `LootUnchained.sol` contract to spend your NFT (or via `setApprovalForAll`)
2. Transferring your NFT directly to the contract, triggerring the `onERC721Received` callback

## Run locally

```bash
# Install dependencies
yarn

# Optional: compile contracts
yarn compile

# Run tests
yarn test
```

### Security Notes

* In order to improve gas efficiency, OZ's ERC1155.sol was patched to expose the `_balances`
mapping. We use that to do a batch mint inside `open`.
* Dom's original [LootComponents](https://twitter.com/dhof/status/1432403895008088064) was modified
to be cheaper to use, since it did a lot of redundant `SLOAD`s in hot code paths.
