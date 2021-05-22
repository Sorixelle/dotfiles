{ config, lib, pkgs, ... }:

let hmConf = config.home-manager.users.ruby;
in {
  imports = [ ./hardware/amethyst.nix ];

  time.timeZone = "Australia/Melbourne";

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

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };

    steam-hardware.enable = true;
  };

  users = {
    users.ruby = {
      description = "Ruby";
      extraGroups = [ "adbusers" "docker" "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  nix.trustedUsers = [ "ruby" ];

  environment.systemPackages = with pkgs; [ ntfs3g pciutils usbutils ];
  environment.etc."pipewire/media-session.d/with-pulseaudio" = { text = ""; };

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
  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";

  programs = {
    adb.enable = true;

    gnupg.agent = {
      enable = true;
      pinentryFlavor = "gtk2";
    };
  };

  services = {
    blueman.enable = true;

    dbus.packages = [ pkgs.gnome3.dconf ];

    geoclue2.enable = true;

    gvfs.enable = true;

    mopidy = {
      enable = true;
      extensionPackages = with pkgs; [
        mopidy-mpd
        mopidy-subidy
      ];

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

    trezord.enable = true;

    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="1038", ATTR{idProduct}=="1700", GROUP="wheel", MODE="0660"
    '';

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

  home-manager.users.ruby = import ../home/amethyst-ruby.nix;

  system.stateVersion = "21.03";
}
