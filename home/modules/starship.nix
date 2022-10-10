{ config, lib, ... }:

let conf = config.srxl.starship;
in with lib; {
  options.srxl.starship = {
    enable = mkEnableOption ''
      Starship with my configuration.

      The consuming configuration must set the desired shell integrations in
      programs.starship itself.
    '';

    styles = {
      directory = mkOption {
        type = types.str;
        description = "Style for the directory component.";
      };
      directoryReadOnly = mkOption {
        type = types.str;
        description =
          "Style for the read only icon in the directory component.";
      };
      elixir = mkOption {
        type = types.str;
        description = "Style for the Elixir version component.";
      };
      git = mkOption {
        type = types.str;
        description = "Style for the Git status component.";
      };
      hostname = mkOption {
        type = types.str;
        description = "Style for the username@hostname component.";
      };
      nix = mkOption {
        type = types.str;
        description = "Style for the Nix component.";
      };
      time = mkOption {
        type = types.str;
        description = "Style for the time component.";
      };
    };
  };

  config = mkIf conf.enable {
    programs.starship = {
      inherit (conf) enable;
      settings = {
        format =
          "$username$hostname$directory$nix_shell$git_branch$git_status$elixir$fill$cmd_duration$time $line_break$character";

        directory = {
          format = "[ $path ]($style)[$read_only]($read_only_style)";
          read_only = "🔒 ";
          style = conf.styles.directory;
          read_only_style = conf.styles.directoryReadOnly;
          fish_style_pwd_dir_length = 1;
        };
        elixir = {
          format = "[ $symbol $version (\\(OTP $otp_version\\) )]($style)";
          symbol = "";
          style = conf.styles.elixir;
        };
        fill = { symbol = " "; };
        git_branch = {
          format = "[ $symbol$branch(:$remote_branch) ]($style)";
          style = conf.styles.git;
        };
        git_status = {
          format = "[($all_status$ahead_behind )]($style)";
          style = conf.styles.git;
        };
        hostname = {
          format = "[@$hostname ]($style)";
          style = conf.styles.hostname;
          ssh_only = false;
        };
        nix_shell = {
          format = "[ $symbol ]($style)";
          style = conf.styles.nix;
          symbol = "";
        };
        time = {
          disabled = false;
          format = "[$time]($style)";
          style = conf.styles.time;
          time_format = "%I:%M:%S %P";
        };
        username = {
          format = "[ $user]($style)";
          style_root = conf.styles.hostname;
          style_user = conf.styles.hostname;
          show_always = true;
        };
      };
    };
  };
}
