#!/bin/bash

set -euo pipefail

URL="${1:-}"
THRESHOLD_MS="${2:-500}"

show_usage() {
    cat << EOF
Usage: $0 <url> [threshold_ms]

Measure API response latency and alert if threshold is exceeded.
EOF
}

if [[ -z "$URL" || "$URL" == "-h" || "$URL" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$THRESHOLD_MS" =~ ^[0-9]+$ ]]; then
    echo "Error: threshold_ms must be a non-negative integer"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl command not available"
    exit 1
fi

latency_sec=$(curl -o /dev/null -s -w '%{time_total}' "$URL")
latency_ms=$(awk -v t="$latency_sec" 'BEGIN {printf "%d", t * 1000}')

echo "URL: $URL"
echo "Latency: ${latency_ms}ms"

if (( latency_ms > THRESHOLD_MS )); then
    echo "ALERT: latency above threshold (${THRESHOLD_MS}ms)"
    exit 1
fi

echo "OK: latency within threshold"
