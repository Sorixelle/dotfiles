{ pkgs, ... }:

{
  xdg.configFile = {
    "hypr/hyprpaper.conf" = {
      text = ''
        preload = ${./wp.png}
        wallpaper = DP-4,${./wp.png}
        wallpaper = HDMI-A-2,${./wp.png}
      '';
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      monitor=HDMI-A-2,1920x1080@60,0x0,1

      # So I have no idea what the flying fuck is going on with this monitor. If
      # I set it initially to 170Hz, the cursor gets real laggy when moving
      # between windows. If I set it to 120Hz, then back to 170Hz, everything is
      # fine. No idea why, and I feel like the answer will give me permanent
      # warp, so I just do this and be content with it.
      monitor=DP-4,2560x1440@120,1920x0,1
      exec-once=${pkgs.hyprland}/bin/hyprctl keyword monitor DP-4,2560x1440@170,1920x0,1

      general {
        border_size = 3
        gaps_in = 30
        gaps_out = 75
        col.inactive_border = 0xFF121E1D
        col.active_border = 0xFF40772B
      }

      decoration {
        rounding = 3
        blur = true
        blur_size = 8
        blur_passes = 3
        blur_new_optimizations = true
        drop_shadow = false
      }
      blurls=launcher

      input {
        accel_profile = flat
      }

      exec=${pkgs.hyprpaper}/bin/hyprpaper

      bind=SUPER,Q,killactive,
      bind=SUPER_SHIFT,Q,exit,
      bind=SUPER,return,exec,alacritty
      bind=SUPER,space,exec,${pkgs.tofi}/bin/tofi-drun --drun-launch=true

      bind=SUPER,T,togglefloating,active
      bind=SUPER_SHIFT,T,pseudo,
      bind=SUPER,F,fullscreen,0
      bind=SUPER_SHIFT,F,fullscreen,1
      bind=SUPER,P,pin,

      bind=SUPER,H,movefocus,l
      bind=SUPER,J,movefocus,d
      bind=SUPER,K,movefocus,u
      bind=SUPER,L,movefocus,r
      bind=SUPER_SHIFT,H,movewindow,l
      bind=SUPER_SHIFT,J,movewindow,d
      bind=SUPER_SHIFT,K,movewindow,u
      bind=SUPER_SHIFT,L,movewindow,r

      bind=SUPER,W,submap,windowmove
      submap=windowmove

      binde=,H,moveactive,-25 0
      binde=,J,moveactive,0 25
      binde=,K,moveactive,0 -25
      binde=,L,moveactive,25 0
      binde=SHIFT,H,resizeactive,-25 0
      binde=SHIFT,J,resizeactive,0 25
      binde=SHIFT,K,resizeactive,0 -25
      binde=SHIFT,L,resizeactive,25 0
      bind=,return,submap,reset
      bind=,escape,submap,reset
      bind=SUPER,W,submap,reset

      submap=reset

      bind=SUPER,1,workspace,1
      bind=SUPER,2,workspace,2
      bind=SUPER,3,workspace,3
      bind=SUPER,4,workspace,4
      bind=SUPER,5,workspace,5
      bind=SUPER,6,workspace,6
      bind=SUPER,7,workspace,7
      bind=SUPER,8,workspace,8
      bind=SUPER,9,workspace,9
      bind=SUPER,0,workspace,0

      bind=SUPER_SHIFT,1,movetoworkspace,1
      bind=SUPER_SHIFT,2,movetoworkspace,2
      bind=SUPER_SHIFT,3,movetoworkspace,3
      bind=SUPER_SHIFT,4,movetoworkspace,4
      bind=SUPER_SHIFT,5,movetoworkspace,5
      bind=SUPER_SHIFT,6,movetoworkspace,6
      bind=SUPER_SHIFT,7,movetoworkspace,7
      bind=SUPER_SHIFT,8,movetoworkspace,8
      bind=SUPER_SHIFT,9,movetoworkspace,9
      bind=SUPER_SHIFT,0,movetoworkspace,0

      bind=SUPER,grave,togglespecialworkspace,
      bind=SUPER_SHIFT,grave,movetoworkspace,special

      bind=SUPER,bracketleft,movecurrentworkspacetomonitor,l
      bind=SUPER,bracketright,movecurrentworkspacetomonitor,r
    '';
  };
}
