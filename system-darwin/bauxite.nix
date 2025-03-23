let
  sources = import ../npins;

  pkgs = import ../nixpkgs;
in
{
  config,
  lib,
  ...
}:

{
  imports = [
    (import "${sources.home-manager}/nix-darwin")
    (import "${sources.lix-module}/module.nix" {
      lix = import sources.lix;
      # Include short hash of Lix commit in the version
      versionSuffix = "-${builtins.substring 0 7 sources.lix.revision}";
    })

    ../system/modules/rebuild.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.pkgs = pkgs;

  networking.hostName = "bauxite";
  time.timeZone = "Australia/Melbourne";

  environment.systemPackages = with pkgs; [
    bat
    btop
    dnsutils
    eza
    fd
    file
    htop
    ncdu
    neovim
    nix-output-monitor
    rebuild
    ripgrep
    wget
    zip
    unzip
  ];

  homebrew = {
    enable = true;
    onActivation = {
      # Update all Brew packages when activating
      autoUpdate = true;
      upgrade = true;

      # Remove anything not installed by this configuration
      cleanup = "zap";
    };

    brews = [
      "mas"
    ];

    casks = [
      "alfred"
      "parsec"
    ];

    masApps = {
      Xcode = 497799835;
    };
  };

  nix = {
    # No channels. It's all declarative in this config
    channel.enable = false;

    # Regularly run store optimization
    optimise.automatic = true;

    # Pin nixpkgs in the flake registry to our nixpkgs checkout in npins
    registry.nixpkgs.to = {
      type = "path";
      path = sources.nixpkgs;
    };

    nixPath = [
      # Include it in the nix path too, for compatibility with darwin-rebuild, older CLI tools and <nixpkgs> references
      "nixpkgs=flake:nixpkgs"
      # Put darwin-config back in NIX_PATH, since channels are turned off
      "darwin-config=${config.environment.darwinConfig}"
      # Tell darwin where the nix-darwin checkout lives
      "darwin=${sources.nix-darwin}"
    ];

    # Make sure Nix runs builds in the sandbox
    # settings.sandbox = true;

    # Ensure flakes work
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # We're more of a server than a desktop - don't sleep
  power.sleep = {
    computer = "never";
    display = "never";
    harddisk = "never";
  };

  # Setup Fish, and ensure it's usable as a login shell
  programs.fish.enable = true;
  environment.shells = [
    config.programs.fish.package
  ];
  # Workaround for Fish not correctly setting up PATH in non-interactive SSH sessions
  environment.etc."fish/nixos-env-preinit.fish".text = lib.mkForce ''
    # This happens before $__fish_datadir/config.fish sets fish_function_path, so it is currently
    # unset. We set it and then completely erase it, leaving its configuration to $__fish_datadir/config.fish
    set fish_function_path "${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d" $__fish_datadir/functions
    # source the NixOS environment config
    if [ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" ]
      # I added this line to work around a problem where environment wasn't set when running through SSH
      set -x __NIX_DARWIN_SET_ENVIRONMENT_DONE 1
      fenv source ${config.system.build.setEnvironment}
    end
    # clear fish_function_path so that it will be correctly set when we return to $__fish_datadir/config.fish
    set -e fish_function_path
  '';

  services.openssh.enable = true;

  services.tailscale.enable = true;

  # Let rebuild (and darwin-rebuild) know where this config lives
  srxl.rebuild.configLocation = "/Users/ruby/Nix";
  environment.darwinConfig = "${config.srxl.rebuild.configLocation}/system-darwin/bauxite.nix";

  # TODO: why does this fail activation?
  # ln: failed to create symbolic link '/etc/pam.d/sudo_local': Operation not permitted
  security.pam.services.sudo_local.enable = false;

  users.users.ruby = {
    description = "Ruby Iris Juric";
    home = "/Users/ruby";
    # Use Fish as the user shell
    shell = config.programs.fish.package;
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIBveMRzoY0e0F2c2f9N/gZ7zFBIXJGhNPSAGI5/XTaBMAAAABHNzaDo= ssh:"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.ruby = import ../home/bauxite-ruby;
  };

  system.stateVersion = 6;
}
