#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This script recursively finds all files in the current directory
# and combines their content into a single output file.

import os

# --- Configuration ---
# The name of the output file.
OUTPUT_FILE = "combined_output.txt"
# Directories to exclude from the search.
EXCLUDE_DIRS = {".git", ".idea", "__pycache__"}
# Files to exclude from the search.
EXCLUDE_FILES = {OUTPUT_FILE, "collect_files.py", "apply_changes.py", "flake.lock"}


def main():
    """
    Main function to walk through directories and collect file contents.
    """
    # Open the output file in write mode, which clears it first.
    # Use utf-8 encoding for broad compatibility.
    with open(OUTPUT_FILE, "w", encoding="utf-8") as outfile:
        # os.walk provides the directory path, a list of subdirectories, and a list of files.
        for root, dirs, files in os.walk("."):
            # Modify the list of directories in-place to prevent os.walk from descending into them.
            # This is the idiomatic way to prune directories with os.walk.
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]

            # Sort files for a consistent order in the output file.
            for filename in sorted(files):
                if filename in EXCLUDE_FILES:
                    continue

                # Construct the full path to the file.
                file_path = os.path.join(root, filename)

                try:
                    # Write a header for the file.
                    header = f"===== НАЧАЛО ФАЙЛА: {file_path} =====\n"
                    outfile.write(header)

                    # Open and read the content of the current file.
                    with open(
                        file_path, "r", encoding="utf-8", errors="ignore"
                    ) as infile:
                        content = infile.read()
                        outfile.write(content)

                    # Write a footer for the file.
                    footer = f"\n===== КОНЕЦ ФАЙЛА: {file_path} =====\n\n"
                    outfile.write(footer)

                    print(f"Collected: {file_path}")

                except Exception as e:
                    print(f"Error processing file {file_path}: {e}")

    print(f"\nAll files have been combined into {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
