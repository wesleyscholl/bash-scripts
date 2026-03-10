#!/bin/bash

set -euo pipefail

HOST="${1:-}"
PORT="${2:-}"
TIMEOUT="${3:-5}"

show_usage() {
    cat << EOF
Usage: $0 <host> <port> [timeout_seconds]

Check raw TCP connectivity to a host and port.
EOF
}

if [[ -z "$HOST" || -z "$PORT" || "$HOST" == "-h" || "$HOST" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$PORT" =~ ^[0-9]+$ ]] || ! [[ "$TIMEOUT" =~ ^[0-9]+$ ]]; then
    echo "Error: port and timeout_seconds must be non-negative integers"
    exit 1
fi

if command -v nc >/dev/null 2>&1; then
    if nc -z -w "$TIMEOUT" "$HOST" "$PORT"; then
        echo "OK: TCP connectivity succeeded for $HOST:$PORT"
        exit 0
    fi
else
    if timeout "$TIMEOUT" bash -c "</dev/tcp/$HOST/$PORT" >/dev/null 2>&1; then
        echo "OK: TCP connectivity succeeded for $HOST:$PORT"
        exit 0
    fi
fi

echo "ALERT: TCP connectivity failed for $HOST:$PORT"
exit 1
