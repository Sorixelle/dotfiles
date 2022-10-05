{ config, pkgs, ... }:

let hmConf = config.home-manager.users.ruby;
in {
  imports = [ ./hardware/sapphire.nix ];

  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Australia/Melbourne";
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "2560x1440";
      # Add OpenCore macOS boot entry
      extraEntries = ''
        menuentry "macOS" {
          set root=(hd0,1)
          chainloader /EFI/BOOT/BOOTx64.EFI
        }
      '';
      useOSProber = true;
    };
  };

  fileSystems."/home/ruby/.backup" = {
    device = "fluorite:/mnt/Fluorite-HDD/Machine-Backups/Amethyst";
    fsType = "nfs";
    options =
      [ "noauto" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=600" ];
  };

  hardware = {
    bluetooth.enable = true;

    enableRedistributableFirmware = true;

    firmware = [ pkgs.broadcom-bt-firmware ];

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
    };

    sane.enable = true;

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby";
      extraGroups = [ "adbusers" "camera" "docker" "lp" "scanner" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  nix.settings.trusted-users = [ "ruby" ];

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

    libvirtd.enable = true;
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

    xserver = {
      enable = true;

      displayManager.lightdm = {
        enable = true;
        greeters.gtk = {
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
    };
  };

  sound.enable = true;

  musnix.enable = true;

  home-manager.users.ruby = import ../home/sapphire-ruby.nix;

  system.stateVersion = "21.05";
}
