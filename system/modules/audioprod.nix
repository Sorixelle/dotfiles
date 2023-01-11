{ config, pkgs, lib, ... }:

let conf = config.srxl.audioprod;
in {
  options.srxl.audioprod = {
    enable = lib.mkEnableOption
      "tools and other configuration for audio production/editing";

    user = lib.mkOption {
      type = lib.types.str;
      default = "ruby";
      description = "The name of the user that will be using audio tools.";
    };
  };

  config = lib.mkIf conf.enable {
    musnix = {
      enable = true;
      kernel = {
        realtime = true;
        packages = pkgs.linuxPackages_latest_rt;
      };
    };

    security.rtkit.enable = true;

    users.users.${conf.user}.extraGroups = [ "audio" ];

    services.pipewire.config = {
      pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 32;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 64;
        };
        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
            flags = [ "ifexists" "nofail" ];
          }
          { name = "libpipewire-module-protocol-native"; }
          { name = "libpipewire-module-profiler"; }
          { name = "libpipewire-module-metadata"; }
          { name = "libpipewire-module-spa-device-factory"; }
          { name = "libpipewire-module-spa-node-factory"; }
          { name = "libpipewire-module-client-node"; }
          { name = "libpipewire-module-client-device"; }
          {
            name = "libpipewire-module-portal";
            flags = [ "ifexists" "nofail" ];
          }
          {
            name = "libpipewire-module-access";
            args = { };
          }
          { name = "libpipewire-module-adapter"; }
          { name = "libpipewire-module-link-factory"; }
          { name = "libpipewire-module-session-manager"; }
        ];
      };
    };

    home-manager.users.${conf.user}.home.packages = with pkgs; [
      ardour

      calf
      distrho
      geonkick
      gxplugins-lv2
      lsp-plugins
      odin2
      wolf-shaper
      zyn-fusion
    ];
  };
}
