let publicIP = "170.75.170.152";
in { config, lib, ... }: {
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
    };

    # Use NAT to forward incoming traffic over Wireguard
    nat = let
      ports = [ 80 443 ];
      # Create destination NAT rules
      forwardPorts = map (sourcePort: {
        inherit sourcePort;
        destination = "192.168.50.2";
      }) ports;
      # Create masquerade rules
      extraCommands = lib.concatMapStrings (p: ''
        iptables -t nat -A nixos-nat-post -p tcp --dport ${
          toString p
        } -j MASQUERADE
      '') ports;
    in {
      enable = true;
      # Traffic comes in on ens3
      externalInterface = "ens3";
      inherit forwardPorts extraCommands;
    };
  };

  # Enable SSH
  services.sshd.enable = true;

  system.stateVersion = "21.05";
}
