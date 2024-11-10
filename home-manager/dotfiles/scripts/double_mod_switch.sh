#!/usr/bin/env bash

# File to store the time of the last key press
LAST_PRESS_FILE="/tmp/last_mod_press"

# Time interval for double press detection (in seconds)
DOUBLE_PRESS_TIME=0.15

# Get the current time
current_time=$(date +%s.%N)

# Check if the file exists and read the last press time
if [ -f "$LAST_PRESS_FILE" ]; then
  last_time=$(cat "$LAST_PRESS_FILE")
  diff=$(echo "$current_time - $last_time" | bc)

  # If the press occurred within the interval, switch to the terminal workspace
  if (($(echo "$diff < $DOUBLE_PRESS_TIME" | bc -l))); then
    i3-msg workspace terminal
    rm "$LAST_PRESS_FILE"
    exit 0
  fi
fi

# Update or create the file with the current time
echo "$current_time" >"$LAST_PRESS_FILE"
