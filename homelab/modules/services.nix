{ config, lib, nixpkgs, nodes, ... }:

let
  inherit (lib) types mkOption literalExample;
  conf = config.srxl.services;
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

  config = {
    # Configures Nginx services
    # TODO: handle services where isHttp == false (plain tcp streams)
    services.nginx = let
      wireguardIP =
        builtins.head config.networking.wg-quick.interfaces.wg0.address;
    in {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      enableReload = true;

      # Allow reading real source addresses from both Wireguard IP addresses,
      # and read the real IP from PROXY protocol
      commonHttpConfig = let
        gatewayWireguardIP = builtins.head
          nodes.gateway.config.networking.wg-quick.interfaces.wg0.address;
      in ''
        set_real_ip_from ${wireguardIP};
        set_real_ip_from ${gatewayWireguardIP};
        real_ip_header proxy_protocol;
      '';

      # Define HTTP(S) servers
      # All services use PROXY protocol, so they can read the correct source IP
      # address into X-Forwarded-For, etc. The gateway machine will proxy
      # requests directly to these servers.
      virtualHosts = builtins.mapAttrs (name: service: {
        inherit (service) locations;
        serverName = "${name}.gemstonelabs.cloud";
        listen = [
          {
            addr = wireguardIP;
            port = 800;
            extraParameters = [ "proxy_protocol" ];
          }
          {
            addr = wireguardIP;
            port = 4430;
            ssl = true;
            extraParameters = [ "proxy_protocol" ];
          }
        ];
        forceSSL = true;
        enableACME = true;
      }) conf.http;

      # Define plain TCP stream servers
      # Used to accept regular HTTP(S) traffic from the local network, and wrap
      # it in PROXY protocol so they can be sent to the actual servers defined
      # above.
      streamConfig = let localIP = config.deployment.targetHost;
      in ''
        server {
          listen ${localIP}:80;
          proxy_protocol on;
          proxy_pass ${wireguardIP}:800;
        }
        server {
          listen ${localIP}:443;
          proxy_protocol on;
          proxy_pass ${wireguardIP}:4430;
        }
      '';
    };

    # Allow incoming traffic to both regular and PROXY protocol routes
    networking.firewall.allowedTCPPorts = [ 80 443 800 4430 ];
  };
}
