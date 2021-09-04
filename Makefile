# dapp deps
update:; dapp update

# Install dependencies & apply patches
install :; make npm && make patch && make solc
npm:; yarn install

# apply patches or let it fail gracefully
patch:; git apply patches/* || true

# install solc version
# example to install other versions: `make solc 0_8_2`
SOLC_VERSION := 0_8_6
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_${SOLC_VERSION}

# Build & test
all    :; make build && make test
build  :; dapp build
test   :; dapp test
clean  :; dapp clean
lint:; yarn run lint
