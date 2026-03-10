#!/bin/bash
# disk-throughput-test.sh — Benchmark sequential read and write throughput on a directory
# Usage: ./scripts/disk-throughput-test.sh [OPTIONS] [directory]

set -euo pipefail

TEST_DIR="${TMPDIR:-/tmp}"
FILE_SIZE_MB=100
BLOCK_SIZE="1M"

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [directory]

Writes a test file and reads it back to measure disk throughput.

Options:
  -s, --size <mb>       Test file size in MB (default: $FILE_SIZE_MB)
  -h, --help            Show this help message

Arguments:
  directory   Target directory for the benchmark (default: $TEST_DIR)

Examples:
  $(basename "$0")
  $(basename "$0") --size 256 /mnt/data
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -s|--size)
            FILE_SIZE_MB="$2"
            if ! [[ "$FILE_SIZE_MB" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: size must be a positive integer"
                exit 1
            fi
            shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage ;;
        *) TEST_DIR="$1"; shift ;;
    esac
done

if [[ ! -d "$TEST_DIR" ]]; then
    echo "Error: directory not found: $TEST_DIR"
    exit 1
fi

if ! command -v dd >/dev/null 2>&1; then
    echo "Error: dd command is required"
    exit 1
fi

TEST_FILE="${TEST_DIR}/disk_throughput_test_$$.tmp"

cleanup() { rm -f "$TEST_FILE"; }
trap cleanup EXIT

echo "Disk throughput test — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Directory:  $TEST_DIR"
echo "  File size:  ${FILE_SIZE_MB} MB"
echo "  Block size: $BLOCK_SIZE"
echo "-----------------------------------------------"

# Write test
echo "Write test..."
write_result=$(dd if=/dev/urandom of="$TEST_FILE" bs="$BLOCK_SIZE" count="$FILE_SIZE_MB" 2>&1)
write_speed=$(echo "$write_result" | awk '/copied/{for(i=1;i<=NF;i++) if($i~/MB\/s|GB\/s/) {print $(i-1),$i}}' | tail -1)
echo "  Write speed: ${write_speed:-N/A}"

# Flush page cache if possible (requires root on Linux), otherwise skip
sync
if [[ -w /proc/sys/vm/drop_caches ]]; then
    echo 1 > /proc/sys/vm/drop_caches 2>/dev/null || true
fi

# Read test
echo "Read test..."
read_result=$(dd if="$TEST_FILE" of=/dev/null bs="$BLOCK_SIZE" 2>&1)
read_speed=$(echo "$read_result" | awk '/copied/{for(i=1;i<=NF;i++) if($i~/MB\/s|GB\/s/) {print $(i-1),$i}}' | tail -1)
echo "  Read speed:  ${read_speed:-N/A}"

echo "-----------------------------------------------"
echo "Benchmark complete."
exit 0
