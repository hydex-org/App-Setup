#!/bin/bash

# Bash script to delete placeholder folders in src/ and clone repos

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_PATH="$SCRIPT_DIR/src"

echo -e "\033[36mScript running from: $SCRIPT_DIR\033[0m"
echo -e "\033[36mSource path: $SRC_PATH\033[0m"

# Find all folders with "_PLACEHOLDER" in their name
placeholder_folders=$(find "$SRC_PATH" -maxdepth 1 -type d -name "*_PLACEHOLDER*" 2>/dev/null)

if [ -z "$placeholder_folders" ]; then
    echo -e "\033[33mNo placeholder folders found in src/\033[0m"
else
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
fi

# Clone repositories into src/
echo ""
echo -e "\033[36mCloning repositories into $SRC_PATH ...\033[0m"

# Use HTTPS URLs (works without SSH keys on CI/CD runners)
repos=(
    "https://github.com/hydex-org/bridge-custody.git"
    "https://github.com/hydex-org/hydex-frontend.git"
    "https://github.com/hydex-org/enclaveenv.git"
    "https://github.com/hydex-org/frost-pallas.git"
    "https://github.com/hydex-org/hydexAPI.git"
)

# Ensure src directory exists
mkdir -p "$SRC_PATH"

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    target_dir="$SRC_PATH/$repo_name"
    
    if [ -d "$target_dir" ]; then
        echo -e "\033[33mSkipping $repo_name (already exists at $target_dir)\033[0m"
    else
        echo -e "Cloning \033[90m$repo_name\033[0m into $target_dir..."
        if git clone "$repo" "$target_dir" 2>&1; then
            echo -e "\033[32mCloned: $repo_name\033[0m"
        else
            echo -e "\033[31mFailed to clone: $repo_name\033[0m"
        fi
    fi
done

# Checkout main branch for each repository
echo ""
echo -e "\033[36mChecking out main branch...\033[0m"

for repo in "${repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    target_dir="$SRC_PATH/$repo_name"
    
    if [ -d "$target_dir" ]; then
        echo -e "Switching \033[90m$repo_name\033[0m to main..."
        if git -C "$target_dir" checkout main 2>/dev/null; then
            echo -e "\033[32mChecked out main: $repo_name\033[0m"
        else
            echo -e "\033[31mFailed to checkout main: $repo_name (branch may not exist)\033[0m"
        fi
    fi
done

echo ""
echo -e "\033[36mSetup complete!\033[0m"
echo ""
echo -e "\033[36mFinal directory structure:\033[0m"
ls -la "$SRC_PATH" 2>/dev/null || echo "src/ directory not found"
