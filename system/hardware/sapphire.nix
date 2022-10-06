{ config, lib, ... }:

{
  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules =
    [ "vendor-reset" "vfio_pci" "vfio" "vfio_iommu_type1" "vfio_virqfd" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.vendor-reset ];
  boot.extraModprobeConfig = ''
    options vfio_pci ids=1022:14da,1022:14db,1002:1478,1002:1479,1002:731f,1002:ab38
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-label/NixOS-Root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/vault" = {
    device = "/dev/disk/by-label/Vault";
    fsType = "exfat";
    options = [ "defaults" "umask=000" ];
  };

  swapDevices = [{ device = "/dev/disk/by-label/Swap"; }];

  nix.settings.max-jobs = lib.mkDefault 24;
}
