{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    functions = {
      pnpx = {
        description = "Run command from Node package";
        body = ''
          set -l pnpx_command (which pnpx 2> /dev/null)
          if [ -n "$pnpx_command" ]
            $pnpx_command $argv
          else
            nix shell nixpkgs#pnpm --command pnpx $argv
          end
        '';
      };

      pnpc = {
        description = "Initialize a project with pnpm create";
        body = ''
          set -l pnpm_command (which pnpm 2> /dev/null)
          if [ -n "$pnpm_command" ]
            $pnpm_command create $argv
          else
            nix run nixpkgs#pnpm create $argv
          end
        '';
      };
    };

    shellAbbrs = {
      l = "ll";
      vim = "nvim";

      nix-clean = "sudo nix-collect-garbage -d && nix store optimise";
      nix-search = "nix search nixpkgs";
    };

    plugins = [
      {
        name = "plugin-git";
        inherit (pkgs.fishPlugins.plugin-git) src;
      }
    ];

    interactiveShellInit = ''
      set -g fish_color_command blue
      set -g fish_color_param cyan
      set -g fish_color_redirection cyan
      set -g fish_color_end green
      set -g fish_color_quote yellow
      set -g fish_color_error red

      # Vim keybindings
      fish_vi_key_bindings

      # Bind H and L in normal mode to move back/forward in directory history
      bind \eh prevd-or-backward-word
      bind \el nextd-or-forward-word

      # Stop virtualenv from modifiying prompt
      set -g VIRTUAL_ENV_DISABLE_PROMPT 1

      # No help message
      set -U fish_greeting

      # Setup jump
      ${pkgs.jump}/bin/jump shell fish | source

      # Pokemon :3
      ${pkgs.krabby}/bin/krabby random --no-title
    '';
  };

  # Enable Catppuccin theming
  catppuccin.fish.enable = true;

  # Enable eza for a much nicer ls
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    colors = "auto";
    git = true;
    icons = "auto";
    extraOptions = [
      "-b" # Binary size prefixes
      "-h" # Add a header for each column
    ];
  };

  # Enable hyfetch for fancy termial systeminfo
  programs.hyfetch = {
    enable = true;
    settings = {
      preset = "lesbian";
      mode = "rgb";
      light_dark = "dark";
      color_align.mode = "horizontal";
      backend = "fastfetch";
      pride_month_disable = false;
    };
  };

  # Enable nix-your-shell to ensure nix-shell calls start a fish shell
  programs.nix-your-shell = {
    enable = true;
    enableFishIntegration = true;
  };

  # Enable `fuck` for correcting commands
  programs.thefuck = {
    enable = true;
    enableFishIntegration = true;
  };

  # Add some extra shell hook packages
  home.packages = with pkgs; [
    git-diffie
    jump
  ];
}
