GREEN='\033[0;32m'
NC='\033[0m' # No Color

export OUT_DIR=${OUT_DIR:-$PWD/out}
ADDRESSES_FILE="$OUT_DIR/addresses.json"
export CONFIG_FILE="${OUT_DIR}/config.json"

# loads addresses as key-value pairs from $ADDRESSES_FILE and exports them as
# environment variables.
loadAddresses() {
    local keys

    keys=$(jq -r "keys_unsorted[]" "$ADDRESSES_FILE")
    for KEY in $keys; do
        VALUE=$(jq -r ".$KEY" "$ADDRESSES_FILE")
        export "$KEY"="$VALUE"
    done
}

# concatenates the args with a comma
join() {
    local IFS=","
    echo "$*"
}

log() {
    printf '%b\n' "${GREEN}${*}${NC}"
    echo ""
}

toUpper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

toLower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}
