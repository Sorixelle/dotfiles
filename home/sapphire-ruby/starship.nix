{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format =
        "$username$hostname$directory$nix_shell$git_branch$git_status$elixir$fill$cmd_duration$time $line_break$character";

      directory = {
        format = "[ $path ]($style)[$read_only]($read_only_style)";
        read_only = "🔒 ";
        style = "bg:black";
        read_only_style = "fg:red bg:black";
        fish_style_pwd_dir_length = 1;
      };
      elixir = {
        format = "[ $symbol $version (\\(OTP $otp_version\\) )]($style)";
        symbol = "";
        style = "bg:purple";
      };
      fill = { symbol = " "; };
      git_branch = {
        format = "[ $symbol$branch(:$remote_branch) ]($style)";
        style = "bg:green";
      };
      git_status = {
        format = "[($all_status$ahead_behind )]($style)";
        style = "bg:green";
      };
      hostname = {
        format = "[@$hostname ]($style)";
        style = "bg:blue";
        ssh_only = false;
      };
      nix_shell = {
        format = "[ $symbol ]($style)";
        style = "bg:cyan";
        symbol = "";
      };
      time = {
        disabled = false;
        format = "[$time]($style)";
        style = "white";
        time_format = "%I:%M:%S %P";
      };
      username = {
        format = "[ $user]($style)";
        style_root = "bg:blue";
        style_user = "bg:blue";
        show_always = true;
      };
    };
  };
}
