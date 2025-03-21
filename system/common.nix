{
  pkgs,
  lib,
  inputs,
  name,
  flakePkgs,
  ...
}:

{
  # Set the hostname
  networking.hostName = name;

  # Use flake's nixpkgs
  nixpkgs.pkgs = flakePkgs;

  # Configure Nix
  nix = {
    # Disable channels
    channel.enable = false;

    # Enable nix-command and flakes, and persist derivations/outputs for nix-direnv
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
    '';

    settings = {
      # Build up to 4 derivations in parallel
      max-jobs = 4;

      # https://github.com/NixOS/nix/issues/9574
      nix-path = lib.mkForce "nixpkgs=flake:nixpkgs";

      # Include binary caches for some projects
      substituters = [
        "https://autost.cachix.org"
        "https://nix-community.cachix.org"
        "https://pebble.cachix.org"
      ];
      trusted-public-keys = [
        "autost.cachix.org-1:zl/QINkEtBrk/TVeogtROIpQwQH6QjQWTPkbPNNsgpk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "pebble.cachix.org-1:aTqwT2hR6lGggw/rPISRcHZctDv2iF7ewsVxf3Hq6ow="
      ];
    };

    # Expose this flake in the flake registry
    registry.srxl-dotfiles.flake = inputs.self;
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    bat
    dnsutils
    eza
    fd
    file
    fzf
    htop
    ncdu
    neovim
    nix-output-monitor
    psmisc
    ripgrep
    wget
    zip
    unzip
  ];

  # Use the Fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Disable command not found handler since it's broken with flakes
  programs.command-not-found.enable = false;

  # Clean /tmp on startup
  boot.tmp.cleanOnBoot = true;

  # Use nixos-rebuild-ng in place of nixos-rebuild
  system.rebuild.enableNg = true;

  home-manager = {
    # Install home-manager packages to /etc/profiles
    useUserPackages = true;
    # Use globally configured Nixpkgs set
    useGlobalPkgs = true;
  };

  # Set flake revision
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
}
