{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    extraConfig = ''
      monitor = DP-1, highrr, 1920x0, 1
      monitor = HDMI-A-1, preferred, 0x0, 1

      general {
        border_size = 0
        gaps_in = 16
        gaps_out = 32
      }

      decoration {
        rounding = 16
        shadow_range = 4
        shadow_render_power = 1
        shadow_offset = 2 2
        col.shadow = 0x70000000
        dim_inactive = true
        dim_strength = 0.2

        blur {
          size = 2
          passes = 3
          noise = 0.05
        }
      }

      group {
        groupbar {
          font_family = Intur
          font_size = 12
          height = 24
          col.active = rgb(5b6078)
          col.inactive = rgb(24273a)
          col.locked_active = rgb(494d64)
          col.locked_inactive = rgb(1e2030)
        }
      }

      input {
        repeat_delay = 500
        follow_mouse = 1
      }

      misc {
        vrr = 2
      }

      dwindle {
        preserve_split = true;
      }

      cursor {
        inactive_timeout = 5
      }

      env = XCURSOR_THEME, ${config.gtk.cursorTheme.name}
      env = XCURSOR_SIZE, 24

      bezier = quickSnap, 0, 1, 0.7, 1
      animation = specialWorkspace, 1, 5, quickSnap, slidevert

      windowrulev2 = float,class:^(kitty-telnet-handler)$
      windowrulev2 = size 1155 632,class:^(kitty-telnet-handler)$
      windowrulev2 = tile,class:(winbox64\.exe)$
      windowrulev2 = tile,class:(designer\.exe)$,title:(Affinity Designer 2)$
      windowrulev2 = tile,class:(photo\.exe)$,title:(Affinity Photo 2)$

      # Quitting things
      bind = SUPER, Q, killactive,
      bind = SUPER SHIFT, Q, exit,

      # Focus windows
      bind = SUPER, H, movefocus, l
      bind = SUPER, J, movefocus, d
      bind = SUPER, K, movefocus, u
      bind = SUPER, L, movefocus, r

      # Swapping windows
      bind = SUPER SHIFT, H, swapwindow, l
      bind = SUPER SHIFT, J, swapwindow, d
      bind = SUPER SHIFT, K, swapwindow, u
      bind = SUPER SHIFT, L, swapwindow, r

      # Preselect direction for next window
      bind = SUPER ALT, H, layoutmsg, preselect l
      bind = SUPER ALT, J, layoutmsg, preselect d
      bind = SUPER ALT, K, layoutmsg, preselect u
      bind = SUPER ALT, L, layoutmsg, preselect r

      # Rotate window split
      bind = SUPER, R, layoutmsg, togglesplit

      # Resizing and moving windows
      bind = SUPER, M, submap, windowmanip
      submap = windowmanip
      binde = , H, moveactive, -25 0
      binde = , J, moveactive, 0 25
      binde = , K, moveactive, 0 -25
      binde = , L, moveactive, 25 0
      binde = SHIFT, H, resizeactive, -25 0
      binde = SHIFT, J, resizeactive, 0 25
      binde = SHIFT, K, resizeactive, 0 -25
      binde = SHIFT, L, resizeactive, 25 0
      bind  = , escape, submap, reset
      submap = reset

      # Grouping windows
      bind = SUPER, G, togglegroup
      bind = SUPER SHIFT, G, lockactivegroup, toggle
      bind = SUPER ALT, G, moveoutofgroup, active
      binde = SUPER, TAB, changegroupactive
      binde = SUPER SHIFT, TAB, movegroupwindow

      # Switch to workspace
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

      # Move window to workspace
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

      # Special popup terminal workspace
      bind = SUPER, grave, togglespecialworkspace, terminal
      windowrulev2 = workspace special:terminal, class:^(kitty-special-terminal)$
      windowrulev2 = float, class:^(kitty-special-terminal)$
      windowrulev2 = size 75% 60%, class:^(kitty-special-terminal)$
      windowrulev2 = center, class:^(kitty-special-terminal)$
      workspace = special:terminal, on-created-empty:${pkgs.kitty}/bin/kitty --class=kitty-special-terminal

      # Change window state
      bind = SUPER, T, togglefloating, active
      bind = SUPER, F, fullscreen, 0

      # Launch apps
      bind = SUPER, E, exec, ${pkgs.kitty}/bin/kitty ${pkgs.ranger}/bin/ranger
      bind = SUPER, return, exec, ${pkgs.kitty}/bin/kitty
      bind = SUPER, space, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun

      # Screenshot
      bind = SUPER, S, exec, ${pkgs.scr}/bin/scr -Mode Active -Clipboard
      bind = SUPER SHIFT, S, exec, ${pkgs.scr}/bin/scr -Mode Selection -Clipboard
      bind = SUPER ALT, S, exec, ${pkgs.scr}/bin/scr -Mode Screen -Clipboard

      # Move and resize windows with the mouse
      bindm = SUPER, mouse:272, movewindow
      bindm = SUPER, mouse:273, resizewindow

      # App rules
      windowrulev2 = workspace 1,class:^(firefox)$
      windowrulev2 = workspace 2,class:^(discord)$
      windowrulev2 = workspace 2,class:^(cinny)$
      windowrulev2 = group set,class:^(discord)$
      windowrulev2 = group set,class:^(cinny)$
      windowrulev2 = workspace 3,class:^(emacs)$

      exec-once = ${pkgs.wpaperd}/bin/wpaperd
    '';
  };

  xdg.configFile."wpaperd/wallpaper.toml".text = ''
    [default]
    path = "/home/ruby/img/papes"
    duration = "1h"
  '';
}
