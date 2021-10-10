{ config, lib, pkgs, ... }:

let conf = config.srxl.theme.onedark;
in {
  imports = [ ../../modules/fonts.nix ];

  options.srxl.theme.onedark = with lib; {
    enable = mkEnableOption "the onedark system theme for this user";
  };

  config = lib.mkIf conf.enable {
    gtk = with pkgs; {
      enable = true;
      iconTheme = {
        name = "Arc";
        package = arc-icon-theme;
      };
      theme = {
        name = "Arc-Dark";
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
    };

    srxl = {
      emacs = {
        enable = true;
        theme = "doom-one";
        useEXWM = true;
      };

      fonts = {
        monospace = {
          name = "Blex Mono NerdFont";
          size = 12;
          package = pkgs.nerdfonts.override { fonts = [ "IBMPlexMono" ]; };
        };
        ui = {
          name = "IBM Plex Sans";
          size = 12;
          package = pkgs.ibm-plex;
        };
        serif = {
          name = "IBM Plex Serif";
          size = 12;
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
    };

    xsession = {
      enable = true;
      scriptPath = ".xsession-hm";
    };
  };
}
