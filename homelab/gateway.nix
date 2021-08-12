let publicIP = "170.75.170.152";
in { ... }: {
  imports = [ ./hardware/gateway.nix ];

  deployment.targetHost = publicIP;

  sops = {
    defaultSopsFile = ../secrets/gateway.yaml;
    secrets.wg_server_privkey = { };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking = {
    hostName = "gemstonelabs-gateway";

    interfaces.ens3.useDHCP = true;

    wg-quick.interfaces.wg0 = {
      address = [ "192.168.50.1/24" ];
      privateKeyFile = "/run/secrets/wg_server_privkey";
      listenPort = 51820;
      peers = [{
        publicKey = "vDEUGgshzIOQeBEThkyrBbAZlLMeTl9x6PL1FKmv6DA=";
        allowedIPs = [ "192.168.50.2/32" ];
      }];
    };
  };

  services.sshd.enable = true;
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "21.05";
}
