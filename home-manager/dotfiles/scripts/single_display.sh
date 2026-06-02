#!/bin/sh
# Single-display policy for sway: keep exactly one screen active.
#
# If any output other than the internal panel (eDP-1) is connected, disable
# eDP-1 so the external monitor is the only screen. With no external connected
# (laptop alone), keep eDP-1 enabled as the fallback. Re-evaluated on every
# output hotplug event, so plugging/unplugging HDMI/DP — and opening the lid
# while docked — never brings the internal panel back as a second screen.

INTERNAL="eDP-1"
SELF="$HOME/.config/scripts/single_display.sh"

# On sway reload exec_always starts a fresh copy; stop any previous instance
# (and its swaymsg subscribe child) so we don't stack subscribers. Skip our
# own PID.
for pid in $(pgrep -f "$SELF"); do
  [ "$pid" = "$$" ] || kill "$pid" 2>/dev/null
done

apply() {
  others=$(swaymsg -t get_outputs | jq -r --arg i "$INTERNAL" \
    '.[] | select(.name != $i) | .name')
  if [ -n "$others" ]; then
    swaymsg "output $INTERNAL disable" >/dev/null
  else
    swaymsg "output $INTERNAL enable" >/dev/null
  fi
}

apply
# Reapply on each output event (connect/disconnect/mode change).
swaymsg -t subscribe '["output"]' | while read -r _; do
  apply
done
