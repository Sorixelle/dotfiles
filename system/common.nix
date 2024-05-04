{ pkgs, lib, inputs, name, flakePkgs, ... }:

{
  imports = [
    # ./modules/audioprod.nix
    ./modules/cifs-utils.nix
    ./modules/keyutils.nix
    ./modules/qmk.nix
  ];

  # Set the hostname
  networking.hostName = name;

  nixpkgs = {
    # Use flake's nixpkgs
    pkgs = flakePkgs;
  };

  # Configure Nix
  nix = {
    # Disable channels
    channel.enable = false;

    # Use a flakes-enabled version of Nix
    package = pkgs.nixVersions.latest;

    # Run automatic garbage collection at 4pm every Sunday
    gc = {
      automatic = true;
      dates = "Sun 16:00";
    };

    # Enable nix-command and flakes, and persist derivations/outputs
    # for nix-direnv
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
    '';

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

  boot = {
    # Clean /tmp on startup
    tmp.cleanOnBoot = true;
  };

  home-manager = {
    # Install home-manager packages to /etc/profiles
    useUserPackages = true;
    # Use globally configures Nixpkgs set
    useGlobalPkgs = true;
    # Add some home-manager modules from flakes to all users
    sharedModules = [
      inputs.hypridle.homeManagerModules.default
      inputs.hyprland.homeManagerModules.default
      inputs.hyprlock.homeManagerModules.default
      inputs.wired-notify.homeManagerModules.default
    ];
  };

  # Set flake revision
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
}
