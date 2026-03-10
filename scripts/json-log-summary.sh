#!/bin/bash

set -euo pipefail

LOG_FILE="${1:-}"

show_usage() {
    cat << EOF
Usage: $0 <json_log_file>

Summarize newline-delimited JSON logs by level and status code.

Arguments:
  json_log_file    Path to JSON log file (one JSON object per line)
EOF
}

if [[ -z "$LOG_FILE" ]] || [[ "$LOG_FILE" == "-h" ]] || [[ "$LOG_FILE" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: log file not found: $LOG_FILE"
    exit 1
fi

echo "JSON log summary for $LOG_FILE"

if command -v jq >/dev/null 2>&1; then
    echo "Level counts:"
    jq -r '.level // "UNKNOWN"' "$LOG_FILE" 2>/dev/null | sort | uniq -c | awk '{print "  " $2 ": " $1}'

    echo "HTTP status counts:"
    jq -r '.status // empty' "$LOG_FILE" 2>/dev/null | sort -n | uniq -c | awk '{print "  " $2 ": " $1}'
else
    echo "jq not found, using regex fallback"
    echo "Level counts (approximate):"
    grep -oE '"level"[[:space:]]*:[[:space:]]*"[A-Za-z]+"' "$LOG_FILE" | awk -F '"' '{print $4}' | sort | uniq -c | awk '{print "  " $2 ": " $1}'

    echo "HTTP status counts (approximate):"
    grep -oE '"status"[[:space:]]*:[[:space:]]*[0-9]+' "$LOG_FILE" | awk -F ':' '{gsub(/ /, "", $2); print $2}' | sort -n | uniq -c | awk '{print "  " $2 ": " $1}'
fi
