{
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/services/hardware/sane_extra_backends/brscan5.nix"
  ];

  time.timeZone = "Australia/Melbourne";

  boot = {
    kernelParams = [ "quiet" ];
    consoleLogLevel = 3;

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

    # TODO: reformat drive and uncomment
    # "/vault" = {
    #   device = "/dev/disk/by-uuid/F279-E82B";
    #   fsType = "exfat";
    #   options = [
    #     "defaults"
    #     "umask=000"
    #   ];
    # };
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

    keyboard.qmk.enable = true;

    logitech.wireless.enable = true;

    opentabletdriver.enable = true;

    sane = {
      enable = true;
      brscan5 = {
        enable = true;
        netDevices = {
          home = {
            model = "MFC-L2800DW";
            ip = "10.0.3.25";
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

  nix.settings.trusted-users = [ "ruby" ];

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

    useNetworkd = true;

    wireguard.enable = true;
  };

  systemd.network = {
    enable = true;

    networks."10-enp10s0" = {
      matchConfig.Name = "enp10s0";
      networkConfig.DHCP = "ipv4";
      ipv6AcceptRAConfig.Token = "prefixstable";
      linkConfig.RequiredForOnline = "routable";
    };
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

    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;

      settings = {
        locale = "en_GB";
        sunshine_name = "Sapphire";
        adapter_name = "/dev/dri/renderD128";
        output_name = 1;
      };
      applications = {
        apps = [
          {
            name = "Steam Big Picture";
            cmd = "systemctl --user start steam-big-picture";
          }
        ];
      };
    };

    syncoid = {
      enable = true;
      sshKey = "/etc/backup_key";
      commonArgs = [ "--no-privilege-elevation" ];
      commands."Sapphire/Ruby/Home".target =
        "ruby@10.0.2.20:Fluorite-HDD/Machine-Backups/Sapphire/Ruby/Home";
    };

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
