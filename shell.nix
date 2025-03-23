let
  pkgs = import ./nixpkgs;

  commit-hooks = import ./commit-hooks.nix { inherit pkgs; };
in

pkgs.mkShell {
  name = "srxl-dotfiles";

  packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    npins
  ];

  shellHook = ''
    ${commit-hooks.shellHook}
  '';
}
