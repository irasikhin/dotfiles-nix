#!/usr/bin/env bash

# Set the directory to search. You can modify this to your desired directory.
SEARCH_DIR="$HOME/.config/wallpaper"

# Destination directory for the selected image
DEST_DIR="$HOME/.background-image"

# Find all jpg and png files recursively and store them in an array
mapfile -t image_files < <(find "$SEARCH_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \))

# Check if the array is not empty
if [ ${#image_files[@]} -eq 0 ]; then
    echo "No image files found in the specified directory."
    exit 1
fi

# Randomly select an image from the array
RANDOM_IMAGE="${image_files[RANDOM % ${#image_files[@]}]}"

# Copy the randomly selected image to the destination directory
cp "$RANDOM_IMAGE" "$DEST_DIR"

# Output the path of the copied image
echo "Randomly selected image copied to $DEST_DIR: $(basename "$RANDOM_IMAGE")"