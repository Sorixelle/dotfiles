{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    recommendedEnvironment = true;

    extraConfig = ''
      monitor = DP-1, highrr, 1920x0, 1
      monitor = HDMI-A-1, preferred, 0x0, 1

      general {
        border_size = 0
        gaps_in = 16
        gaps_out = 32
        cursor_inactive_timeout = 5
      }

      decoration {
        rounding = 16
        shadow_range = 4
        shadow_render_power = 1
        shadow_offset = 2 2
        col.shadow = 0x70000000
        dim_inactive = true
        dim_strength = 0.2
      }

      input {
        repeat_delay = 500
        follow_mouse = 1
      }

      misc {
        vrr = 2
      }

      bezier = smoothPopIn, 0.22, 0.17, 0, 1
      animation = windowsIn, 1, 7, smoothPopIn, popin
      animation = windowsOut, 1, 7, smoothPopIn, popin

      bind = SUPER, Q, killactive,
      bind = SUPER SHIFT, Q, exit,

      bind = SUPER, H, movefocus, l
      bind = SUPER, J, movefocus, d
      bind = SUPER, K, movefocus, u
      bind = SUPER, L, movefocus, r

      bind = SUPER SHIFT, H, swapwindow, l
      bind = SUPER SHIFT, J, swapwindow, d
      bind = SUPER SHIFT, K, swapwindow, u
      bind = SUPER SHIFT, L, swapwindow, r

      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5
      bind = SUPER, 6, workspace, 6
      bind = SUPER, 7, workspace, 7
      bind = SUPER, 8, workspace, 8
      bind = SUPER, 9, workspace, 9
      bind = SUPER, 0, workspace, 10

      bind = SUPER SHIFT, 1, movetoworkspace, 1
      bind = SUPER SHIFT, 2, movetoworkspace, 2
      bind = SUPER SHIFT, 3, movetoworkspace, 3
      bind = SUPER SHIFT, 4, movetoworkspace, 4
      bind = SUPER SHIFT, 5, movetoworkspace, 5
      bind = SUPER SHIFT, 6, movetoworkspace, 6
      bind = SUPER SHIFT, 7, movetoworkspace, 7
      bind = SUPER SHIFT, 8, movetoworkspace, 8
      bind = SUPER SHIFT, 9, movetoworkspace, 9
      bind = SUPER SHIFT, 0, movetoworkspace, 10

      bind = SUPER, T, togglefloating, active
      bind = SUPER, F, fullscreen, 0

      bind = SUPER, E, exec, ${pkgs.kitty}/bin/kitty ${pkgs.ranger}/bin/ranger
      bind = SUPER, return, exec, ${pkgs.kitty}/bin/kitty
      bind = SUPER, space, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun

      bind = SUPER, S, exec, ${pkgs.scr}/bin/scr -Mode Active -Clipboard
      bind = SUPER SHIFT, S, exec, ${pkgs.scr}/bin/scr -Mode Selection -Clipboard
      bind = SUPER ALT, S, exec, ${pkgs.scr}/bin/scr -Mode Screen -Clipboard

      bindm = SUPER, mouse:272, movewindow
      bindm = SUPER, mouse:273, resizewindow

      exec-once = ${pkgs.wpaperd}/bin/wpaperd
    '';
  };

  xdg.configFile."wpaperd/wallpaper.toml".text = ''
    [default]
    path = "/home/ruby/usr/img/papes"
    duration = "1h"
  '';
}
