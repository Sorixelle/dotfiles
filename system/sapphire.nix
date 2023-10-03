{ pkgs, ... }:

{
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Australia/Melbourne";
  };

  boot = {
    kernelParams = [ "quiet" ];
    consoleLogLevel = 3;
    kernelPackages = pkgs.linuxPackages-rt_latest;

    initrd = {
      availableKernelModules =
        [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "kvm-amd" ];

      luks.devices = {
        Encrypt-Key.device =
          "/dev/disk/by-uuid/5bc957cf-200a-4921-a624-04e147d8942a";

        Encrypted-Swap = {
          device = "/dev/disk/by-uuid/40a0f85c-380b-416b-8889-0e461441b564";
          keyFile = "/dev/mapper/Encrypt-Key";
          keyFileSize = 8192;
          bypassWorkqueues = true;
        };

        Encrypted-Root = {
          device = "/dev/disk/by-uuid/c3a5eb7c-f67f-4d97-89d7-5261b1931977";
          keyFile = "/dev/mapper/Encrypt-Key";
          keyFileSize = 8192;
          bypassWorkqueues = true;
          allowDiscards = true;
        };
      };

      systemd.enable = true;
    };

    loader = {
      efi.canTouchEfiVariables = true;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        gfxmodeEfi = "2560x1440";
        useOSProber = true;
        splashImage = null;
        timeoutStyle = "hidden";
      };
    };

    plymouth = {
      enable = true;
      font = "${pkgs.inter}/share/fonts/opentype/Inter-Regular.otf";
    };
  };

  fileSystems = {
    "/" = {
      device = "Sapphire/System/Root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "Sapphire/Nix-Store";
      fsType = "zfs";
    };
    "/var" = {
      device = "Sapphire/System/var";
      fsType = "zfs";
    };
    "/home/ruby" = {
      device = "Sapphire/Ruby/Home";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/29D4-5A41";
      fsType = "vfat";
    };

    "/vault" = {
      device = "/dev/disk/by-uuid/F279-E82B";
      fsType = "exfat";
      options = [ "defaults" "umask=000" ];
    };
    "/home/ruby/media" = {
      device = "fluorite.dhcp.ongemst.one:/mnt/hdd/Data/Media";
      fsType = "nfs";
      options = [ "x-systemd.automount" ];
    };
    "/home/ruby/.local/share/backup" = {
      device = "fluorite.dhcp.ongemst.one:/mnt/hdd/Machine-Backups/Sapphire";
      fsType = "nfs";
      options = [ "x-systemd.automount" "x-systemd.idle-timeout=600" ];
    };
  };

  swapDevices = [{ device = "/dev/mapper/Encrypted-Swap"; }];

  hardware = {
    bluetooth.enable = true;

    cpu.amd.updateMicrocode = true;

    enableRedistributableFirmware = true;

    logitech.wireless.enable = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby Iris Juric";
      extraGroups = [ "adbusers" "audio" "camera" "docker" "libvirtd" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  nix.settings = {
    max-jobs = 24;
    trusted-users = [ "ruby" ];
  };

  environment.systemPackages = with pkgs; [ ntfs3g pciutils usbutils ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ corefonts ibm-plex inter roboto ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Inter" ];
        serif = [ "IBM Plex Serif" ];
        monospace = [ "IBM Plex Mono" ];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
        <fontconfig>
          <match target="font">
            <test name="fontformat" compare="not_eq">
              <string />
            </test>
            <test name="family">
              <string>Inter</string>
            </test>
            <edit name="fontfeatures" mode="append">
              <string>ss01 on</string>
              <string>ss02 on</string>
            </edit>
          </match>

          <match target="font">
            <test name="fontformat" compare="not_eq">
              <string />
            </test>
            <test name="family">
              <string>IBM Plex Mono</string>
            </test>
            <edit name="fontfeatures" mode="append">
              <string>ss02 on</string>
              <string>ss03 on</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };

  location.provider = "geoclue2";

  networking = {
    hostId = "676cd442";

    firewall.enable = false;

    wireguard.enable = true;
  };

  virtualisation = {
    docker.enable = true;

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        swtpm.enable = true;
      };
    };

    spiceUSBRedirection.enable = true;
  };

  programs = {
    adb.enable = true;

    dconf.enable = true;

    gphoto2.enable = true;

    hyprland.enable = true;

    ssh.startAgent = true;
  };

  srxl.audioprod.enable = true;

  services = {
    blueman.enable = true;

    dbus.packages = [ pkgs.gcr ];

    geoclue2.enable = true;

    gnome = {
      at-spi2-core.enable = true;
      gnome-keyring.enable = true;
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

    srxl.qmk.enable = true;

    trezord.enable = true;

    tumbler.enable = true;

    xserver = {
      enable = true;

      displayManager = {
        autoLogin.user = "ruby";
        lightdm = {
          enable = true;
          greeter.enable = false;
        };
      };

      videoDrivers = [ "amdgpu" "qxl" ];

      wacom.enable = true;

      windowManager.session = [{
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.xsession-hm &
          waitPID=$!
        '';
      }];
    };
  };

  sound.enable = true;

  home-manager.users.ruby = import ../home/sapphire-ruby;

  system.stateVersion = "21.05";
}
