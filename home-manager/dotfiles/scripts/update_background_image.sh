#!/usr/bin/env bash

set -euo pipefail

SUBREDDIT="${WALLPAPER_SUBREDDIT:-wallpapers}"
CACHE_LIMIT="${WALLPAPER_CACHE_LIMIT:-50}"
REDDIT_URL="https://www.reddit.com/r/${SUBREDDIT}/top.json?t=week&limit=100"
USER_AGENT="${WALLPAPER_USER_AGENT:-ir-wallpaper-rotator/1.0}"
LOCAL_FALLBACK_DIR="${HOME}/.config/wallpaper"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpapers/reddit/${SUBREDDIT}"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/wallpaper-rotator"
LOCK_FILE="${STATE_DIR}/lock"
DEST_IMAGE="${HOME}/.background-image"
DEST_BLUR="${HOME}/.background-image-blur"
DISPLAY="${DISPLAY:-:0}"

mkdir -p "$CACHE_DIR" "$STATE_DIR"

exec 9>"$LOCK_FILE"
flock -n 9 || exit 0

reddit_candidates_file="$(mktemp "${STATE_DIR}/reddit-candidates.XXXXXX")"
fallback_candidates_file="$(mktemp "${STATE_DIR}/fallback-candidates.XXXXXX")"
cleanup() {
  rm -f "$reddit_candidates_file" "$fallback_candidates_file"
}
trap cleanup EXIT

download_reddit_candidates() {
  if ! curl -fsSL -A "$USER_AGENT" "$REDDIT_URL" | jq -r '
    .data.children[]
    | .data as $post
    | ($post.url_overridden_by_dest // $post.url // "") as $url
    | select(($post.over_18 // false) | not)
    | select($url | test("\\.(jpe?g|png|webp)(\\?.*)?$"; "i"))
    | "\($post.id)\t\($url)"
  ' > "$reddit_candidates_file"; then
    return 1
  fi

  [[ -s "$reddit_candidates_file" ]]
}

download_to_cache() {
  local post_id="$1"
  local image_url="$2"
  local extension filename destination tmpfile

  extension="${image_url##*.}"
  extension="${extension%%\?*}"
  extension="${extension,,}"

  case "$extension" in
    jpg | jpeg | png | webp) ;;
    *)
      return 0
      ;;
  esac

  filename="${post_id}.${extension}"
  destination="${CACHE_DIR}/${filename}"

  if [[ -f "$destination" ]]; then
    return 0
  fi

  tmpfile="$(mktemp "${STATE_DIR}/wallpaper-download.XXXXXX")"
  if curl -fsSL -A "$USER_AGENT" "$image_url" -o "$tmpfile"; then
    mv "$tmpfile" "$destination"
  else
    rm -f "$tmpfile"
  fi
}

trim_cache() {
  local extra

  mapfile -t extra < <(
    find "$CACHE_DIR" -maxdepth 1 -type f -printf '%T@ %p\n' \
      | sort -nr \
      | tail -n +"$((CACHE_LIMIT + 1))" \
      | cut -d' ' -f2-
  )

  if (( ${#extra[@]} > 0 )); then
    rm -f "${extra[@]}"
  fi
}

build_fallback_candidates() {
  if [[ -d "$LOCAL_FALLBACK_DIR" ]]; then
    find "$LOCAL_FALLBACK_DIR" -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      > "$fallback_candidates_file"
  fi
}

select_random_file() {
  local source_file="$1"
  local -n target_ref="$2"
  local candidates

  mapfile -t candidates < "$source_file"
  if (( ${#candidates[@]} == 0 )); then
    return 1
  fi

  target_ref="${candidates[RANDOM % ${#candidates[@]}]}"
}

apply_wallpaper() {
  if [[ -n "${SWAYSOCK:-}" ]] && command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg >/dev/null 2>&1 || true
    nohup swaybg -i "$DEST_IMAGE" -m fill >/dev/null 2>&1 &
    return
  fi

}

generate_blur() {
  if command -v magick >/dev/null 2>&1; then
    magick "$DEST_IMAGE" -resize 25% -blur 0x8 -resize 400% "$DEST_BLUR"
  else
    convert "$DEST_IMAGE" -resize 25% -blur 0x8 -resize 400% "$DEST_BLUR"
  fi
}

if download_reddit_candidates; then
  while IFS=$'\t' read -r post_id image_url; do
    [[ -n "$post_id" && -n "$image_url" ]] || continue
    download_to_cache "$post_id" "$image_url"
  done < "$reddit_candidates_file"
fi

trim_cache
build_fallback_candidates

selected_image=""

if mapfile -t _cache_files < <(find "$CACHE_DIR" -maxdepth 1 -type f | sort) && (( ${#_cache_files[@]} > 0 )); then
  printf '%s\n' "${_cache_files[@]}" > "$reddit_candidates_file"
  select_random_file "$reddit_candidates_file" selected_image
elif [[ -s "$fallback_candidates_file" ]]; then
  select_random_file "$fallback_candidates_file" selected_image
elif [[ -f "$DEST_IMAGE" ]]; then
  selected_image="$DEST_IMAGE"
else
  echo "No wallpapers available from Reddit cache or local fallback directory." >&2
  exit 1
fi

if [[ "$selected_image" != "$DEST_IMAGE" ]]; then
  cp "$selected_image" "$DEST_IMAGE"
fi

generate_blur
apply_wallpaper

echo "Applied wallpaper: $(basename "$selected_image")"
