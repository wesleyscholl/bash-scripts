#!/bin/bash

set -euo pipefail

BACKUP_DIR="${1:-.}"
MIN_SIZE_MB="${2:-1}"

show_usage() {
    cat << EOF
Usage: $0 [backup_dir] [min_size_mb]

Validate backup archives and flag suspiciously small files.

Arguments:
  backup_dir    Directory containing backup archives (default: current directory)
  min_size_mb   Minimum expected archive size in MB (default: 1)

Supported archive types: .tar, .tar.gz, .tgz, .gz, .zip
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Error: backup directory not found: $BACKUP_DIR"
    exit 1
fi

if ! [[ "$MIN_SIZE_MB" =~ ^[0-9]+$ ]]; then
    echo "Error: min_size_mb must be a non-negative integer"
    exit 1
fi

MIN_SIZE_BYTES=$((MIN_SIZE_MB * 1024 * 1024))
FAILED=0
FOUND=0

echo "Checking backup integrity in: $BACKUP_DIR"

while IFS= read -r -d '' file; do
    FOUND=1
    size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file")
    status="OK"

    if (( size < MIN_SIZE_BYTES )); then
        status="SMALL"
        FAILED=1
    fi

    case "$file" in
        *.tar)
            tar -tf "$file" >/dev/null 2>&1 || { status="CORRUPT"; FAILED=1; }
            ;;
        *.tar.gz|*.tgz)
            tar -tzf "$file" >/dev/null 2>&1 || { status="CORRUPT"; FAILED=1; }
            ;;
        *.gz)
            gzip -t "$file" >/dev/null 2>&1 || { status="CORRUPT"; FAILED=1; }
            ;;
        *.zip)
            if command -v unzip >/dev/null 2>&1; then
                unzip -t "$file" >/dev/null 2>&1 || { status="CORRUPT"; FAILED=1; }
            else
                status="SKIP(no-unzip)"
            fi
            ;;
    esac

    printf "%s | %s bytes | %s\n" "$file" "$size" "$status"
done < <(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name "*.tar" -o -name "*.tar.gz" -o -name "*.tgz" -o -name "*.gz" -o -name "*.zip" \) -print0)

if (( FOUND == 0 )); then
    echo "No backup archives found."
    exit 2
fi

if (( FAILED == 1 )); then
    echo "Backup integrity check completed with issues."
    exit 1
fi

echo "Backup integrity check passed."
