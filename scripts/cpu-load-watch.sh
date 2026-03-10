#!/bin/bash

set -euo pipefail

THRESHOLD="${1:-2.0}"

show_usage() {
    cat << EOF
Usage: $0 [load_threshold]

Check 1-minute load average against a threshold.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: load_threshold must be numeric"
    exit 1
fi

load_1m=$(awk '{print $1}' /proc/loadavg 2>/dev/null || uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)

echo "1-minute load average: $load_1m"
echo "Threshold: $THRESHOLD"

if awk -v l="$load_1m" -v t="$THRESHOLD" 'BEGIN {exit !(l > t)}'; then
    echo "ALERT: load is above threshold"
    exit 1
fi

echo "OK: load is within threshold"
