#!/usr/bin/env bash

SEARCH_DIR="$HOME/.config/wallpaper"
DEST_IMAGE="$HOME/.background-image"

if [ ! -d "$SEARCH_DIR" ]; then
    echo "Wallpaper directory not found: $SEARCH_DIR"
    exit 1
fi

mapfile -t image_files < <(find "$SEARCH_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \))

if [ ${#image_files[@]} -eq 0 ]; then
    echo "No image files found in the specified directory."
    exit 1
fi

RANDOM_IMAGE="${image_files[RANDOM % ${#image_files[@]}]}"

cp "$RANDOM_IMAGE" "$DEST_IMAGE"
feh --bg-scale "$DEST_IMAGE"

echo "Set background to: $(basename "$RANDOM_IMAGE")"
