# DappTools Guide

## Installing Dependencies


`dapp install https://github.com/OpenZeppelin/openzeppelin-contracts`

Always have a `.dapprc` with your configs


## Installing 

nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_6


# When is it worth having a shell.nix?

https://github.com/dapp-org/radicle-contracts-tests/blob/master/shell.nix

# Swithc to versions of your choice

https://github.com/Rari-Capital/duppgrade

# Solc version

Need to install custom version to last

# Patches

IF you want to patch your deps, you must also add `ignore = dirty` to its corresponding
`.gitmodules`, e.g.

```
[submodule "lib/openzeppelin-contracts"]
    path = lib/openzeppelin-contracts
    url = https://github.com/OpenZeppelin/openzeppelin-contracts
    ignore = dirty
```

https://stackoverflow.com/a/5542452

# gitattributes

Highlight Shell for dapprc

.dapprc linguist-language=Shell

