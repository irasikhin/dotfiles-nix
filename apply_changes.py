#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# This script parses a patch file and applies changes (create, replace, delete)
# to the local filesystem.

import os
import re

# --- Configuration ---
# The patch file to read changes from.
PATCH_FILE = "refactor_patch.txt"


def apply_changes():
    """
    Parses the patch file and applies file system operations.
    """
    if not os.path.exists(PATCH_FILE):
        print(f"Error: Patch file '{PATCH_FILE}' not found.")
        print("Please ensure the file exists in the current directory.")
        return

    print(f"Starting to apply changes from '{PATCH_FILE}'...")

    # Read the entire patch file into memory.
    with open(PATCH_FILE, "r", encoding="utf-8") as f:
        content = f.read()

    # Regex to find all command blocks.
    # The pattern is non-greedy (.*?) to handle multiple blocks.
    # re.DOTALL makes '.' match newlines, which is crucial here.
    block_pattern = re.compile(
        r"===== START: (CREATE_OR_REPLACE|DELETE) (.*?) =====\n(.*?)"
        r"===== END: \1 \2 =====\n",
        re.DOTALL,
    )

    found_blocks = 0
    for match in block_pattern.finditer(content):
        found_blocks += 1
        action, file_path, block_content = match.groups()

        # Sanitize file path
        file_path = file_path.strip()

        if action == "DELETE":
            print(f"Action: DELETE, Path: {file_path}")
            if os.path.exists(file_path):
                os.remove(file_path)
                print(f"  -> Deleted: {file_path}")
            else:
                print(f"  -> Already deleted or does not exist: {file_path}")

        elif action == "CREATE_OR_REPLACE":
            print(f"Action: CREATE/REPLACE, Path: {file_path}")

            # Ensure the parent directory exists.
            dir_name = os.path.dirname(file_path)
            if dir_name:
                os.makedirs(dir_name, exist_ok=True)

            # Write the content to the file.
            # The block_content from regex already includes the necessary newlines.
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(block_content)
            print(f"  -> Wrote {len(block_content)} bytes to {file_path}")

    if found_blocks == 0:
        print("Warning: No valid change blocks found in the patch file.")
    else:
        print(f"\nSuccessfully processed {found_blocks} change blocks.")
        print("Review the changes with 'git status' and 'git diff'.")
        print("After reviewing, run your system's rebuild script.")


if __name__ == "__main__":
    apply_changes()
