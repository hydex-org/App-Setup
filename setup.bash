#!/bin/bash

# Bash script to delete placeholder folders in src/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_PATH="$SCRIPT_DIR/src"

# Find all folders with "_PLACEHOLDER" in their name
placeholder_folders=$(find "$SRC_PATH" -maxdepth 1 -type d -name "*_PLACEHOLDER*")

if [ -z "$placeholder_folders" ]; then
    echo -e "\033[33mNo placeholder folders found in src/\033[0m"
    exit 0
fi

count=$(echo "$placeholder_folders" | wc -l | tr -d ' ')
echo -e "\033[36mFound $count placeholder folder(s) to delete:\033[0m"

echo "$placeholder_folders" | while read -r folder; do
    echo -e "  - \033[90m$(basename "$folder")\033[0m"
done

echo ""

echo "$placeholder_folders" | while read -r folder; do
    if rm -rf "$folder"; then
        echo -e "\033[32mDeleted: $(basename "$folder")\033[0m"
    else
        echo -e "\033[31mFailed to delete: $(basename "$folder")\033[0m"
    fi
done


echo ""
echo -e "\033[36mCleanup complete!\033[0m"