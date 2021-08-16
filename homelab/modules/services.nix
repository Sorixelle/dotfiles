{ config, lib, nixpkgs, nodes, ... }:

let
  inherit (lib) types mkOption literalExample;
  conf = config.srxl.services;
  service = types.submodule {
    options = {
      port = mkOption {
        type = types.port;
        description = "The port the service listens on.";
        example = 443;
      };
      isHttp = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the service is a HTTP(S) server.";
        example = false;
      };
      locations = mkOption {
        type = types.attrsOf (types.submodule (import
          "${nixpkgs}/nixos/modules/services/web-servers/nginx/location-options.nix" {
            inherit lib;
          }));
        default = { };
        description = ''
          Location blocks to add to Nginx config for the service.
          Identical to <literal>services.nginx.virtualHosts.<name>.locations</literal>.
        '';
      };
    };
  };
in {
  options = {
    srxl.services = mkOption {
      type = types.attrsOf service;
      description = ''
        A list of services that will be mapped from gateway to opal-entrypoint.
        Each service will have 2 mappings on opal-entrypoint - one regular one
        for access from the local network, and another PROXY protocol enabled
        one for access from gateway while preserving source IP addresses. The
        attribute name will become the server name subdomain in the Nginx config,
        if <literal>isHttp</literal> is set to <literal>true</literal>.
      '';
      example = literalExample ''
        {
          service = {
            port = 443;
            destination = "192.168.1.123";
          };
        }
      '';
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
      virtualHosts = let httpServices = (lib.filterAttrs (_: s: s.isHttp) conf);
      in builtins.mapAttrs (name: service: {
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
      }) httpServices;

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
