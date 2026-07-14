#!/usr/bin/env bash
set -euo pipefail

pid=${1:-}
if [ -z "$pid" ]; then
  pid=$(swaymsg -t get_tree | jq -r '.. | objects | select(.focused? == true) | .pid // empty' | head -1)
fi
[ -n "$pid" ] || exit 1
[ -d "/proc/$pid" ] || exit 1

pgid=$(ps -o pgid= -p "$pid" | tr -d ' ')
[ -n "$pgid" ] || exit 1

self_pgid=$(ps -o pgid= -p $$ | tr -d ' ')
sway_pid=$(pgrep -x sway | head -1)
sway_pgid=$(ps -o pgid= -p "$sway_pid" | tr -d ' ')
if [ "$pgid" = "$self_pgid" ] || [ "$pgid" = "$sway_pgid" ]; then
  exit 1
fi

name=$(ps -o comm= -p "$pid" | tr -d ' ')
notify() { command -v notify-send >/dev/null && notify-send "killapp" "$1" || true; }

kill -TERM -- "-$pgid" 2>/dev/null || exit 1

for _ in $(seq 30); do
  if ! kill -0 -- "-$pgid" 2>/dev/null; then
    notify "$name (pgid $pgid) закрыт"
    exit 0
  fi
  sleep 0.1
done

kill -KILL -- "-$pgid" 2>/dev/null || true
notify "$name (pgid $pgid) убит принудительно"
