{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    font = "Inter 12";
    location = "center";
    terminal = "${config.programs.kitty.package}/bin/kitty";
  };
}
