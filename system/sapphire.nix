{ config, pkgs, ... }:

{
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Australia/Melbourne";
  };

  boot = {
    kernelParams = [ "quiet" ];
    consoleLogLevel = 3;

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
      font = "${pkgs.inter-patched}/share/fonts/truetype/InturVariable.ttf";
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
      device = "fluorite:/mnt/hdd/Data/Media";
      fsType = "nfs";
      options =
        [ "x-systemd.automount" "x-systemd.requires=tailscaled.service" ];
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

  environment = {
    sessionVariables = { NIXOS_OZONE_WL = "1"; };
    systemPackages = with pkgs; [ ntfs3g pciutils usbutils ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ corefonts etBook iosevka-bin inter-patched roboto ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Intur" ];
        serif = [ "ETBembo" ];
        monospace = [ "Iosevka" ];
      };
    };
  };

  location.provider = "geoclue2";

  musnix = {
    enable = true;
    kernel.realtime = true;
  };

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

  security.rtkit.enable = true;

  services = {
    blueman.enable = true;

    dbus.packages = [ pkgs.gcr ];

    geoclue2.enable = true;

    gnome = {
      at-spi2-core.enable = true;
      gnome-keyring.enable = true;
    };

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

    sanoid = {
      enable = true;
      datasets."Sapphire/Ruby/Home" = {
        autosnap = true;
        autoprune = true;
        hourly = 48;
        daily = 14;
        monthly = 12;
        yearly = 3;
      };
    };

    srxl.qmk.enable = true;

    tailscale.enable = true;

    tumbler.enable = true;

    udev.extraRules = ''
      # Nintendo Switch - Goldleaf over USB
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", GROUP="wheel", MODE="0660"
    '';

    xserver = {
      enable = true;

      displayManager.autoLogin.user = "ruby";

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
