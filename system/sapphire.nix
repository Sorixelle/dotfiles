{ config, pkgs, ... }:

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
      kernelModules = [ "vendor-reset" "kvm-amd" ];
    };

    extraModulePackages = with config.boot.kernelPackages; [
      kvmfr
      vendor-reset
    ];

    extraModprobeConfig = ''
      options vfio_pci ids=1022:14da,1022:14db,1002:1478,1002:1479,1002:731f,1002:ab38
      options kvmfr static_size_mb=64
    '';

    kernelModules = [ "kvmfr" ];

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
      device = "/dev/disk/by-uuid/90155dc3-0542-40e0-950e-661154c53980";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/76DD-0B53";
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
    [{ device = "/dev/disk/by-uuid/ec0749a5-6ca5-4c31-b1b8-3bc178e756cd"; }];

  hardware = {
    bluetooth.enable = true;

    enableRedistributableFirmware = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };

    sane.enable = true;

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby";
      extraGroups =
        [ "adbusers" "camera" "docker" "libvirtd" "lp" "scanner" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };

    groups.dgpu = { };
  };

  nix.settings = {
    max-jobs = 24;
    trusted-users = [ "ruby" ];
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
    pciutils
    usbutils

    ardour
    calf
    caps
    carla
    distrho
    eq10q
    geonkick
    gxplugins-lv2
    helm
    lsp-plugins
    noise-repellent
    rubberband
    wolf-shaper
    zyn-fusion
  ];

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
        verbatimConfig = ''
          namespaces = []

          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
            "/dev/rtc", "/dev/hpet", "/dev/kvmfr0",
          ]
        '';
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

    mopidy = {
      enable = true;
      extensionPackages = with pkgs; [ mopidy-mpd mopidy-subidy ];

      configuration = ''
        [audio]
        output = pulsesink server=127.0.0.1:4713
      '';

      # All the configuration that has passwords and stuff that I obviously
      # can't commit to a public repo goes here
      extraConfigFiles = [ "/etc/mopidy/mopidy.conf" ];
    };

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

      config.pipewire-pulse = {
        "context.modules" = [
          {
            name = "libpipewire-module-rtkit";
            flags = [ "ifexists" "nofail" ];
          }
          { name = "libpipewire-module-protocol-native"; }
          { name = "libpipewire-module-client-node"; }
          { name = "libpipewire-module-adapter"; }
          { name = "libpipewire-module-metadata"; }
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              "server.address" = [ "unix:native" "tcp:4713" ];
              "vm.overrides" = { "pulse.min.quantum" = "1024/48000"; };
            };
          }
        ];
      };
    };

    printing = {
      enable = true;
      drivers = [ pkgs.epson-escpr ];
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

    udev.extraRules = ''
      # Use vendor-reset when resetting GPU to avoid GPU being unusable after shutting down VM
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x731f", RUN+="${pkgs.bash}/bin/bash -c 'echo device_specific > /sys$env{DEVPATH}/reset_method'"

      KERNEL=="card[0-9]", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTRS{boot_vga}=="1", GROUP="dgpu", TAG="nothing", ENV{ID_SEAT}="none"
      KERNEL=="renderD12[0-9]", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", ATTRS{boot_vga}=="1", GROUP="dgpu", MODE="0660"

      SUBSYSTEM=="kvmfr", OWNER="ruby", GROUP="kvm", MODE="0660"
    '';
  };

  sound.enable = true;

  musnix.enable = true;

  home-manager.users.ruby = import ../home/sapphire-ruby.nix;

  system.stateVersion = "21.05";
}
