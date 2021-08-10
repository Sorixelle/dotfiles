{ name, nixpkgsConf, inputs }:
{ pkgs, ... }:

{
  # Set the hostname
  networking.hostName = name;

  # Add nixpkgs to NIX_PATH, by linking it to /etc/nixpkgs
  environment.etc.nixpkgs.source = inputs.nixpkgs;

  # Use flake-configured Nixpkgs
  nixpkgs = nixpkgsConf;

  # Configure Nix
  nix = {
    # Use a flakes-enabled version of Nix
    package = pkgs.nixUnstable;

    # Build derivations in a sandboxed environment
    useSandbox = true;

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
    binaryCaches = [ "https://cache.nixos.org" "https://hydra.iohk.io" ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Common packages
  environment.systemPackages = with pkgs; [
    bat
    dnsutils
    exfat
    fd
    file
    htop
    ncdu
    ripgrep
    vim
    wget
    zip
    unzip
  ];

  # Homebrew integration
  homebrew = {
    enable = true;

    # Uninstall any packages not defined in Nix
    cleanup = "uninstall";

    taps = [ "homebrew/cask" ];
  };

  # Configure ZSH to use nix-darwin env
  programs.zsh.enable = true;

  # Use the Fish shell
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  home-manager = {
    # Install home-manager packages to /etc/profiles
    useUserPackages = true;
    # Use globally configures Nixpkgs set
    useGlobalPkgs = true;
  };

  system.stateVersion = 4;
}
