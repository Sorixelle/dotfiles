let
  sources = import ./npins;

  pkgs = import sources.nixpkgs {
    config = import ./nixpkgs/config.nix;
  };

  npins-latest = import (pkgs.fetchzip {
    url = "https://github.com/andir/npins/archive/refs/heads/master.tar.gz";
    hash = "sha256-/FTE/lDICJnXr4JbxaA+9mwM0sSF5++/XaYR+S2pFdA=";
  }) { };

  commit-hooks = import ./commit-hooks.nix { inherit pkgs; };
in

pkgs.mkShell {
  name = "srxl-dotfiles";

  packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    npins-latest
  ];

  shellHook = ''
    ${commit-hooks.shellHook}
  '';
}
