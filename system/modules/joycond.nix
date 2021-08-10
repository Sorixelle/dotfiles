{ config, lib, pkgs, ... }:

with lib;
let conf = config.services.srxl.joycond;
in {
  options.services.srxl.joycond = {
    enable = mkEnableOption "joycond Nintendo Switch controller daemon.";
  };

  config = mkIf conf.enable {
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [ hid-nintendo ];
      kernelModules = [ "hid-nintendo" "ledtrig-timer" ];
    };

    environment.systemPackages = [ pkgs.joycond ];

    systemd.services.joycond = {
      description = "joycond Nintendo Switch controller daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.joycond}/bin/joycond";
        WorkingDirectory = "/root";
        StandardInput = "inherit";
        StandardOutput = "inherit";
        Restart = "always";
        User = "root";
      };
    };
  };
}
