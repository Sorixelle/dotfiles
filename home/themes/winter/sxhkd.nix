{
  enable = true;
  keybindings = {
    # Open terminal
    "super + Return" = "kitty";
    # Open app launcher
    "super + @space" = "rofi -show drun";

    # Show last notification
    "super + grave" =                 "dunstctl history-pop";
    # Dismiss notifications
    "super + {_,shift + }backslash" = "dunstctl {close,close-all}";

    # Exit to login
    "super + ctrl + q"      = "bspc quit";
    # Reload sxhkd config
    "super + ctrl + r"      = "pkill -USR1 -x sxhkd";
    # Close/kill window
    "super + {_,shift + }w" = "bspc node -{c,k}";

    # Toggle fullscreen window
    "super + f"             = "bspc node -t ~fullscreen";
    # Toggle floating window
    "super + c"             = "bspc node -t ~floating";
    # Toggle (pseudo-)tiled window
    "super + {_,shift + }t" = "bspc node -t ~{tiled,pseudo_tiled}";
    # Toggle monocle mode
    "super + m"             = "bspc desktop -l next";

    # Move focus/window
    "super + {_,shift + }{h,j,k,l}"            = "bspc node -{f,s} {west,south,north,east}";
    # Focus next/previous window
    "super + {_,alt + }Tab"                    = "bspc node -f {next,prev}.local.!hidden.window";
    # Focus/send window to desktop
    "super + {_,shift + }{1-9,0}"              = "bspc {desktop -f,node -d} '^{1-9,10}'";
    # Swap with biggest window
    "super + g"                                = "bspc node -s biggest.local.!hidden.window";
    # Grow window size
    "super + alt + {h,j,k,l}"                  = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
    # Shrink window size
    "super + alt + shift + {h,j,k,l}"          = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
    # Preselect new window
    "super + ctrl + {h,j,k,l}"                 = "bspc node -p ~{west,south,north,east}";
    # Cancel preselection
    "super + Escape"                           = "bspc node -p cancel";
    # Move floating windows
    "super + {_,shift + }{Up,Down,Left,Right}" = "bspc node -v {0 -10,0 -50,0 10,0 50,-10 0,-50 0,10 0,50 0}";
  };
}
