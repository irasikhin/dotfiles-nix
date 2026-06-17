#!/usr/bin/env bash

set -euo pipefail

# Themed wallpaper rotator backed by the wallhaven.cc API.
#
# Reddit's old anonymous .json endpoints now return HTTP 403 (OAuth required /
# datacenter blocked), so this fetches from wallhaven instead — no API key is
# needed for SFW content. Each run picks a random theme query, downloads a small
# batch into a persistent local pool, trims the pool, then selects a random
# wallpaper from it, sets it as the sway background and mirrors it to the SDDM
# login screen. The local pool means rotation still works offline.
#
# WALLPAPER_QUERIES is a comma-separated list of themes. Multi-word themes use
# '+' for spaces (e.g. "the+witcher") because systemd Environment= splits values
# on whitespace; the script converts '+' back to a space before URL-encoding.

QUERIES_RAW="${WALLPAPER_QUERIES:-nature,cyberpunk,landscape,space}"
CACHE_LIMIT="${WALLPAPER_CACHE_LIMIT:-80}"
BATCH="${WALLPAPER_BATCH:-8}"
ATLEAST="${WALLPAPER_ATLEAST:-2560x1440}"
CATEGORIES="${WALLPAPER_CATEGORIES:-100}" # 100 = general only
PURITY="${WALLPAPER_PURITY:-100}"         # 100 = SFW only
APIKEY="${WALLHAVEN_API_KEY:-}"
PROXY="${WALLPAPER_PROXY:-}"
USER_AGENT="${WALLPAPER_USER_AGENT:-ir-wallpaper-rotator/2.0}"

LOCAL_FALLBACK_DIR="${HOME}/.config/wallpaper"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpapers/wallhaven"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-rotator"
LOCK_FILE="${STATE_DIR}/lock"
DEST_IMAGE="${HOME}/.background-image"
GREETER_IMAGE="/var/lib/greeter-wallpaper/bg.jpg"

mkdir -p "$CACHE_DIR" "$STATE_DIR"

# Single-flight: a backgrounded swaybg must NOT inherit this fd (see
# apply_wallpaper), or it would hold the lock forever and make every later run
# exit here silently.
exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

curl_opts=(-fsSL -m 30 -A "$USER_AGENT")
[[ -n $PROXY ]] && curl_opts+=(-x "$PROXY")

fallback_candidates_file="$(mktemp "${STATE_DIR}/fallback-candidates.XXXXXX")"
cleanup() {
  rm -f "$fallback_candidates_file"
}
trap cleanup EXIT

pick_query() {
  local -a queries
  IFS=',' read -ra queries <<<"$QUERIES_RAW"
  local raw="${queries[RANDOM % ${#queries[@]}]}"
  # '+' is our space placeholder (systemd-safe); restore real spaces.
  printf '%s' "${raw//+/ }"
}

fetch_batch() {
  local query="$1" json
  local -a args=(
    -G "https://wallhaven.cc/api/v1/search"
    --data-urlencode "q=${query}"
    --data-urlencode "categories=${CATEGORIES}"
    --data-urlencode "purity=${PURITY}"
    --data-urlencode "sorting=random"
    --data-urlencode "atleast=${ATLEAST}"
  )
  [[ -n $APIKEY ]] && args+=(--data-urlencode "apikey=${APIKEY}")

  if ! json="$(curl "${curl_opts[@]}" "${args[@]}")"; then
    return 1
  fi

  printf '%s' "$json" | jq -r --argjson n "$BATCH" '
    [.data[] | {id, path}] | .[0:$n][] | "\(.id)\t\(.path)"'
}

download_to_cache() {
  local id="$1" image_url="$2" extension destination tmpfile

  extension="${image_url##*.}"
  extension="${extension,,}"

  case "$extension" in
  jpg | jpeg | png | webp) ;;
  *)
    return 0
    ;;
  esac

  destination="${CACHE_DIR}/wallhaven-${id}.${extension}"

  if [[ -f $destination ]]; then
    return 0
  fi

  tmpfile="$(mktemp "${STATE_DIR}/wallpaper-download.XXXXXX")"
  if curl "${curl_opts[@]}" "$image_url" -o "$tmpfile"; then
    mv "$tmpfile" "$destination"
  else
    rm -f "$tmpfile"
  fi
}

