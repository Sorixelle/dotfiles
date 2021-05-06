lib: conf:

let
  colors = import ./colors.nix;
in {
  enable = true;
  monitors = lib.genAttrs conf.monitors (_:
    ["web" "chat" "code" "terminals" "games" "files" "gimp" "8" "9" "0"]
  );

  rules = {
    "Emacs" = {
      state = "tiled";
    };
  };

  extraConfig = ''
    bspc config normal_border_color "${colors.bg}"
    bspc config focused_border_color "${colors.blue}"
    bspc config presel_feedback_color "${colors.redLight}"
    bspc config window_gap 32
    bspc config border_width 10
    bspc config ignore_ewmh_struts true
  '';
}
