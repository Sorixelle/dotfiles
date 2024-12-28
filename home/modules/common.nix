{ ... }:

{
  imports = [
    ./emacs.nix
    ./email.nix
    ./fonts.nix
  ];

  config.home.file.nixpkgs = {
    source = ../../nixpkgs;
    target = ".config/nixpkgs";
    recursive = true;
  };
}
