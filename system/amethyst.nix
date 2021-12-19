{ config, pkgs, ... }:

let hmConf = config.home-manager.users.ruby;
in {
  imports = [ ./hardware/amethyst.nix ];

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
      gfxmodeEfi = "1920x1080";
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

  hardware = {
    bluetooth.enable = true;

    enableRedistributableFirmware = true;

    firmware = [ pkgs.broadcom-bt-firmware ];

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
    };

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby";
      extraGroups = [ "adbusers" "camera" "docker" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  nix.trustedUsers = [ "ruby" ];

  environment.systemPackages = with pkgs; [ ntfs3g pciutils usbutils ];

  location.provider = "geoclue2";

  networking = {
    networkmanager.enable = true;

    firewall.enable = false;
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
  };

  services = {
    blueman.enable = true;

    geoclue2.enable = true;

    gnome.at-spi2-core.enable = true;

    gvfs.enable = true;

    mopidy = {
      enable = true;
      extensionPackages = with pkgs; [ mopidy-mpd mopidy-subidy ];

      configuration = ''
        [audio]
        output = tee name=t ! queue ! pulsesink server=127.0.0.1:10001 t.
               ! queue ! audio/x-raw,rate=44100,channels=2,format=S16LE
               ! udpsink host=127.0.0.1 port=10002
      '';

      # All the configuration that has passwords and stuff that I obviously
      # can't commit to a public repo goes here
      extraConfigFiles = [ "/etc/mopidy/mopidy.conf" ];
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
      media-session.enable = true;
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

    srxl.joycond.enable = true;
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

  home-manager.users.ruby = import ../home/amethyst-ruby.nix;

  system.stateVersion = "21.05";
}
