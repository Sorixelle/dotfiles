{ ... }:

{
  imports = [
    ./emacs.nix
    ./email.nix
    ./fonts.nix
  ];

  # Place the repo's nixpkgs config in the globally-accessible location
  xdg.configFile."nixpkgs/config.nix".source = ../../nixpkgs/config.nix;
}
