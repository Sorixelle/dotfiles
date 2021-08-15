let publicIP = "192.168.1.2";
in { nodes, ... }: {
  imports = [ ./hardware/opal-entrypoint.nix ];

  # Set deployment IP
  deployment.targetHost = publicIP;

  # Read and deploy secrets from sops yaml
  sops = {
    defaultSopsFile = ../secrets/opal-entrypoint.yaml;
    secrets.wg_client_privkey = { };
  };

  # Configure GRUB for booting
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  # Enable QEMU guest agent
  services.qemuGuest.enable = true;

  networking = {
    # Set hostname
    hostName = "opal-entrypoint";

    # Use DHCP for internet interface
    interfaces.ens18.useDHCP = true;

    # Setup a Wireguard interface
    wg-quick.interfaces.wg0 = {
      # Address of wg0 on client
      address = [ "192.168.50.2" ];
      # Private key - file created by sops-nix
      privateKeyFile = "/run/secrets/wg_client_privkey";
      peers = [{
        # Public key of Wireguard server
        publicKey = "YDcqYFV64FH7NPYeJedFArEEYRwI2s0FzO/BhmvUt30=";
        # Endpoint of Wireguard server to connect to
        endpoint = let
          gateway = nodes.gateway.config;
          ip = gateway.deployment.targetHost;
          port = toString gateway.networking.wg-quick.interfaces.wg0.listenPort;
        in "${ip}:${port}";
        # IPs that the server is allowed to communicate with
        allowedIPs = [ "192.168.50.0/24" ];
        # Send keepalive to ensure connection stays open
        persistentKeepalive = 25;
      }];
    };
  };

  # Enable SSH
  services.sshd.enable = true;

  # TODO: remove and configure HAProxy or Traefik instead - this is for testing
  services.nginx.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "21.05";
}
