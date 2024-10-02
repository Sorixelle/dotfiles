{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cifs-utils;
in
{
  options.programs.cifs-utils = with lib; {
    enable = mkEnableOption "the cifs-utils packages for mounting SMB shares.";

    package = mkOption {
      type = types.package;
      default = pkgs.cifs-utils;
      description = ''
        The cifs-utils package to use.
      '';
    };

    idmapPlugin = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "${pkgs.sssd}/lib/cifs-utils/cifs_idmap_sss.so";
      description = ''
        Path to the idmap plugin used to convert SIDs to Unix UID/GIDs.

        Only used when mounting a share with the cifsacl option.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."cifs-utils/idmap-plugin".source = lib.mkIf (
      cfg.idmapPlugin != null
    ) cfg.idmapPlugin;

    programs.keyutils = {
      enable = true;
      keyPrograms = [
        {
          op = "create";
          type = "cifs.spnego";
          command = "${cfg.package}/bin/cifs.upcall %k";
        }
        {
          op = "create";
          type = "cifs.idmap";
          command = "${cfg.package}/bin/cifs.idmap %k";
        }
      ];
    };
  };
}
