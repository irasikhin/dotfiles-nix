#!/usr/bin/env bash

set -euo pipefail

# Keep state in the per-user runtime dir when available so it is isolated
# per session and cleaned up automatically.
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/double_mod_switch"
LAST_PRESS_FILE="$STATE_DIR/last_press_ns"
LOCK_FILE="$STATE_DIR/lock"
DOUBLE_PRESS_NS=400000000
STALE_PRESS_NS=2000000000
TARGET_WORKSPACE="terminal"

mkdir -p "$STATE_DIR"

run_workspace_command() {
  if [[ -n ${SWAYSOCK:-} ]] && command -v swaymsg >/dev/null 2>&1; then
    exec swaymsg "workspace $TARGET_WORKSPACE"
  fi

  exit 1
}

# Prevent overlapping invocations when Super is pressed repeatedly.
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

current_time=$(date +%s%N)

if [[ -f $LAST_PRESS_FILE ]]; then
  read -r last_time <"$LAST_PRESS_FILE" || last_time=0

  if [[ $last_time =~ ^[0-9]+$ ]]; then
    diff=$((current_time - last_time))

    if ((diff > 0 && diff < DOUBLE_PRESS_NS)); then
      rm -f "$LAST_PRESS_FILE"
      run_workspace_command
    fi

    # Ignore stale timestamps so an old file never affects later presses.
    if ((diff > STALE_PRESS_NS)); then
      rm -f "$LAST_PRESS_FILE"
    fi
  else
    rm -f "$LAST_PRESS_FILE"
  fi
fi

printf '%s\n' "$current_time" >"$LAST_PRESS_FILE"
