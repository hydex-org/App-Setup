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

# Clone repositories into src/
echo ""
echo -e "\033[36mCloning repositories...\033[0m"

repos=(
    "git@github.com:hydex-org/bridge-custody.git"
    "git@github.com:hydex-org/hydex-frontend.git"
    "git@github.com:hydex-org/enclaveenv.git"
    "git@github.com:hydex-org/frost-pallas.git"
    "git@github.com:hydex-org/hydexAPI.git"
)

cd "$SRC_PATH"

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ -d "$repo_name" ]; then
        echo -e "\033[33mSkipping $repo_name (already exists)\033[0m"
    else
        echo -e "Cloning \033[90m$repo_name\033[0m..."
        if git clone "$repo" 2>/dev/null; then
            echo -e "\033[32mCloned: $repo_name\033[0m"
        else
            echo -e "\033[31mFailed to clone: $repo_name\033[0m"
        fi
    fi
done

# Checkout DevToProd branch for each repository
echo ""
echo -e "\033[36mChecking out DevToProd branch...\033[0m"

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ -d "$repo_name" ]; then
        cd "$SRC_PATH/$repo_name"
        echo -e "Switching \033[90m$repo_name\033[0m to DevToProd..."
        if git checkout DevToProd 2>/dev/null; then
            echo -e "\033[32mChecked out DevToProd: $repo_name\033[0m"
        else
            echo -e "\033[31mFailed to checkout DevToProd: $repo_name (branch may not exist)\033[0m"
        fi
        cd "$SRC_PATH"
    fi
done

echo ""
echo -e "\033[36mSetup complete!\033[0m"