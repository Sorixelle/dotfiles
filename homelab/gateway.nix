let publicIP = "170.75.170.152";
in { config, nodes, ... }: {
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
      # Open ports for all HTTP(S) traffic
      allowedTCPPorts = [ 80 443 ];
    };
  };

  # Configure Nginx to forward incoming traffic over Wireguard with PROXY protocol
  services.nginx = let
    wireguardIP = builtins.head
      nodes.opal-entrypoint.config.networking.wg-quick.interfaces.wg0.address;
  in {
    enable = true;
    enableReload = true;
    virtualHosts = { };

    streamConfig = ''
      server {
        listen *:80;
        proxy_protocol on;
        proxy_pass ${wireguardIP}:800;
      }
      server {
        listen *:443;
        proxy_protocol on;
        proxy_pass ${wireguardIP}:4430;
      }
    '';
  };

  system.stateVersion = "21.05";
}
