#!/bin/bash
# large-file-finder.sh — Find the largest files in a directory tree, sorted by size
# Usage: ./scripts/large-file-finder.sh [OPTIONS] [directory]

set -euo pipefail

TOP_N=20
MIN_SIZE_MB=10
SEARCH_DIR="."

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [directory]

Finds the largest files under directory and prints them sorted by size (largest first).

Options:
  -n, --top <n>         Number of files to display (default: $TOP_N)
  -m, --min-size <mb>   Minimum file size in MB to include (default: ${MIN_SIZE_MB}MB)
  -h, --help            Show this help message

Arguments:
  directory   Root directory to search (default: current directory)

Examples:
  $(basename "$0")
  $(basename "$0") --top 10 --min-size 50 /var
  $(basename "$0") /home
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -n|--top)
            TOP_N="$2"
            if ! [[ "$TOP_N" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: top must be a positive integer"
                exit 1
            fi
            shift 2 ;;
        -m|--min-size)
            MIN_SIZE_MB="$2"
            if ! [[ "$MIN_SIZE_MB" =~ ^[0-9]+$ ]]; then
                echo "Error: min-size must be a non-negative integer"
                exit 1
            fi
            shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage ;;
        *) SEARCH_DIR="$1"; shift ;;
    esac
done

if [[ ! -d "$SEARCH_DIR" ]]; then
    echo "Error: directory not found: $SEARCH_DIR"
    exit 1
fi

MIN_SIZE_BYTES=$(( MIN_SIZE_MB * 1024 * 1024 ))

echo "Large file finder — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Directory: $SEARCH_DIR"
echo "  Min size:  ${MIN_SIZE_MB} MB"
echo "  Top N:     $TOP_N"
echo "-------------------------------------------"

find "$SEARCH_DIR" -type f -size +"${MIN_SIZE_BYTES}c" -print0 2>/dev/null \
    | xargs -0 du -b 2>/dev/null \
    | sort -rn \
    | head -n "$TOP_N" \
    | awk '{
        size=$1
        if (size>=1073741824)   printf "%8.1f GB  ", size/1073741824
        else if (size>=1048576) printf "%8.1f MB  ", size/1048576
        else if (size>=1024)    printf "%8.1f KB  ", size/1024
        else                    printf "%8d  B   ", size
        for (i=2; i<=NF; i++) printf "%s ", $i
        print ""
    }'

echo "-------------------------------------------"
echo "Done."
exit 0
