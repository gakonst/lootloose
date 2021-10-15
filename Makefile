all: update patch solc

install: npm patch

# dapp deps
update:; dapp update

# npm deps for linting etc.
npm:; yarn install

# apply patches or let it fail gracefully
patch:; git apply patches/* || true

# install solc version
# example to install other versions: `make solc 0_8_2`
SOLC_VERSION := 0_8_6
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_${SOLC_VERSION}

# Build & test
build  :; dapp build
test   :; dapp test --ffi
clean  :; dapp clean
lint   :; yarn run lint

# returns the URL to deploy to a hosted Alchemy node
# requires the API_KEY env var to be set
# the first argument determines the network
define network
	https://eth-$1.alchemyapi.io/v2/${API_KEY}
endef

# Deployment helpers
deploy :; @./scripts/deploy.sh

# mainnet
deploy-mainnet: export ETH_RPC_URL = $(call network,mainnet)
deploy-mainnet: deploy

# rinkeby
deploy-rinkeby: export ETH_RPC_URL = $(call network,rinkeby)
deploy-rinkeby: deploy
