{ ... }:

{
  # Set system timezone
  time.timeZone = "Australia/Melbourne";
  # Set system locale
  i18n.defaultLocale = "en_AU.UTF-8";

  boot = {
    kernelModules = [ "kvm-intel" ];

    initrd = {
      # Kernel modules for booting
      availableKernelModules = [
        "ehci_pci"
        "ahci"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "sdhci_pci"
      ];

      # Setup encrypted partitions
      luks.devices = {
        # Encryption key for rest of disk, requires passphrase to unlock
        cryptkey.device = "/dev/disk/by-partlabel/Key";

        # Swap partition
        swap = {
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
          device = "/dev/disk/by-partlabel/Swap";
        };

        # Root ZFS partition
        nixos = {
          keyFile = "/dev/mapper/cryptkey";
          keyFileSize = 8192;
          allowDiscards = true;
          device = "/dev/disk/by-partlabel/NixOS";
        };
      };
    };

    # Setup GRUB
    loader.grub = {
      enable = true;
      # No need to install bootloader, just generate configs
      # Libreboot contains a GRUB payload we use instead
      device = "nodev";

      # Don't try to boot in text mode, since Coreboot sets up a framebuffer
      gfxpayloadBios = "keep";
      gfxmodeBios = "auto";
    };
  };

  # Mount filesystems
  fileSystems = {
    # Root ZFS dataset
    "/" = {
      device = "Obsidian/System/Root";
      fsType = "zfs";
    };
    # FAT32 boot partition
    "/boot" = {
      device = "/dev/disk/by-partlabel/Boot";
      fsType = "vfat";
    };
    # Nix store dataset
    "/nix" = {
      device = "Obsidian/Nix-Store";
      fsType = "zfs";
    };
    # /var dataset
    # Has xattr=sa and aclmode=posix for compatibility
    "/var" = {
      device = "Obsidian/System/var";
      fsType = "zfs";
    };
    # Home directory dataset
    "/home/ruby" = {
      device = "Obsidian/Home";
      fsType = "zfs";
    };
  };

  # Setup swap device
  swapDevices = [{ device = "/dev/mapper/swap"; }];

  hardware = {
    # Ensure CPU microcode patches are applied
    cpu.intel.updateMicrocode = true;

    # Allow use of nonfree firmware
    enableRedistributableFirmware = true;
  };

  networking = {
    hostName = "obsidian";
    # Required for ZFS
    hostId = "ee9440fb";

    # Use NetworkManager to handle network connections
    networkmanager.enable = true;
  };

  # Setup main user account
  users.users.ruby = {
    uid = 1000;
    isNormalUser = true;
    description = "Ruby Iris Juric";
    extraGroups = [ "wheel" ];
  };

  nix.settings = {
    # Use 4 cores for Nix builds
    max-jobs = 4;
    # Add ruby as a trusted user to the Nix daemon
    trusted-users = [ "ruby" ];
  };

  system.stateVersion = "23.05";
}
