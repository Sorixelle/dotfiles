{ config, lib, ... }:

let
  conf = config.srxl.fonts;

  fontSpecType = with lib;
    types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Name of the font family within the specified package.";
        };
        package = mkOption {
          type = types.nullOr types.package;
          description = "Package providing the specified font.";
        };
        size = mkOption {
          type = types.ints.positive;
          description = "Size of the font.";
          default = 10;
        };
      };
    };
in with lib; {
  options.srxl.fonts = {
    monospace = mkOption {
      type = fontSpecType;
      description = "The monospace font to use in the system.";
    };

    ui = mkOption {
      type = fontSpecType;
      description = "The UI font to use in the system. Usually variable-width.";
    };

    extraFonts = with types;
      mkOption {
        type = listOf package;
        default = [ ];
        description = "Any extra fonts to install.";
      };
  };

  config = {
    fonts.fontconfig.enable = true;

    gtk.font.name = conf.ui.name;

    home.packages = [ conf.monospace.package conf.ui.package ]
      ++ conf.extraFonts;
  };
}
