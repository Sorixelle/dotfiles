{ config, lib, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.activation.linkApps = let
    apps = pkgs.buildEnv {
      name = "hm-apps";
      paths = config.home.packages;
      pathsToLink = "/Applications";
    };
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/Applications/Home Manager Apps"
    $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync ''${VERBOSE_ARG:+-v} \
      -ac --chmod=-w --copy-unsafe-links --delete \
      "${apps}/Applications/" \
      "$HOME/Applications/Home Manager Apps"
  '';
}
