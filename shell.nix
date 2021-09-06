let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "ecf5a5313d62fbcf4bf66ee306f6e0eb9a7aea23";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "lootloose";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }
