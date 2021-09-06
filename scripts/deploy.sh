# import helpers
# TODO: Can we make this import work from any directory?
. ./scripts/common.sh

# Setup addresses file
cat > "$ADDRESSES_FILE" <<EOF
{
    "DEPLOYER": "$(seth --to-checksum-address "$FROM")"
}
EOF

# Mainnet loot address
MAINNET_LOOT=0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7
# Default to it if nothing is provided
LOOT="${LOOT:-$MAINNET_LOOT}"

# Deploy.
LootLooseAddr=$(deploy LootLoose $LOOT)
log "LootLoose deployed at:" $LootLooseAddr
