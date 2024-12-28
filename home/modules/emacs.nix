{
  config,
  lib,
  pkgs,
  ...
}:

let
  conf = config.srxl.emacs;
in
with lib;
{
  imports = [ ./fonts.nix ];

  options.srxl.emacs = with types; {
    enable = mkEnableOption "Emacs with my configuration.";

    server.enable = mkEnableOption "Emacs daemon on systes startup.";

    package = mkOption {
      type = package;
      default = pkgs.emacs-unstable;
      description = "The Emacs package to install.";
    };

    theme = mkOption {
      type = str;
      default = "";
      description = "The name of the Emacs theme to use.";
    };

    emailAddress = mkOption {
      type = str;
      default = "";
      description = "The email to use in Emacs.";
    };

    extraConfig = mkOption {
      type = lines;
      default = "";
      description = "Extra configuration to add to config-vars.el.";
    };
  };

  config =
    let
      emacsPkgs = pkgs.emacsPackagesFor conf.package;
      emacsPackage = emacsPkgs.emacsWithPackages (
        e: [ e.treesit-grammars.with-all-grammars ] ++ (lib.optional config.srxl.email.enable e.mu4e)
      );

      tangledConfig = pkgs.stdenv.mkDerivation {
        name = "hm-emacs-tangled-config";

        src = ../../config/emacs-config.org;
        phases = "buildPhase installPhase";

        buildPhase = ''
          cp $src config.org
          ${emacsPackage}/bin/emacs --batch -l org --eval "(org-babel-tangle-file \"config.org\")"
        '';

        installPhase = ''
          cp -a out $out
        '';
      };
    in
    mkIf conf.enable {
      programs.emacs = {
        enable = true;
        package = emacsPackage;
      };

      services.emacs = mkIf conf.server.enable {
        enable = true;
        client.enable = true;
        defaultEditor = true;
        startWithUserSession = "graphical";
      };

      home.file = {
        ".emacs.d" = {
          source = tangledConfig;
          recursive = true;
          target = ".emacs.d/";
        };

        "config-vars.el" = {
          target = ".emacs.d/config-vars.el";
          text =
            let
              toBool = b: if b then "t" else "nil";
            in
            ''
              (setq
               srxl/font-family-monospace "${config.srxl.fonts.monospace.name}"
               srxl/font-size-monospace "${toString config.srxl.fonts.monospace.size}"
               srxl/font-family-ui "${config.srxl.fonts.ui.name}"
               srxl/font-size-ui ${toString (config.srxl.fonts.ui.size * 10)}
               srxl/theme-name '${conf.theme}
               srxl/use-mu4e ${toBool config.srxl.email.enable}
               srxl/email "${conf.emailAddress}")

              ${conf.extraConfig}
            '';
        };
      };
    };
}
