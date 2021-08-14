let publicIP = "170.75.170.152";
in { config, ... }: {
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
    };
  };

  # Enable SSH
  services.sshd.enable = true;

  # TODO: remove and configure HAProxy or Traefik instead - this is for testing
  services.nginx.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "21.05";
}
