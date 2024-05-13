{ pkgs, ... }:
let
  lock_time = 300;
  lock_grace = 10;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      monitor = ",preferred,auto,auto";

      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.swaybg}/bin/swaybg -i ~/spidy.png"
        "${pkgs.swayidle}/bin/swayidle timeout ${toString lock_time} 'hyprctl dispatcher dpms off' resume 'hyprctl dispatcher dpms on' timeout ${toString (lock_grace + lock_time)} swaylock"
      ];

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = 1;
          tap-to-click = false;
        };
        natural_scroll = true;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        scroll_method = "2fg";
      };

      misc = {
        force_default_wallpaper = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "master";
      };

      decoration = {
        rounding = 0;
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = false;
      };

      master = {
        new_is_master = true;
        new_on_top = false;
      };

      gestures = {
        workspace_swipe = false;
      };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod SHIFT, return, exec, kitty -o allow_remote_control=yes"
        "$mainMod, P, exec, bemenu-run"
        "$mainMod SHIFT, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," # dwindle

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        ", XF86AudioRaiseVolume, exec, volctl up"
        ", XF86AudioLowerVolume, exec, volctl down"

        ", XF86AudioRaiseVolume SHIFT, exec, volctl microup"
        ", XF86AudioLowerVolume SHIFT, exec, volctl microdown"
        ", XF86AudioMute, exec, volctl togglemute"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };
}
