{ config, lib, pkgs, ... }:

let conf = config.srxl.emacs;
in with lib; {
  imports = [ ./fonts.nix ];

  options.srxl.emacs = with types; {
    enable = mkEnableOption "Emacs with my configuration.";

    package = mkOption {
      type = package;
      default = pkgs.emacsPgtkGcc;
      description = "The Emacs package to install.";
    };

    theme = mkOption {
      type = str;
      default = "";
      description = "The name of the Emacs theme to use.";
    };

    extraConfig = mkOption {
      type = lines;
      default = "";
      description = "Extra configuration to add to config-vars.el.";
    };
  };

  config = mkIf conf.enable {
    programs.emacs = {
      enable = true;
      package = with pkgs;
        (emacsPackagesNgGen conf.package).emacsWithPackages
        (epkgs: [ epkgs.vterm ]);
    };

    home = {
      # Emacs doesn't regenerate the tangled config on changes because of the
      # symlinks home-manager creates to the config. So we clear the cached
      # version ourselves here.
      activation.clearTangledConfig = hm.dag.entryAfter [ "writeBoundary" ] ''
        CONFIG_FILE=$HOME/.emacs.d/config.el
        if [ -f "$CONFIG_FILE" ]; then
          $DRY_RUN_CMD rm $VERBOSE_ARG "$CONFIG_FILE"
        fi
      '';

      file = {
        ".emacs.d" = {
          source = ../../config/emacs;
          target = ".emacs.d";
          recursive = true;
        };

        "config-vars.el" = {
          target = ".emacs.d/config-vars.el";
          text = ''
            (setq
             srxl/font-family-monospace "${config.srxl.fonts.monospace.name}"
             srxl/font-size-monospace "${
               toString config.srxl.fonts.monospace.size
             }"
             srxl/font-family-ui "${config.srxl.fonts.ui.name}"
             srxl/font-size-ui ${toString (config.srxl.fonts.ui.size * 10)}
             srxl/font-family-serif "${config.srxl.fonts.serif.name}"
             srxl/font-size-serif ${
               toString (config.srxl.fonts.serif.size * 10)
             }
             srxl/theme-name '${conf.theme}
             srxl/project-dir "~/usr/devel")

             ${conf.extraConfig}
          '';
        };
      };
    };
  };
}
