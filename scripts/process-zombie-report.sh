#!/bin/bash

set -euo pipefail

show_usage() {
    cat << EOF
Usage: $0

Report zombie processes found on the host.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! command -v ps >/dev/null 2>&1; then
    echo "Error: ps command not available"
    exit 1
fi

zombies=$(ps -eo pid,ppid,stat,comm | awk '$3 ~ /Z/ {print}')

if [[ -n "$zombies" ]]; then
    echo "ALERT: zombie processes detected"
    echo "$zombies"
    exit 1
fi

echo "OK: no zombie processes detected"
