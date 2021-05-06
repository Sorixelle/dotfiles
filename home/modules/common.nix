{ ... }:

{
  imports = [
    ./emacs.nix
    ./fonts.nix
    ../themes/winter
  ];

  config = {
    home = {
      file = {
        "nixpkgs" = {
          source = ../../nixpkgs;
          target = ".config/nixpkgs";
          recursive = true;
        };
        "pls" = {
          source = ../../config/pls;
          target = ".local/bin/pls";
          executable = true;
        };
      };

      sessionPath = [ "$HOME/.local/bin" ];
    };
  };
}
