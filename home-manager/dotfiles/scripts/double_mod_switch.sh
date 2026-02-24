#!/usr/bin/env bash

# Path to the file storing the timestamp of the last key press
LAST_PRESS_FILE="/tmp/last_mod_press"

# Time threshold for double-press detection in nanoseconds (0.15 seconds)
DOUBLE_PRESS_TIME=150000000

# Get current time in seconds + nanoseconds as a single integer
current_time=$(date +%s%N)

# Check if the last press file exists
if [ -f "$LAST_PRESS_FILE" ]; then

  # Read the timestamp of the previous press from the file
  last_time=$(cat "$LAST_PRESS_FILE")

  # Calculate the difference between current and last timestamp
  diff=$((current_time - last_time))

  # If difference is less than threshold, it's a double press
  if [ "$diff" -lt "$DOUBLE_PRESS_TIME" ]; then

    # Switch to the 'terminal' workspace using i3-msg
    i3-msg workspace terminal

    # Remove the timestamp file after action
    rm "$LAST_PRESS_FILE"

    # Exit successfully after handling double press
    exit 0
  fi
fi

# Store current timestamp in the file for next press detection
echo "$current_time" > "$LAST_PRESS_FILE"

