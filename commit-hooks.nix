let
  sources = import ./npins;
  git-hooks = import sources.git-hooks;
in

{ pkgs }:

git-hooks.run {
  src = builtins.path {
    path = ./.;
    name = "dotfiles";
  };

  hooks = {
    nixfmt-rfc-style.enable = true;
    statix.enable = true;
  };

  tools = {
    inherit (pkgs) nixfmt-rfc-style statix;
  };
}
