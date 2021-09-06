#  default to localhost
RPC_URL=${ETH_RPC_URL:-http://localhost:8545}

deploy() {
    NAME=$1
    SIG=$2
    ARGS=${@:3}

    # get the bytecode from the compiled file
    PATTERN=".contracts[\"src/$NAME.sol\"].$NAME.evm.bytecode.object"
    BYTECODE=0x$(cat out/dapp.sol.json | jq -r "$PATTERN")

    # estimate gas
    GAS=$(seth estimate --create $BYTECODE $SIG $ARGS --rpc-url $RPC_URL --from $FROM)

    # deploy
    ADDRESS=$(dapp create $NAME $ARGS -- --rpc-url $RPC_URL --from $FROM --gas $GAS)
    echo $ADDRESS
}

# Mainnet loot address
MAINNET_LOOT=0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7

# Default to it if nothing is provided
LOOT="${LOOT:-$MAINNET_LOOT}"

# Deploy.
LootLooseAddr=$(deploy LootLoose 'LootLoose(address)' $LOOT)
echo "LootLoose deployed at", $LootLooseAddr
