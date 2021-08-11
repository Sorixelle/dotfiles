let publicIP = "170.75.170.152";
in { ... }: {
  imports = [ ./hardware/gateway.nix ];

  deployment.targetHost = publicIP;

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking = {
    hostName = "gemstonelabs-gateway";

    interfaces.ens3.useDHCP = true;
  };

  services.sshd.enable = true;
  services.nginx.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "21.05";
}
