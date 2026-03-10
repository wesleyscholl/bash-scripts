#!/bin/bash

set -euo pipefail

THRESHOLD="${1:-80}"

show_usage() {
    cat << EOF
Usage: $0 [threshold_percent]

Monitor inode usage across mounted filesystems.

Arguments:
  threshold_percent   Alert threshold for inode usage (default: 80)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 1 || THRESHOLD > 100 )); then
    echo "Error: threshold must be an integer between 1 and 100"
    exit 1
fi

if ! command -v df >/dev/null 2>&1; then
    echo "Error: df command not available"
    exit 1
fi

ALERT=0

echo "Filesystem inode usage report (threshold: ${THRESHOLD}%)"

df -Pi | awk 'NR>1 {print $1, $5, $6}' | while read -r fs usage mount; do
    used_percent=${usage%%%}
    if (( used_percent >= THRESHOLD )); then
        echo "ALERT: $fs at $mount inode usage ${usage}"
        ALERT=1
    else
        echo "OK: $fs at $mount inode usage ${usage}"
    fi
done

if df -Pi | awk -v t="$THRESHOLD" 'NR>1 {gsub(/%/,"",$5); if ($5 >= t) found=1} END {exit !found}'; then
    exit 1
fi

exit 0
