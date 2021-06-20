{ name, flakePkgs }:
{ pkgs, lib, inputs, ... }:

{
  imports = [
    ./modules/joycond.nix
  ];

  # Set the hostname
  networking.hostName = name;

  # Use flake's nixpkgs
  nixpkgs.pkgs = flakePkgs;

  # Add nixpkgs to NIX_PATH, by linking it to /etc/nixpkgs
  environment.etc.nixpkgs.source = inputs.nixpkgs;

  # Configure Nix
  nix = {
    # Use a flakes-enabled version of Nix
    package = pkgs.nixUnstable;

    # Enable nix-command and flakes, and persist derivations/outputs
    # for nix-direnv
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
    '';

    # NIX_PATH entries
    nixPath = [ "nixpkgs=/etc/nixpkgs" "nur=${inputs.nur}" ];

    # Expose nixpkgs and this flake in the flake registry
    registry = {
      srxl-dotfiles.flake = inputs.self;
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        flake = inputs.nixpkgs;
      };
    };

    # Additional binary caches
    binaryCaches = [
      "https://cache.nixos.org"
      "https://hydra.iohk.io"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    bat
    dnsutils
    exfat
    file
    htop
    ncdu
    psmisc
    ripgrep
    vim
    wget
    zip
    unzip
  ];

  # Use the Fish shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  boot = {
    # Clean /tmp on startup
    cleanTmpDir = true;
    # Mount /tmp as tmpfs
    tmpOnTmpfs = true;
  };

  home-manager = {
    # Install home-manager packages to /etc/profiles
    useUserPackages = true;
    # Use globally configures Nixpkgs set
    useGlobalPkgs = true;
  };

  # Set flake revision
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
}
