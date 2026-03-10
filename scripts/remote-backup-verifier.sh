#!/bin/bash

set -euo pipefail

REMOTE_HOST="${1:-}"
REMOTE_PATH="${2:-}"

show_usage() {
    cat << EOF
Usage: $0 <remote_host> <remote_path>

Verify remote backup path is reachable and non-empty via SSH.
EOF
}

if [[ -z "$REMOTE_HOST" || -z "$REMOTE_PATH" || "$REMOTE_HOST" == "-h" || "$REMOTE_HOST" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! command -v ssh >/dev/null 2>&1; then
    echo "Error: ssh command not available"
    exit 1
fi

count=$(ssh -o BatchMode=yes -o ConnectTimeout=10 "$REMOTE_HOST" "find '$REMOTE_PATH' -maxdepth 1 -type f 2>/dev/null | wc -l" 2>/dev/null || true)

if [[ -z "$count" ]]; then
    echo "Error: unable to query remote path"
    exit 1
fi

echo "Remote host: $REMOTE_HOST"
echo "Remote path: $REMOTE_PATH"
echo "File count: $count"

if (( count == 0 )); then
    echo "ALERT: remote backup path is empty"
    exit 1
fi

echo "OK: remote backup path has files"
