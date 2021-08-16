let publicIP = "192.168.1.2";
in { nodes, ... }: {
  imports = [ ./hardware/opal-entrypoint.nix ./modules/services.nix ];

  # Set deployment IP
  deployment.targetHost = publicIP;

  # Read and deploy secrets from sops yaml
  sops = {
    defaultSopsFile = ../secrets/opal-entrypoint.yaml;
    secrets.wg_client_privkey = { };
    secrets.nginx_dh_params = { owner = "nginx"; };
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

  # Sets up Nginx and creates servers for each entry
  # See ./modules/services.nix for more details on how this is done
  srxl.services = {
    media = {
      port = 443;
      locations = {
        "= /" = { return = "302 https://$host/web/"; };
        "/" = {
          proxyPass = "http://192.168.1.10:8096";
          extraConfig = "proxy_buffering off;";
        };
        "= /web/" = { proxyPass = "http://192.168.1.10:8096/web/index.html"; };
        "/socket" = {
          proxyPass = "http://192.168.1.10:8096";
          proxyWebsockets = true;
        };
      };
    };
  };
  # Set Nginx Diffie-Hellman parameters from sops secrets
  services.nginx.sslDhparam = "/run/secrets/nginx_dh_params";

  system.stateVersion = "21.05";
}
