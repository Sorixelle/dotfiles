{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = ''
        [┌](bold fg:cyan)[ $username@$hostname ](bg:black)[ $directory](bg:bright-black)[$nix_shell](bg:blue)$fill$status$cmd_duration$git_branch$elixir$rust$scala
        [└─](bold fg:cyan)$character
      '';

      fill.symbol = " ";

      cmd_duration.format = "[took $duration](italic fg:bright-white)";

      directory = {
        fish_style_pwd_dir_length = 1;
        read_only = "󰌾 ";
        style = "fg:cyan bg:bright-black";
        read_only_style = "italic fg:red bg:bright-black";
      };

      elixir = {
        format = "[ $symbol](fg:purple)[$version (\\(OTP $otp_version\\))]($style)";
        symbol = " ";
        style = "fg:bright-white";
      };

      git_branch = {
        format = "[ $symbol](fg:green)[$branch(:$remote_branch)]($style)";
        style = "fg:bright-white";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname](fg:purple bg:black)";
      };

      nix_shell = {
        format = "[ $symbol ]($style)";
        style = "fg:white bg:blue";
        symbol = " ";
      };

      rust = {
        format = "[ $symbol](fg:red)[$version]($style)";
        symbol = " ";
        style = "fg:bright-white";
      };

      scala = {
        detect_files = [
          ".sbtenv"
          ".scalaenv"
          "build.sbt"
          "build.sc"
        ];
        format = "[ $symbol](fg:red)[$version]($style)";
        symbol = " ";
        style = "fg:bright-white";
      };

      status = {
        disabled = false;
        symbol = " ";
      };

      username = {
        show_always = true;
        format = "[$user]($style bg:black)";
        style_user = "fg:green";
        style_root = "bold fg:yellow";
      };
    };
  };
}
