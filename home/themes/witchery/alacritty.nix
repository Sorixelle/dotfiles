{ config, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window.padding = {
        x = 20;
        y = 20;
      };
      font = {
        normal.family = config.srxl.fonts.monospace.name;
        size = config.srxl.fonts.monospace.size;
      };
    };
  };
}