trim_cache() {
  local extra

  mapfile -t extra < <(
    find "$CACHE_DIR" -maxdepth 1 -type f -printf '%T@ %p\n' |
      sort -nr |
      tail -n +"$((CACHE_LIMIT + 1))" |
      cut -d' ' -f2-
  )

  if ((${#extra[@]} > 0)); then
    rm -f "${extra[@]}"
  fi
}

build_fallback_candidates() {
  if [[ -d $LOCAL_FALLBACK_DIR ]]; then
    find "$LOCAL_FALLBACK_DIR" -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      >"$fallback_candidates_file"
  fi
}

select_random_file() {
  local source_file="$1"
  local -n target_ref="$2"
  local candidates

  mapfile -t candidates <"$source_file"
  if ((${#candidates[@]} == 0)); then
    return 1
  fi

  target_ref="${candidates[RANDOM % ${#candidates[@]}]}"
}

apply_wallpaper() {
  if [[ -n ${SWAYSOCK:-} ]] && command -v swaybg >/dev/null 2>&1; then
    # The nix wrapper's process name is ".swaybg-wrapped", so an anchored
    # `pkill -x swaybg` would miss it; match by substring instead.
    pkill swaybg >/dev/null 2>&1 || true
    # Close fd 9 (the flock fd) in the swaybg child: a backgrounded swaybg lives
    # forever and would otherwise inherit and hold the lock, making every later
    # run fail `flock -n` and exit silently.
    nohup swaybg -i "$DEST_IMAGE" -m fill 9>&- >/dev/null 2>&1 &
    return
  fi
}

mirror_greeter() {
  # Mirror the sharp wallpaper to the SDDM login background. The greeter user
  # (sddm) cannot read $HOME, so a world-readable copy lives in /var/lib
  # (directory provisioned by systemd.tmpfiles in nixos/modules/display.nix).
  # The sddm-astronaut theme dims it itself for legibility. install sets mode
  # 0644 regardless of umask; write to a temp name and rename so the greeter
  # never reads a half-written file. Non-fatal, but log failures.
  if ! { install -m 0644 "$DEST_IMAGE" "${GREETER_IMAGE}.tmp" &&
    mv -f "${GREETER_IMAGE}.tmp" "$GREETER_IMAGE"; }; then
    echo "warning: failed to mirror greeter wallpaper" >&2
  fi
}

theme="$(pick_query)"

if batch="$(fetch_batch "$theme")" && [[ -n $batch ]]; then
  while IFS=$'\t' read -r post_id image_url; do
    [[ -n $post_id && -n $image_url ]] || continue
    download_to_cache "$post_id" "$image_url"
  done <<<"$batch"
else
  echo "warning: wallhaven fetch failed for '${theme}', using existing pool" >&2
fi

trim_cache
build_fallback_candidates

selected_image=""
pool_file="$(mktemp "${STATE_DIR}/pool.XXXXXX")"

if find "$CACHE_DIR" -maxdepth 1 -type f >"$pool_file" && [[ -s $pool_file ]]; then
  select_random_file "$pool_file" selected_image
elif [[ -s $fallback_candidates_file ]]; then
  select_random_file "$fallback_candidates_file" selected_image
elif [[ -f $DEST_IMAGE ]]; then
  selected_image="$DEST_IMAGE"
else
  rm -f "$pool_file"
  echo "No wallpapers available from wallhaven pool or local fallback." >&2
  exit 1
fi
rm -f "$pool_file"

if [[ $selected_image != "$DEST_IMAGE" ]]; then
  cp "$selected_image" "$DEST_IMAGE"
fi

mirror_greeter
apply_wallpaper

echo "Applied wallpaper: $(basename "$selected_image") (theme: ${theme})"
