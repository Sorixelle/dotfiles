{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/services/hardware/sane_extra_backends/brscan5.nix"
  ];

  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Australia/Melbourne";
  };

  boot = {
    kernelParams = [ "quiet" ];
    consoleLogLevel = 3;

    extraModulePackages = [
      (config.boot.kernelPackages.liquidtux.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "liquidctl";
          repo = "liquidtux";
          rev = "b2545177be1d0f8c0eed0da4a2e0e487f708fc16";
          hash = "sha256-ByrUNTDMXACchpNiLFNuz3rnPBqoZLEYtGNRArjjqec=";
        };
        installPhase = ''
          cd drivers/hwmon
          install nzxt-grid3.ko nzxt-kraken2.ko nzxt-kraken3.ko nzxt-smart2.ko -Dm444 -t ${placeholder "out"}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/kernel/drivers/hwmon
        '';
      }))
    ];

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [ "kvm-amd" ];

      luks.devices = {
        Encrypt-Key.device = "/dev/disk/by-uuid/5bc957cf-200a-4921-a624-04e147d8942a";

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
      options = [
        "defaults"
        "umask=000"
      ];
    };
    "/home/ruby/media" = {
      device = "fluorite:/mnt/hdd/Data/Media";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "x-systemd.requires=tailscaled.service"
      ];
    };
    "/home/ruby/download" = {
      device = "tmpfs";
      fsType = "tmpfs";
    };
  };

  swapDevices = [ { device = "/dev/mapper/Encrypted-Swap"; } ];

  hardware = {
    bluetooth.enable = true;

    cpu.amd.updateMicrocode = true;

    enableRedistributableFirmware = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    logitech.wireless.enable = true;

    opentabletdriver.enable = true;

    sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          home = {
            model = "MFC-L2800DW";
            ip = "10.0.3.251";
          };
        };
      };
    };

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby Iris Juric";
      extraGroups = [
        "adbusers"
        "audio"
        "camera"
        "docker"
        "libvirtd"
        "lp"
        "scanner"
        "wheel"
      ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  nix = {
    gc.automatic = lib.mkForce false;
    settings.trusted-users = [ "ruby" ];
  };

  environment = {
    etc = {
      "greetd/environments".text = ''
        sway
      '';
      "libinput/local-overrides.quirks".text = ''
        [OpenTabletDriver Virtual Tablet]
        MatchName=OpenTabletDriver*
        AttrTabletSmoothing=0
      '';
    };

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      liquidctl
      ntfs3g
      pciutils
      usbutils
    ];
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      corefonts
      etBook
      iosevka-bin
      inter-patched
      roboto
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

    ssh.startAgent = true;

    sway.enable = true;
  };

  security.rtkit.enable = true;

  services = {
    blueman.enable = true;

    dbus.packages = [ pkgs.gcr ];

    displayManager.autoLogin.user = "ruby";

    geoclue2.enable = true;

    gnome = {
      at-spi2-core.enable = true;
      gnome-keyring.enable = true;
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet";
        };
        initial_session = {
          command = "${config.programs.sway.package}/bin/sway";
          user = "ruby";
        };
      };
    };

    gvfs.enable = true;

    hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };

    joycond.enable = true;

    pcscd.enable = true;

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;

      wireplumber.extraConfig = {
        # There seems to be a few ms delay between opening audio device -> hearing sound come out, which drops the start
        # of the sound until the device is "ready". Or something like that. Either way, the delay is long enough to
        # completely drop things like notification sounds, so I disable the session timeout in Wireplumber so that the
        # audio interface never gets closed.
        disable-session-timeout = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.name" = "~alsa_input.*"; }
                { "node.name" = "~alsa_output.*"; }
              ];
              actions.update-props."session.suspend-timeout-seconds" = 0;
            }
          ];
        };
      };
    };

    printing.enable = true;

    sanoid = {
      enable = true;
      datasets."Sapphire/Ruby/Home" = {
        autosnap = true;
        autoprune = true;
        hourly = 10;
        daily = 7;
      };
    };

    syncoid = {
      enable = true;
      sshKey = "/etc/backup_key";
      commonArgs = [ "--no-privilege-elevation" ];
      commands."Sapphire/Ruby/Home".target = "ruby@10.0.2.20:Fluorite-HDD/Machine-Backups/Sapphire/Ruby/Home";
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

      videoDrivers = [
        "amdgpu"
        "qxl"
      ];

      wacom.enable = true;

      windowManager.session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.xsession-hm &
            waitPID=$!
          '';
        }
      ];
    };
  };

  systemd.services = {
    syncoid-Sapphire-Ruby-Home.onFailure = [ "backup-fail-notify.service" ];
    backup-fail-notify = {
      description = "Send notification when Syncoid job fails";
      path = [
        pkgs.curl
        pkgs.systemd
      ];
      serviceConfig.Type = "oneshot";
      script = ''
        RUN_ID=$(systemctl show --value -p InvocationID syncoid-Sapphire-Ruby-Home.service)
        LOG=$(journalctl _SYSTEMD_INVOCATION_ID=$RUN_ID)

        curl -L \
          -H "X-Priority: 4" \
          -H "X-Title: Sapphire backup sync to Fluorite failed!" \
          -d "$LOG" \
          ntfy.isincredibly.gay/backup-status
      '';
    };
  };

  home-manager.users.ruby = import ../home/sapphire-ruby;

  system.stateVersion = "21.05";
}
