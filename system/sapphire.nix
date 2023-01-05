{ pkgs, ... }:

{
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Australia/Melbourne";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules =
        [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "kvm-amd" ];
    };

    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        gfxmodeEfi = "2560x1440";
        useOSProber = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/058c81bf-408d-4425-9ca5-0d790ec1c12d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/06D4-6CD6";
      fsType = "vfat";
    };
    "/vault" = {
      device = "/dev/disk/by-uuid/F279-E82B";
      fsType = "exfat";
      options = [ "defaults" "umask=000" ];
    };
    "/home/ruby/.backup" = {
      device = "fluorite:/mnt/Fluorite-HDD/Machine-Backups/Amethyst";
      fsType = "nfs";
      options = [
        "noauto"
        "noatime"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
      ];
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/06764441-8c0d-4e61-a105-f1fab1c66149"; }];

  hardware = {
    bluetooth.enable = true;

    enableRedistributableFirmware = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby";
      extraGroups = [ "adbusers" "camera" "docker" "libvirtd" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  nix.settings = {
    max-jobs = 24;
    trusted-users = [ "ruby" ];
  };

  environment.systemPackages = with pkgs; [ ntfs3g pciutils usbutils ];

  location.provider = "geoclue2";

  networking = {
    firewall.enable = false;

    wireguard.enable = true;
  };

  fonts.enableDefaultFonts = true;

  virtualisation = {
    docker.enable = true;

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
  };

  # Allow setuid for libvirtd USB passthrough helper
  security.wrappers.spice-client-glib-usb-acl-helper = {
    owner = "root";
    group = "root";
    source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";
  };

  programs = {
    adb.enable = true;

    dconf.enable = true;

    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
    };

    gphoto2.enable = true;

    ssh.startAgent = true;
  };

  services = {
    blueman.enable = true;

    geoclue2.enable = true;

    gnome = {
      at-spi2-core.enable = true;
      gnome-keyring.enable = true;
    };

    greetd = {
      enable = true;
      settings = let
        swayConfig = pkgs.writeText "sway-config" ''
          exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; ${pkgs.sway}/bin/swaymsg exit"
        '';
      in {
        default_session = {
          command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
        };
      };
    };

    gvfs.enable = true;

    joycond.enable = true;

    mullvad-vpn.enable = true;

    pcscd.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };

    redshift = {
      enable = true;
      temperature = {
        day = 6500;
        night = 4000;
      };
    };

    srxl.qmk.enable = true;

    trezord.enable = true;

    tumbler.enable = true;
  };

  sound.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  home-manager.users.ruby = import ../home/sapphire-ruby.nix;

  system.stateVersion = "21.05";
}
