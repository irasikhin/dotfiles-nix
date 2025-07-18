{ pkgs, ... }:

let
  my-scripts = pkgs.runCommand "my-i3-scripts" { } ''
    mkdir -p $out/bin
    cp ${../../../scripts/double_mod_switch.sh} $out/bin/double_mod_switch
    cp ${../../../scripts/update_background_image.sh} $out/bin/update_background_image
    chmod +x $out/bin/*
  '';
in
{
  home.packages = [ my-scripts ];

  xdg.configFile."i3/config".text = ''
    set $mod Mod4
    set $alt Mod1
    default_border none
    font pango:FiraCode Nerd Font 12
    floating_modifier $mod
    workspace_auto_back_and_forth yes
    bindsym $mod+Return exec termite -e /bin/zsh
    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+a focus parent,kill
    bindsym $alt+d exec "rofi -show combi -sidebar-mode"
    bindsym $mod+Tab exec "rofi -show window"
    bindsym $mod+j focus left
    bindsym $mod+k focus down
    bindsym $mod+l focus up
    bindsym $mod+semicolon focus right
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right
    bindsym $mod+Shift+j move left
    bindsym $mod+Shift+k move down
    bindsym $mod+Shift+l move up
    bindsym $mod+Shift+semicolon move right
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right
    bindsym $mod+h split h
    bindsym $mod+v split v
    bindsym $mod+f fullscreen toggle
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split
    bindsym $mod+Shift+space floating toggle
    bindsym $mod+space focus mode_toggle
    bindsym $mod+a focus parent
    set $ws1 "1"
    set $ws2 "2"
    set $ws3 "3"
    set $ws4 "4"
    set $ws5 "5"
    set $ws6 "6"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    set $ws10 "10"
    bindsym $mod+1 workspace $ws1
    bindsym $mod+2 workspace $ws2
    bindsym $mod+3 workspace $ws3
    bindsym $mod+4 workspace $ws4
    bindsym $mod+5 workspace $ws5
    bindsym $mod+6 workspace $ws6
    bindsym $mod+7 workspace $ws7
    bindsym $mod+8 workspace $ws8
    bindsym $mod+9 workspace $ws9
    bindsym $mod+0 workspace $ws10
    bindsym $mod+Shift+1 move container to workspace $ws1
    bindsym $mod+Shift+2 move container to workspace $ws2
    bindsym $mod+Shift+3 move container to workspace $ws3
    bindsym $mod+Shift+4 move container to workspace $ws4
    bindsym $mod+Shift+5 move container to workspace $ws5
    bindsym $mod+Shift+6 move container to workspace $ws6
    bindsym $mod+Shift+7 move container to workspace $ws7
    bindsym $mod+Shift+8 move container to workspace $ws8
    bindsym $mod+Shift+9 move container to workspace $ws9
    bindsym $mod+Shift+0 move container to workspace $ws10
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+r restart
    bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"
    bindsym $mod+Shift+w exec "i3lock-color -k --keylayout 0 --image $HOME/.background-image"
    mode "resize" {
      bindsym j resize shrink width 10 px or 10 ppt
      bindsym k resize grow height 10 px or 10 ppt
      bindsym l resize shrink height 10 px or 10 ppt
      bindsym semicolon resize grow width 10 px or 10 ppt
      bindsym Left resize shrink width 10 px or 10 ppt
      bindsym Down resize grow height 10 px or 10 ppt
      bindsym Up resize shrink height 10 px or 10 ppt
      bindsym Right resize grow width 10 px or 10 ppt
      bindsym Return mode "default"
      bindsym Escape mode "default"
      bindsym $mod+r mode "default"
    }
    bindsym $mod+r mode "resize"
    bar {
      font pango: FiraCode Nerd Font 16
      position top
      status_command i3status-rs ~/.config/i3/status.toml
      colors {
        separator #666666
        background #222222
        statusline #dddddd
        focused_workspace #0088CC #0088CC #ffffff
        active_workspace #333333 #333333 #ffffff
        inactive_workspace #333333 #333333 #888888
        urgent_workspace #2f343a #900000 #ffffff
      }
    }
    focus_on_window_activation focus
    bindsym XF86AudioRaiseVolume exec --no-startup-id pamixer -i 5
    bindsym XF86AudioLowerVolume exec --no-startup-id pamixer -d 5
    bindsym XF86AudioMute exec --no-startup-id pamixer -t
    bindsym XF86MonBrightnessUp exec --no-startup-id brillo -A 5
    bindsym XF86MonBrightnessDown exec --no-startup-id brillo -U 5
    bindsym XF86AudioPlay exec playerctl play
    bindsym XF86AudioPause exec playerctl pause
    bindsym XF86AudioNext exec playerctl next
    bindsym XF86AudioPrev exec playerctl previous
    set $idea "idea"
    bindsym $mod+i workspace $idea
    assign [class=".*[I,i]dea.*"] $idea
    set $msg "msg"
    bindsym $mod+m workspace $msg
    assign [class=".*telegram-desktop.*"] $msg
    set $web "web"
    bindsym $mod+u workspace $web
    assign [class=".*[l,l]ibrewolf.*"] $web
    assign [class=".*[F,f]irefox.*"] $web
    assign [class=".*[C,c]hromium.*"] $web
    assign [class=".*[F,f]loorp.*"] $web
    set $discord "discord"
    bindsym $mod+d workspace $discord
    assign [class=".*[D,d]iscord.*"] $discord
    set $obsidian "obsidian"
    bindsym $mod+o workspace $obsidian
    assign [class=".*[O,o]bsidian.*"] $obsidian
    set $slack "slack"
    bindsym $mod+n workspace $slack
    assign [class=".*[S,s]lack.*"] $slack
    set $code "code"
    bindsym $mod+c workspace $code
    assign [class=".*[C,c]ode.*"] $code
    set $clion "clion"
    bindsym $mod+y workspace $clion
    assign [class=".*[C,c]lion.*"] $clion
    set $terminal "terminal"
    bindsym Super_L exec --no-startup-id "double_mod_switch"
    assign [class=".*[A,a]lacritty.*"] $terminal
    set $spotify "spotify"
    bindsym $mod+p workspace $spotify
    assign [class=".*[S,s]potify.*"] $spotify
    set $thunderbird "thunderbird"
    bindsym $mod+t workspace $thunderbird
    assign [class=".*[T,t]hunderbird.*"] $thunderbird
    for_window [class="^.*"] border pixel 0
    exec_always --no-startup-id nm-applet
    exec --no-startup-id i3-msg 'workspace $terminal; exec alacritty'
    exec --no-startup-id i3-msg 'workspace $web; exec floorp'
    exec --no-startup-id i3-msg 'workspace $idea; exec idea'
    exec --no-startup-id i3-msg 'workspace $msg; exec telegram-desktop'
    exec --no-startup-id i3-msg 'workspace $thunderbird; exec thunderbird'
    exec_always --no-startup-id "update_background_image"
  '';

  xdg.configFile."i3/status.toml".source = ../../dotfiles/i3/status.toml;
}
