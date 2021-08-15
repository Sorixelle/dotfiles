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
    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      enableReload = true;

      # Allow real IP replacement addresses to come from Wireguard
      commonHttpConfig = ''
        set_real_ip_from ${
          builtins.head
          nodes.gateway.config.networking.wg-quick.interfaces.wg0.address
        };
      '';

      virtualHosts = let
        inherit (builtins) head mapAttrs;
        inherit (lib) mapAttrs' nameValuePair;
        httpServices = (lib.filterAttrs (_: s: s.isHttp) conf);

        # Create server definitions that do all the actual routing to services
        # Local connections will hit these, as well as the PROXY protocol
        # definitions doing their proxy_pass
        regularServers = mapAttrs (subdomain: service: {
          inherit (service) locations;
          serverName = "${subdomain}.gemstonelabs.cloud";
          listen = [{
            inherit (service) port;
            addr = config.deployment.targetHost;
          }];
        }) httpServices;

        # Create server definitions that accept PROXY protocol, read the real IP
        # from requests, then proxy_pass over to the regular definitions above
        proxyProtocolServers = mapAttrs' (subdomain: service:
          nameValuePair "${subdomain}-pp" {
            serverName = "${subdomain}.gemstonelabs.cloud";
            listen = [{
              port = service.port * 10;
              addr = head config.networking.wg-quick.interfaces.wg0.address;
              extraParameters = [ "proxy_protocol" ];
            }];
            extraConfig = ''
              real_ip_header proxy_protocol;

              location / {
                proxy_pass http://${config.deployment.targetHost}:${
                  toString service.port
                };
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $proxy_protocol_addr;
                proxy_set_header X-Forwarded-For $proxy_protocol_addr;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Server $host;
              }
            '';
          }) httpServices;
      in regularServers // proxyProtocolServers;
    };

    # Allow incoming traffic to both regular and PROXY protocol routes
    networking.firewall.allowedTCPPorts = lib.unique
      (builtins.concatMap (p: [ p (p * 10) ])
        (lib.mapAttrsToList (_: s: s.port) config.srxl.services));
  };
}
