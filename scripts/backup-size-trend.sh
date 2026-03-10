#!/bin/bash

set -euo pipefail

BACKUP_DIR="${1:-.}"
TOP_N="${2:-10}"

show_usage() {
    cat << EOF
Usage: $0 [backup_dir] [top_n]

Show largest backup files to spot retention anomalies.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$TOP_N" =~ ^[0-9]+$ ]]; then
    echo "Error: top_n must be a non-negative integer"
    exit 1
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Error: backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo "Largest backup files in $BACKUP_DIR"
find "$BACKUP_DIR" -maxdepth 1 -type f -print0 | xargs -r0 du -h 2>/dev/null | sort -hr | head -n "$TOP_N"
