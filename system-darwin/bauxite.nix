{ config, pkgs, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

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

    casks = [
      "parsec"
    ];
  };

  nix = {
    # No channels. All flakes here
    channel.enable = false;

    # Regularly run store optimization
    optimise.automatic = true;

    # Make sure Nix runs builds in the sandbox
    settings.sandbox = true;

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

  services.openssh.enable = true;

  services.tailscale.enable = true;

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
