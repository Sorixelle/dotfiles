{ config, pkgs, ... }:

{
  imports = [ ./alacritty.nix ./hyprland.nix ./waybar.nix ];

  home.packages = with pkgs; [ fish grim ];

  gtk = with pkgs; {
    enable = true;
    iconTheme = rec {
      name = "Foliage";
      package = pkgs.oomoxPlugins.icons-suruplus-aspromauros.generate {
        inherit name;
        src = ./foliage.oomox-theme;
      };
    };
    theme = rec {
      name = "Foliage";
      package = pkgs.oomoxPlugins.theme-materia.generate {
        inherit name;
        src = ./foliage.oomox-theme;
      };
    };
  };

  programs = {
    eww = {
      enable = true;
      package = pkgs.eww-wayland;
      configDir = ./eww;
    };

    fish = {
      interactiveShellInit = ''
        set -g fish_color_command green
        set -g fish_color_param yellow
        set -g fish_color_redirection cyan
        set -g fish_color_end blue
        set -g fish_color_quote magenta
        set -g fish_color_error red
      '';
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  services = {
    wired = {
      enable = true;
      config = ./wired.ron;
    };
  };

  srxl = {
    emacs.theme = "doom-henna";

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

    starship.styles = {
      directory = "bg:black";
      directoryReadOnly = "fg:red bg:black";
      elixir = "bg:purple";
      git = "bg:green";
      hostname = "bg:blue";
      nix = "bg:cyan";
      time = "white";
    };
  };

  xdg.configFile = {
    "tofi/config" = {
      text = ''
        font = ${config.srxl.fonts.ui.name}
        font-size = ${toString config.srxl.fonts.ui.size}
        background-color = #121E1DC0
        border-color = #40772B
        text-color = #DFE4F3
        selection-color = #40772B
        border-width = 3
        outline-width = 0
      '';
    };
  };
}