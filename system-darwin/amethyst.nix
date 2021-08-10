{ config, pkgs, ... }:

{
  homebrew = { casks = [ "macfuse" "veracrypt" ]; };

  networking.computerName = "Amethyst";

  programs.gnupg.agent.enable = true;

  users.users.ruby.home = "/Users/ruby";

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 25;
      KeyRepeat = 2;

      "com.apple.swipescrolldirection" = false;
    };

    dock = { show-recents = false; };

    finder = { CreateDesktop = false; };

    loginwindow = { GuestEnabled = false; };
  };

  home-manager.users.ruby = import ../home/amethyst-ruby-darwin.nix;
}
