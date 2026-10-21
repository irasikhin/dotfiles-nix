#!/usr/bin/env sh
# Sway lock screen.
#
# Background is a pre-blurred, pre-dimmed copy of the wallpaper rendered by
# ImageMagick, NOT swaylock-effects' `--screenshots`. The screencopy path grabs
# the composited output on every lock, which is what left the screen red/blank
# after resume-from-suspend (and after a driver hiccup) -- and a red lock screen
# can only be escaped by logging in on another VT or by rebooting. A static image
# needs no screencopy at all, so the lock screen is reproducible and survives
# suspend. The cache is rebuilt whenever ~/.background-image changes.
#
# If the styled lock refuses to start, fall back to a bare solid-colour lock so
# a mistyped option can never leave the session unlocked.
#
# Escape hatch if a lock ever misbehaves: Ctrl+Alt+F3, log in on the text
# console and `pkill -x swaylock` (sway then returns to the desktop).

set -u

wall="$HOME/.background-image"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/swaylock"
bg="$cache/background.png"
plain="1d2021"

mkdir -p "$cache" 2>/dev/null

# 25% -> blur -> 400% blurs in a downscaled space (fast, smooth), then dim and
# tint towards the gruvbox background so text keeps contrast.
if [ -r "$wall" ]; then
  if [ ! -s "$bg" ] || [ "$wall" -nt "$bg" ]; then
    if magick "$wall" -resize 25% -blur 0x6 -resize 400% \
      -modulate 90,85 -fill "#$plain" -colorize 30% "$bg.tmp" 2>/dev/null; then
      mv -f "$bg.tmp" "$bg"
    else
      rm -f "$bg.tmp"
    fi
  fi
fi

# Single output (eDP-1) per sway config; `-s fill` keeps the aspect ratio.
if [ -s "$bg" ]; then
  bgspec="-i $bg -s fill"
else
  bgspec="-c $plain"
fi

# shellcheck disable=SC2086 # $bgspec is our own whitespace-free flag pair
if swaylock -f $bgspec \
  --fade-in 0.15 \
  --clock --timestr "%H:%M" --datestr "%A, %d %B" \
  --indicator --indicator-idle-visible \
  --indicator-radius 130 --indicator-thickness 10 \
  --ring-color 83a598a0 \
  --ring-ver-color fabd2fff \
  --ring-wrong-color fb4934ff \
  --ring-clear-color b8bb26ff \
  --ring-caps-lock-color fe8019ff \
  --inside-color 1d2021d8 \
  --inside-ver-color 3c3836e0 \
  --inside-wrong-color 402220e0 \
  --inside-clear-color 323d20e0 \
  --line-uses-inside \
  --separator-color 1d2021ff \
  --key-hl-color 8ec07cff \
  --bs-hl-color d3869bff \
  --layout-bg-color 1d2021dd \
  --layout-border-color 3c3836ff \
  --layout-text-color ebdbb2ff \
  --text-color ebdbb2ff \
  --text-ver-color fabd2fff \
  --text-wrong-color fb4934ff \
  --text-clear-color b8bb26ff \
  --font "FiraCode Nerd Font" \
  --font-size 36; then
  exit 0
fi

logger -t lock_screen "styled swaylock failed to start, locking with a plain colour"
exec swaylock -f -c "$plain"
