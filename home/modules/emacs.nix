{ config, lib, pkgs, ... }:

let conf = config.srxl.emacs;
in with lib; {
  imports = [ ./fonts.nix ];

  options.srxl.emacs = with types; {
    enable = mkEnableOption "Emacs with my configuration.";

    package = mkOption {
      type = package;
      default = pkgs.emacsPgtk;
      description = "The Emacs package to install.";
    };

    theme = mkOption {
      type = str;
      default = "";
      description = "The name of the Emacs theme to use.";
    };

    useMu4e = mkOption {
      type = bool;
      default = false;
      description = "Whether to use the mu4e email client.";
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
    emacsPkgs = pkgs.emacsPackagesFor conf.package;
    emacsPackage = emacsPkgs.emacsWithPackages
      (e: [ e.vterm ] ++ (lib.optional conf.useMu4e pkgs.mu));

    tangledConfig = pkgs.stdenv.mkDerivation {
      name = "hm-emacs-tangled-config";

      src = ../../config/emacs/config.org;
      phases = "buildPhase installPhase";

      buildPhase = ''
        cp $src config.org
        ${emacsPackage}/bin/emacs --batch -l org --eval "(org-babel-tangle-file \"config.org\")"
      '';

      installPhase = ''
        cp config.el $out
      '';
    };
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
      packages = lib.optional conf.useEXWM
        pkgs.gtk3; # For gtk-launch, used by counsel-linux-app

      file = {
        "init.el" = {
          source = tangledConfig;
          target = ".emacs.d/init.el";
        };

        "config-vars.el" = {
          target = ".emacs.d/config-vars.el";
          text = let
            toBool = b: if b then "t" else "nil";
            shell = if config.programs.fish.enable then
              "/run/current-system/sw/bin/fish"
            else
              "/bin/sh";
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
             srxl/shell-executable "${shell}"
             srxl/use-exwm ${toBool conf.useEXWM})

            ${conf.extraConfig}
          '';
        };
      };
    };
  };
}
