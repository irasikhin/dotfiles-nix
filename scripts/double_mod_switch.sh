#!/usr/bin/env bash

LAST_PRESS_FILE="/tmp/last_mod_press"
DOUBLE_PRESS_TIME=0.15

current_time=$(date +%s.%N)

if [ -f "$LAST_PRESS_FILE" ]; then
  last_time=$(cat "$LAST_PRESS_FILE")
  diff=$(echo "$current_time - $last_time" | bc)

  if (($(echo "$diff < $DOUBLE_PRESS_TIME" | bc -l))); then
    i3-msg workspace terminal
    rm "$LAST_PRESS_FILE"
    exit 0
  fi
fi

echo "$current_time" >"$LAST_PRESS_FILE"
