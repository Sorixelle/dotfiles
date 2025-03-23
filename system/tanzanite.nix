let
  sources = import ../npins;
in

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (import "${sources.nixos-hardware}/framework/16-inch/7040-amd")
    (import sources.lanzaboote).nixosModules.lanzaboote

    ./common.nix
  ];

  time.timeZone = "Australia/Melbourne";

  boot = {
    kernelParams = [ "quiet" ];
    consoleLogLevel = 3;

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [
        "amdgpu"
        "kvm-amd"
      ];

      luks.devices = {
        Encrypt-Key.device = "/dev/disk/by-partlabel/Key";
        Encrypted-Swap = {
          device = "/dev/disk/by-partlabel/Swap";
          keyFile = "/dev/mapper/Encrypt-Key";
          keyFileSize = 8192;
          bypassWorkqueues = true;
        };
        Encrypted-Root = {
          device = "/dev/disk/by-partlabel/Tanzanite";
          keyFile = "/dev/mapper/Encrypt-Key";
          keyFileSize = 8192;
          bypassWorkqueues = true;
          allowDiscards = true;
        };
      };

      systemd.enable = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 25;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkForce false;
      timeout = 0;
    };

    plymouth = {
      enable = true;
      font = "${pkgs.inter-patched}/share/fonts/truetype/InturVariable.ttf";
      extraConfig = ''
        DeviceScale=2
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = "Tanzanite/System/Root";
      fsType = "zfs";
    };
    "/var" = {
      device = "Tanzanite/System/var";
      fsType = "zfs";
    };
    "/nix/store" = {
      device = "Tanzanite/Nix-Store";
      fsType = "zfs";
    };
    "/home/ruby" = {
      device = "Tanzanite/Ruby/Home";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/Boot";
      fsType = "vfat";
    };

    "/home/ruby/download" = {
      device = "tmpfs";
      fsType = "tmpfs";
    };
  };

  swapDevices = [ { device = "/dev/mapper/Encrypted-Swap"; } ];

  hardware = {
    bluetooth.enable = true;

    enableRedistributableFirmware = true;

    logitech.wireless.enable = true;
  };

  users.users.ruby = {
    description = "Ruby Iris Juric";
    extraGroups = [
      "audio"
      "wheel"
    ];
    isNormalUser = true;
    uid = 1000;
  };

  environment = {
    etc = {
      "greetd/environments".text = ''
        sway
      '';
    };

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    systemPackages = with pkgs; [ sbctl ];
  };

  nix.settings.trusted-users = [ "ruby" ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      corefonts
      etBook
      iosevka-bin
      inter-patched
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Intur" ];
        serif = [ "ETBembo" ];
        monospace = [ "Iosevka" ];
      };
    };
  };

  location.provider = "geoclue2";

  networking = {
    hostId = "59af9bb4";
    hostName = "tanzanite";

    networkmanager.enable = true;

    wireguard.enable = true;
  };

  programs = {
    dconf.enable = true;

    gphoto2.enable = true;

    regreet = {
      enable = true;
      settings = {
        GTK = {
          font_name = lib.mkForce "${builtins.head config.fonts.fontconfig.defaultFonts.sansSerif} 12";
        };
      };
    };

    sway.enable = true;
  };

  services = {
    blueman.enable = true;

    dbus.packages = [ pkgs.gcr ];

    fwupd.enable = true;

    gnome.gnome-keyring.enable = true;

    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${pkgs.sway}/bin/sway";
          user = "ruby";
        };
      };
    };

    gvfs.enable = true;

    pcscd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    sanoid = {
      enable = true;
      datasets."Tanzanite/Ruby/Home" = {
        autosnap = true;
        autoprune = true;
        hourly = 48;
        daily = 14;
        monthly = 12;
        yearly = 3;
      };
    };

    syncoid = {
      enable = true;
      sshKey = "/etc/backup_key";
      commonArgs = [ "--no-privilege-elevation" ];
      commands."Tanzanite/Ruby/Home".target =
        "ruby@10.0.2.20:Fluorite-HDD/Machine-Backups/Tanzanite/Ruby/Home";
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "client";
    };

    udev.extraRules = ''
      # Serial to USB converter for Fluorite
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="wheel", MODE="0660"
    '';
  };

  home-manager.users.ruby = import ../home/tanzanite-ruby;

  system.stateVersion = "23.11";
}
