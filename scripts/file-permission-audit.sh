#!/bin/bash

set -euo pipefail

TARGET_DIR="${1:-.}"

show_usage() {
    cat << EOF
Usage: $0 [target_dir]

Find world-writable files under a directory.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: directory not found: $TARGET_DIR"
    exit 1
fi

found=0
while IFS= read -r -d '' file; do
    echo "WORLD_WRITABLE: $file"
    found=1
done < <(find "$TARGET_DIR" -type f -perm -0002 -print0)

if (( found == 1 )); then
    exit 1
fi

echo "No world-writable files found in $TARGET_DIR"
