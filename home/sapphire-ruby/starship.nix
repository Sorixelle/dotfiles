{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = "$directory$character";
      right_format = "$nix_shell $git_branch $elixir";

      directory = {
        format = "[$path]($style)[ $read_only]($read_only_style)";
        read_only = "󰌾";
        style = "fg:cyan";
        read_only_style = "fg:red";
        fish_style_pwd_dir_length = 1;
      };
      elixir = {
        format =
          "[$symbol](fg:purple)[ $version (\\(OTP $otp_version\\))]($style)";
        symbol = "";
        style = "fg:bright-black";
      };
      git_branch = {
        format = "[$symbol](fg:green)[$branch(:$remote_branch)]($style)";
        style = "fg:bright-black";
      };
      nix_shell = {
        format = "[$symbol]($style)";
        style = "fg:cyan";
        symbol = " ";
      };
    };
  };
}
