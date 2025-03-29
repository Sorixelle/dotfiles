{ ... }:

{
  imports = [
    ./emacs.nix
    ./email.nix
    ./fonts.nix
    ./shell.nix
    ./starship.nix
  ];

  # Place the repo's nixpkgs config in the globally-accessible location
  xdg.configFile."nixpkgs/config.nix".source = ../../nixpkgs/config.nix;

  # Enable Catppuccin theming for common tools
  catppuccin = {
    bat.enable = true;
    glamour.enable = true;
    nvim.enable = true;
  };

  # And let home-manager manage the config for them
  programs = {
    bat.enable = true;
    neovim.enable = true;
  };
}
