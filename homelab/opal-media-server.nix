{ ... }:

{
  imports = [ ./hardware/opal-media-server.nix ];

  # Set deployment IP
  deployment.targetHost = "192.168.1.10";

  # Configure GRUB for booting
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    # Set hostname
    hostName = "opal-media-server";

    # Use DHCP for internet interface
    interfaces.ens18.useDHCP = true;
  };

  # Enable the Jellyfin media server
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
