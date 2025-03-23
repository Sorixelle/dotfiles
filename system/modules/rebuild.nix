{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.srxl.rebuild;
in
{
  options.srxl.rebuild = {
    configLocation = lib.mkOption {
      type = lib.types.str;
      default = "/home/ruby/nixos";
      example = "/etc/nixos";
      description = "Path to where the NixOS configuration repo is checked out on this system.";
    };
  };

  config = {
    environment.systemPackages = [ pkgs.rebuild ];

    environment.variables.REBUILD_CHECKOUT_PATH = cfg.configLocation;
  };
}
