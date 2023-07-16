{ pkgs, ... }:

{
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Australia/Melbourne";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages-rt_latest;

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
    "/home/ruby/usr/media" = {
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

  swapDevices =
    [{ device = "/dev/disk/by-uuid/06764441-8c0d-4e61-a105-f1fab1c66149"; }];

  hardware = {
    bluetooth.enable = true;

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
      description = "Ruby";
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
    enableDefaultFonts = true;
    fonts = with pkgs; [ corefonts ibm-plex inter roboto ];
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

    # https://github.com/NixOS/nixpkgs/issues/196934
    nscd.enableNsncd = false;

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

    # redshift = {
    #   enable = true;
    #   temperature = {
    #     day = 6500;
    #     night = 4000;
    #   };
    # };

    srxl.qmk.enable = true;

    trezord.enable = true;

    tumbler.enable = true;

    xserver = {
      enable = true;

      displayManager.sddm.enable = true;

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
