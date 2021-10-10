{ config, lib, pkgs, ... }:

let conf = config.srxl.theme.winter;
in {
  imports = [ ../../modules/fonts.nix ];

  options.srxl.theme.winter = with lib; {
    enable = mkEnableOption "the winter system theme for this user";

    monitors = with types;
      mkOption {
        type = listOf string;
        default = [ ];
        description = "List of monitor names.";
      };
  };

  config = lib.mkIf conf.enable {
    gtk = with pkgs; {
      enable = true;
      iconTheme = {
        name = "Arc";
        package = arc-icon-theme;
      };
      theme = {
        name = "Arc-Lighter";
        package = arc-theme;
      };
    };

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

          set -g fish_color_command blue
          set -g fish_color_param cyan
          set -g fish_color_redirection cyan
          set -g fish_color_end green
          set -g fish_color_quote yellow
          set -g fish_color_error red

          set -g VIRTUAL_ENV_DISABLE_PROMPT 1

          for f in ${bobthefish}/*.fish
            source $f
          end
        '';
      };

      kitty = import ./kitty.nix config;

      rofi = import ./rofi.nix config;
    };

    srxl = {
      emacs = { theme = "doom-nord-light"; };

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
      dunst = import ./dunst.nix config pkgs;

      picom = {
        enable = true;
        experimentalBackends = true;
        fade = true;
        fadeDelta = 2;
        vSync = true;
      };

      polybar = import ./polybar.nix config pkgs;

      sxhkd = import ./sxhkd.nix;
    };

    xsession = {
      enable = true;
      scriptPath = ".xsession-hm";

      windowManager.bspwm = import ./bspwm.nix lib conf;
    };

    home.file = {
      ".background-image" = {
        source = ./winter.png;
        target = ".background-image";
      };
    };
  };
}
