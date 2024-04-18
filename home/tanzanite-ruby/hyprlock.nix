{ ... }:

{
  programs.hyprlock = {
    enable = true;

    general = { hide_cursor = true; };

    backgrounds = [{
      path = "screenshot";
      blur_size = 3;
      blur_passes = 4;
      noise = 5.0e-2;
    }];

    input-fields = [{
      size = {
        width = 750;
        height = 125;
      };
      position = {
        x = 0;
        y = 0;
      };
      halign = "center";
      valign = "center";

      font_color = "rgb(48, 52, 70)";
      inner_color = "rgba(115, 121, 148, 0.8)";
      outer_color = "rgb(115, 121, 148)";
      check_color = "rgb(229, 200, 144)";
      fail_color = "rgb(231, 130, 132)";

      placeholder_text = "";
      fail_text = "";
      fade_on_empty = false;
    }];

    labels = [
      {
        text = "<i>locked</i>";
        color = "rgb(198, 208, 245)";
        font_size = 40;
        position = {
          x = 32;
          y = 32;
        };
        valign = "bottom";
        halign = "left";
      }
      {
        text = "<i>$TIME</i>";
        color = "rgb(198, 208, 245)";
        font_size = 32;
        position = {
          x = -32;
          y = 32;
        };
        valign = "bottom";
        halign = "right";
      }
    ];
  };
}
