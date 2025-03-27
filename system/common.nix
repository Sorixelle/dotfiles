let
  sources = import ../npins;

  pkgs = import ../nixpkgs;
in

{ ... }:

{
  # Import NixOS modules from npins
  imports = [
    (import "${sources.home-manager}/nixos")
    (import "${sources.lix-module}/module.nix" {
      lix = import sources.lix;
      # Include short hash of Lix commit in the version
      versionSuffix = "-${builtins.substring 0 7 sources.lix.revision}";
    })

    ./modules/rebuild.nix
  ];

  # Use the nixpkgs set we just defined
  nixpkgs.pkgs = pkgs;

  # Disable channels
  nix.channel.enable = false;
  # Pin nixpkgs in the flake registry to our nixpkgs checkout in npins
  nix.registry.nixpkgs.to = {
    type = "path";
    path = sources.nixpkgs;
  };
  # Include it in the nix path too, for compatibility with older CLI tools and <nixpkgs> references
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

  # Enable nix-command and flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings = {
    # Build up to 4 derivations in parallel
    max-jobs = 4;

    # Include binary caches for some projects
    substituters = [
      "https://autost.cachix.org"
      "https://canidae-solutions.cachix.org"
      "https://nix-community.cachix.org"
      "https://pebble.cachix.org"
    ];
    trusted-public-keys = [
      "autost.cachix.org-1:zl/QINkEtBrk/TVeogtROIpQwQH6QjQWTPkbPNNsgpk="
      "canidae-solutions.cachix.org-1:ApBdxwoFhAVozb1wTA9rjgM1RXR10UZPSqE8RszvyK0="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "pebble.cachix.org-1:aTqwT2hR6lGggw/rPISRcHZctDv2iF7ewsVxf3Hq6ow="
    ];
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
}
