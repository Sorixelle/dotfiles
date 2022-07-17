{ config, lib, pkgs, ... }:

let conf = config.srxl.theme.witchery;
in {
  imports = [ ./alacritty.nix ./picom.nix ];

  options.srxl.theme.witchery = with lib; {
    enable = mkEnableOption "the witchery system theme for this user";
  };

  config = lib.mkIf conf.enable {
    gtk = with pkgs; {
      enable = true;
      iconTheme = rec {
        name = "witchery";
        package = pkgs.oomoxPlugins.theme-oomox.generate {
          inherit name;
          src = ./witchery.oomox-theme;
        };
      };
      theme = rec {
        name = "witchery";
        package = pkgs.oomoxPlugins.icons-numix.generate {
          inherit name;
          src = ./witchery.oomox-theme;
        };
      };
    };

    home.packages = [ pkgs.dmenu pkgs.maim ];

    programs = {
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

    srxl = {
      emacs = {
        enable = true;
        theme = "doom-nord-light";
      };

      fonts = {
        monospace = {
          name = "Blex Mono NerdFont";
          package = pkgs.nerdfonts.override { fonts = [ "IBMPlexMono" ]; };
        };
        ui = {
          name = "Inter";
          package = pkgs.inter;
        };
        serif = {
          name = "IBM Plex Serif";
          package = pkgs.ibm-plex;
        };
        extraFonts = with pkgs; [ emacs-all-the-icons-fonts noto-fonts-cjk ];
      };
    };

    services = {
      # dunst = import ./dunst.nix config pkgs;

      # polybar = import ./polybar.nix config pkgs;

      # sxhkd = import ./sxhkd.nix;
    };

    xsession = {
      enable = true;
      scriptPath = ".xsession-hm";

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };

    home.file = {
      ".background-image" = {
        source = ./wp.png;
        target = ".background-image";
      };
    };
  };
}
