{ pkgs, ... }:

{
  imports = [ ./alacritty.nix ./hyprland.nix ];

  home.packages = with pkgs; [ fish ];

  programs = {
    # TODO: replace with nushell
    fish = let
      bobthefish = pkgs.fetchFromGitHub {
        owner = "oh-my-fish";
        repo = "theme-bobthefish";
        rev = "12b829e0bfa0b57a155058cdb59e203f9c1f5db4";
        sha256 = "00by33xa9rpxn1rxa10pvk0n7c8ylmlib550ygqkcxrzh05m72bw";
      };
    in {
      plugins = [{
        name = "bobthefish";
        src = bobthefish;
      }];
      interactiveShellInit = ''
        set -g theme_nerd_fonts yes
        set -g theme_color_scheme terminal-light

        set -g fish_color_command brcyan
        set -g fish_color_param brmagenta
        set -g fish_color_redirection brgreen
        set -g fish_color_end brblue
        set -g fish_color_quote bryellow
        set -g fish_color_error brred

        set -g VIRTUAL_ENV_DISABLE_PROMPT 1

        for f in ${bobthefish}/*.fish
          source $f
        end
      '';
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  # TODO: change pretty much everything here
  srxl = {
    emacs = {
      enable = true;
      theme = "doom-henna";
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
      serif = {
        name = "IBM Plex Serif";
        package = pkgs.ibm-plex;
        size = 12;
      };
      extraFonts = with pkgs; [ emacs-all-the-icons-fonts noto-fonts-cjk ];
    };
  };
}
