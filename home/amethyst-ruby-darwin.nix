{ pkgs, ... }:

{
  imports = [ ./modules/common-darwin.nix ];

  home.packages = with pkgs; [ gnupg ];

  programs = {
    fish.enable = true;

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      lfs.enable = true;
      userEmail = "ruby@srxl.me";
      userName = "Ruby Iris Juric";
      signing = {
        key = "12BFCA4D4B2EE0EB";
        signByDefault = true;
      };
    };
  };

  srxl = {
    emacs = {
      enable = true;
      theme = "doom-dracula";
    };

    fonts = {
      monospace = {
        name = "BlexMono Nerd Font";
        package = pkgs.nerdfonts.override { fonts = [ "IBMPlexMono" ]; };
        size = 12;
      };
      ui = {
        name = "Inter";
        package = pkgs.inter;
        size = 12;
      };
      extraFonts = with pkgs; [ emacs-all-the-icons-fonts ];
    };
  };

  home.stateVersion = "21.05";
}
