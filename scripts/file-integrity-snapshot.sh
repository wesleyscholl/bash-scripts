#!/bin/bash

set -euo pipefail

MODE="${1:-create}"
TARGET_PATH="${2:-.}"
MANIFEST_FILE="${3:-integrity-manifest.sha256}"

show_usage() {
    cat << EOF
Usage: $0 <create|verify> [target_path] [manifest_file]

Create or verify file integrity snapshots using sha256 checksums.

Arguments:
  create|verify   Mode of operation
  target_path     Directory or file to snapshot/verify (default: current directory)
  manifest_file   Manifest path (default: integrity-manifest.sha256)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ "$MODE" != "create" && "$MODE" != "verify" ]]; then
    echo "Error: mode must be create or verify"
    exit 1
fi

if ! command -v sha256sum >/dev/null 2>&1; then
    echo "Error: sha256sum command not available"
    exit 1
fi

if [[ "$MODE" == "create" ]]; then
    if [[ ! -e "$TARGET_PATH" ]]; then
        echo "Error: target path not found: $TARGET_PATH"
        exit 1
    fi

    if [[ -d "$TARGET_PATH" ]]; then
        _tmpfile=$(mktemp)
        find "$TARGET_PATH" -type f ! -name "$(basename "$MANIFEST_FILE")" -print0 | sort -z | xargs -0 sha256sum > "$_tmpfile"
        mv "$_tmpfile" "$MANIFEST_FILE"
    else
        sha256sum "$TARGET_PATH" > "$MANIFEST_FILE"
    fi

    echo "Integrity manifest created: $MANIFEST_FILE"
    exit 0
fi

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "Error: manifest file not found: $MANIFEST_FILE"
    exit 1
fi

if sha256sum -c "$MANIFEST_FILE"; then
    echo "Integrity verification passed."
    exit 0
fi

echo "Integrity verification failed."
exit 1
