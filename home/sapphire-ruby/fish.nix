{ ... }:

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
            nix-shell -p nodePackages.pnpm --run "pnpx $argv"
          end
        '';
      };
    };

    interactiveShellInit = ''
      set -g fish_color_command blue
      set -g fish_color_param cyan
      set -g fish_color_redirection cyan
      set -g fish_color_end green
      set -g fish_color_quote yellow
      set -g fish_color_error red

      # Stop virtualenv from modifiying prompt
      set -g VIRTUAL_ENV_DISABLE_PROMPT 1
    '';
  };
}