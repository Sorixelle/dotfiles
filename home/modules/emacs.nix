{ config, lib, pkgs, ... }:

let conf = config.srxl.emacs;
in with lib; {
  imports = [ ./fonts.nix ];

  options.srxl.emacs = with types; {
    enable = mkEnableOption "Emacs with my configuration.";

    package = mkOption {
      type = package;
      default = pkgs.emacsGcc;
      description = "The Emacs package to install.";
    };

    theme = mkOption {
      type = str;
      default = "";
      description = "The name of the Emacs theme to use.";
    };

    useEXWM = mkOption {
      type = bool;
      default = false;
      description = "Whether to use the EXWM window manager.";
    };

    extraConfig = mkOption {
      type = lines;
      default = "";
      description = "Extra configuration to add to config-vars.el.";
    };
  };

  config = let
    emacsPkgs = pkgs.emacsPackagesNgGen conf.package;
    emacsPackage = emacsPkgs.emacsWithPackages (e: [ e.vterm ]);
  in mkIf conf.enable {
    programs.emacs = {
      enable = true;
      package = emacsPackage;
    };

    # Vterm shell hooks
    programs = {
      fish.interactiveShellInit = ''
        source ${emacsPkgs.vterm.src}/etc/emacs-vterm.fish
      '';
      bash.initExtra = ''
        source ${emacsPkgs.vterm.src}/etc/emacs-vterm-bash.sh
      '';
      zsh.initExtra = ''
        source ${emacsPkgs.vterm.src}/etc/emacs-vterm-zsh.sh
      '';
    };

    xsession.windowManager.command = mkIf conf.useEXWM ''
      ${emacsPackage}/bin/emacs -mm --debug-init
    '';

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

      packages = lib.optional conf.useEXWM
        pkgs.gtk3; # For gtk-launch, used by counsel-linux-app

      file = {
        ".emacs.d" = {
          source = ../../config/emacs;
          target = ".emacs.d";
          recursive = true;
        };

        "config-vars.el" = {
          target = ".emacs.d/config-vars.el";
          text = let toBool = b: if b then "t" else "nil";
          in ''
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
             srxl/project-dir "~/usr/devel"
             srxl/use-exwm ${toBool conf.useEXWM})

             ${conf.extraConfig}
          '';
        };
      };
    };
  };
}
