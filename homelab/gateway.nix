let publicIP = "170.75.170.152";
in { config, lib, nodes, ... }: {
  imports = [ ./hardware/gateway.nix ];

  # Set deployment IP
  deployment.targetHost = publicIP;

  # Read and deploy secrets from sops yaml
  sops = {
    defaultSopsFile = ../secrets/gateway.yaml;
    secrets.wg_server_privkey = { };
  };

  # Configure GRUB for booting
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  # Enable IP forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking = {
    # Set hostname
    hostName = "gemstonelabs-gateway";

    # Use DHCP for internet interface
    interfaces.ens3.useDHCP = true;

    # Setup a Wireguard interface
    wg-quick.interfaces.wg0 = {
      # Address of wg0 on server
      address = [ "192.168.50.1" ];
      # Private key - file created by sops-nix
      privateKeyFile = "/run/secrets/wg_server_privkey";
      # Port for Wireguard to listen on
      listenPort = 51820;
      peers = [{
        # Public key of Wireguard client
        publicKey = "vDEUGgshzIOQeBEThkyrBbAZlLMeTl9x6PL1FKmv6DA=";
        # IP of Wireguard client interface
        allowedIPs = [ "192.168.50.2/32" ];
      }];
    };

    firewall = {
      # Open Wireguard port
      allowedUDPPorts =
        [ config.networking.wg-quick.interfaces.wg0.listenPort ];
      # Open ports for all services opal-entrypoint defines
      allowedTCPPorts = lib.mapAttrsToList (_: s: s.port)
        nodes.opal-entrypoint.config.srxl.services;
    };
  };

  # Configure HAProxy to forward incoming traffic over Wireguard with PROXY protocol
  services.haproxy = let
    inherit (builtins) any concatStringsSep foldl' head;
    inherit (lib) concatMapStringsSep mapAttrsToList;
    wgIP = head
      nodes.opal-entrypoint.config.networking.wg-quick.interfaces.wg0.address;
    # Names and ports of all services, with duplicate ports filtered
    uniquePorts = foldl' (acc: curr:
      if any (e: curr.port == e.port) acc then acc else acc ++ [ curr ]) [ ]
      (mapAttrsToList (name: s: {
        inherit name;
        inherit (s) port;
      }) nodes.opal-entrypoint.config.srxl.services);
  in {
    enable = true;
    config = concatMapStringsSep "\n" ({ name, port }: ''
      listen ${name}
        bind *:${toString port}
        mode tcp
        timeout client 30s
        timeout connect 5s
        timeout server 30s
        timeout tunnel 1h
        server default ${wgIP}:${toString (port * 10)} send-proxy
    '') uniquePorts;
  };

  # Enable SSH
  services.sshd.enable = true;

  system.stateVersion = "21.05";
}
