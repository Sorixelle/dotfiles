{ lib, nixpkgs, ... }:

let
  inherit (lib) types mkOption;
  httpService = types.submodule {
    options = {
      locations = mkOption {
        type = types.attrsOf (types.submodule (import
          "${nixpkgs}/nixos/modules/services/web-servers/nginx/location-options.nix" {
            inherit lib;
          }));
        default = { };
        description = ''
          Location blocks to add to Nginx config for the service.
          Identical to `services.nginx.virtualHosts.<name>.locations`.
        '';
      };
    };
  };
in {
  options = {
    srxl.services = {
      http = mkOption {
        type = types.attrsOf httpService;
        default = { };
        description = ''
          An attribute set containing definitions for HTTP(S) services.

          For each entry in the set, entries in the Nginx config on
          opal-entrypoint will be created to accept HTTPS traffic from both the
          local network and the gateway VPN, as well as redirect HTTP traffic to
          HTTPS. SSL certificates are automatically generated from Let's
          Encrypt. Each service's attribute name will be used to determine the
          server_name for the Nginx config entries (eg. key "foobar" will become
          "foobar.gemstonelabs.cloud").
        '';
      };
    };
  };
}
