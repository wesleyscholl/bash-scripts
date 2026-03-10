#!/bin/bash

set -euo pipefail

COMMITS="${1:-20}"

show_usage() {
    cat << EOF
Usage: $0 [commit_count]

Check recent git commits for Signed-off-by trailers.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$COMMITS" =~ ^[0-9]+$ ]]; then
    echo "Error: commit_count must be a non-negative integer"
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: run inside a git repository"
    exit 1
fi

missing=0

while IFS= read -r hash; do
    body=$(git log -1 --pretty=%B "$hash")
    if ! grep -qi '^Signed-off-by:' <<< "$body"; then
        echo "MISSING_SIGNOFF: $hash"
        missing=1
    fi
done < <(git rev-list --max-count="$COMMITS" HEAD)

if (( missing == 1 )); then
    exit 1
fi

echo "All checked commits contain Signed-off-by trailer."
