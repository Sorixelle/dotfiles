{ flakePkgs, flakeInputs }:

{
  inherit (flakeInputs) nixpkgs;

  network = {
    description = "My personal homelab + VPN gateway";
    enableRollback = true;
  };

  defaults = { pkgs, ... }: {
    imports = [ flakeInputs.sops-nix.nixosModule ];

    deployment.owners = [ "ruby@srxl.me" ];

    nixpkgs.pkgs = flakePkgs;

    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    environment.systemPackages = with pkgs; [
      bat
      file
      htop
      kitty.terminfo
      ncdu
      psmisc
      ripgrep
      vim
      wget
    ];

    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;

    boot.cleanTmpDir = true;
  };

  gateway = import ./gateway.nix;
}
