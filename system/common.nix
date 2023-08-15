{ pkgs, lib, inputs, name, flakePkgs, ... }:

{
  imports = [
    ./modules/audioprod.nix
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
    # Use a flakes-enabled version of Nix
    # Known bug in 2.16 is breaking this config, revert when it gets fixed
    # https://github.com/NixOS/nix/issues/8443
    package = pkgs.nixVersions.nix_2_15;

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

    # NIX_PATH entries
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" "nur=${inputs.nur}" ];

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
  };

  # Common packages
  environment.systemPackages = with pkgs; [
    bat
    dnsutils
    fd
    file
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
      inputs.hyprland.homeManagerModules.default
      inputs.wired-notify.homeManagerModules.default
    ];
  };

  # Set flake revision
  system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
}
