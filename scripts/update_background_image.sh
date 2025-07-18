#!/usr/bin/env bash

# Set the directory to search. You can modify this to your desired directory.
SEARCH_DIR="$HOME/.config/wallpaper"

# Destination for the selected image
# i3 will use this static path to set the lock screen background
DEST_IMAGE="$HOME/.background-image"

# Ensure the wallpaper directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Wallpaper directory not found: $SEARCH_DIR"
    exit 1
fi

# Find all jpg and png files recursively and store them in an array
mapfile -t image_files < <(find "$SEARCH_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \))

# Check if the array is not empty
if [ ${#image_files[@]} -eq 0 ]; then
    echo "No image files found in the specified directory."
    exit 1
fi

# Randomly select an image from the array
RANDOM_IMAGE="${image_files[RANDOM % ${#image_files[@]}]}"

# Copy the randomly selected image to the destination
cp "$RANDOM_IMAGE" "$DEST_IMAGE"
# Also set it as the background using feh
feh --bg-scale "$DEST_IMAGE"

echo "Set background to: $(basename "$RANDOM_IMAGE")"
