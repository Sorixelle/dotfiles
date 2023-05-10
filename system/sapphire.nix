{ config, lib, pkgs, ... }:

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
      device = "//fluorite.ad.ongemst.one/media";
      fsType = "smb3";
      options = [
        "sec=krb5"
        "multiuser"
        "domain=GEM"
        "x-systemd.automount"
        "x-systemd.requires=k5start-root.service"
      ];
    };
    "/home/ruby/.local/share/backup" = {
      device = "//fluorite.ad.ongemst.one/sapphire-backup";
      fsType = "smb3";
      options = [
        "sec=krb5"
        "multiuser"
        "domain=GEM"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.requires=k5start-root.service"
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
      extraGroups = [ "adbusers" "audio" "camera" "docker" "libvirtd" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = "AD.ONGEMST.ONE";
      forwardable = true;
    };

    # Special Secret Sauce that makes sshd not get confused about what principals map to which users
    # eg. without this, a principal for "ruby@AD.ONGEMST.ONE" will map to the user "ruby" (wrong) and not
    # "ruby@ad.ongemst.one" (correct)
    extraConfig = ''
      includedir /var/lib/sss/pubconf/krb5.include.d
    '';
  };

  nix.settings = {
    max-jobs = 24;
    trusted-users = [ "ruby" ];
  };

  environment.systemPackages = with pkgs; [ adcli ntfs3g pciutils usbutils ];

  environment.etc."cifs-utils/idmap-plugin".source =
    "${pkgs.sssd}/lib/cifs-utils/cifs_idmap_sss.so";

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [ corefonts roboto ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Inter" "IBM Plex Mono JP" ];
      serif = [ "IBM Plex Serif" ];
      monospace = [ "BlexMono Nerd Font" ];
    };
  };

  location.provider = "geoclue2";

  networking = {
    domain = "ad.ongemst.one";

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

    cifs-utils = {
      enable = true;
      idmapPlugin = "${pkgs.sssd}/lib/cifs-utils/cifs_idmap_sss.so";
    };

    dconf.enable = true;

    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
    };

    gphoto2.enable = true;

    ssh.startAgent = true;
  };

  srxl.audioprod.enable = true;

  services = {
    blueman.enable = true;

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

    redshift = {
      enable = true;
      temperature = {
        day = 6500;
        night = 4000;
      };
    };

    srxl.qmk.enable = true;

    sssd = {
      enable = true;
      config = ''
        [sssd]
        config_file_version = 2
        domains = ad.ongemst.one
        services = nss, pam

        [domain/ad.ongemst.one]
        access_provider = ad
        auth_provider = ad
        ad_domain = ad.ongemst.one
        cache_credentials = True
        default_shell = ${pkgs.bashInteractive}/bin/bash
        fallback_homedir = /home/%u@%d
        id_provider = files
        krb5_map_user = ruby:ruby
        krb5_realm = AD.ONGEMST.ONE
        krb5_renewable_lifetime = 6h
        krb5_renew_interval = 1h
        krb5_store_password_if_offline = True
        ldap_id_mapping = True
        use_fully_qualified_names = True
      '';
    };

    trezord.enable = true;

    tumbler.enable = true;

    xserver = {
      enable = true;

      displayManager.lightdm = {
        enable = true;
        greeters.gtk = let hmConf = config.home-manager.users.ruby;
        in {
          enable = true;
          inherit (hmConf.gtk) iconTheme theme;
          extraConfig = ''
            font-name = ${hmConf.gtk.font.name}
          '';
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

      xrandrHeads = [
        "HDMI-A-0"
        {
          output = "DisplayPort-0";
          primary = true;
          monitorConfig = ''
            ModeLine "2560x1440@170" 718.40 2560 2608 2640 2720 1440 1443 1448 1554 +hsync -vsync
            Option "PreferredMode" "2560x1440@170"
          '';
        }
      ];
    };
  };

  sound.enable = true;

  systemd.services = {
    k5start-root = {
      description = "Obtain and renew Kerberos ticket for machine account";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kstart}/bin/k5start -f /etc/krb5.keytab -K 60 -v ${
            lib.toUpper config.networking.hostName
          }$";
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  home-manager.users.ruby = import ../home/sapphire-ruby.nix;

  system.stateVersion = "21.05";
}
