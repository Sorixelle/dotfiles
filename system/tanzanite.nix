{ config, inputs, lib, pkgs, ... }:

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  time.timeZone = "Australia/Melbourne";

  boot = {
    kernelParams = [ "quiet" "amd_pstate=active" ];
    consoleLogLevel = 3;

    initrd = {
      availableKernelModules =
        [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "amdgpu" "kvm-amd" ];

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
      pkiBundle = "/etc/secureboot";
      configurationLimit = 25;
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkForce false;
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

  swapDevices = [{ device = "/dev/mapper/Encrypted-Swap"; }];

  hardware = {
    bluetooth.enable = true;

    cpu.amd.updateMicrocode = true;

    enableRedistributableFirmware = true;

    logitech.wireless.enable = true;

    opengl.enable = true;

    sensor.iio.enable = true;
  };

  users.users.ruby = {
    description = "Ruby Iris Juric";
    extraGroups = [ "audio" "wheel" ]; # Enable ‘sudo’ for the user.
    isNormalUser = true;
    uid = 1000;
  };

  environment.systemPackages = with pkgs; [ sbctl ];

  nix.settings = {
    max-jobs = 16;
    trusted-users = [ "ruby" ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ corefonts etBook iosevka-bin inter-patched ];
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

    networkmanager.enable = true;

    wireguard.enable = true;
  };

  programs = {
    dconf.enable = true;

    hyprland.enable = true;
  };

  services = {
    dbus.packages = [ pkgs.gcr ];

    fprintd.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
        };
        initial_session = {
          command = "${config.programs.hyprland.package}/bin/Hyprland";
          user = "ruby";
        };
      };
    };

    pcscd.enable = true;

    power-profiles-daemon.enable = true;
  };

  sound.enable = true;

  home-manager.users.ruby = import ../home/tanzanite-ruby;

  system.stateVersion = "23.11";
}
