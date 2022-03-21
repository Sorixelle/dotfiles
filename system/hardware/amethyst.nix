{ lib, ... }:

{
  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  fileSystems."/vault" = {
    device = "/dev/disk/by-label/Vault";
    fsType = "exfat";
    options = [ "defaults" "umask=000" ];
  };

  swapDevices = [{ device = "/dev/disk/by-label/Swap"; }];

  nix.maxJobs = lib.mkDefault 12;
}
