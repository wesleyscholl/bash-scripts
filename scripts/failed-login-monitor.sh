#!/bin/bash

set -euo pipefail

WINDOW_MINUTES="${1:-60}"
ALERT_THRESHOLD="${2:-10}"
LOG_FILE="${AUTH_LOG_FILE:-/var/log/auth.log}"

show_usage() {
    cat << EOF
Usage: $0 [window_minutes] [alert_threshold]

Count failed SSH logins in the recent time window.

Arguments:
  window_minutes    Lookback window in minutes (default: 60)
  alert_threshold   Number of failures to trigger alert (default: 10)

Environment:
  AUTH_LOG_FILE     Override auth log path (default: /var/log/auth.log)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$WINDOW_MINUTES" =~ ^[0-9]+$ ]] || ! [[ "$ALERT_THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: window_minutes and alert_threshold must be non-negative integers"
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: auth log file not found: $LOG_FILE"
    exit 1
fi

current_epoch=$(date +%s)
cutoff_epoch=$((current_epoch - WINDOW_MINUTES * 60))

count=$(awk -v cutoff="$cutoff_epoch" '
BEGIN {
    split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", m, " ")
    for (i=1; i<=12; i++) month[m[i]] = i
}
/Failed password/ {
    log_epoch = mktime(strftime("%Y") " " month[$1] " " $2 " " $3)
    if (log_epoch >= cutoff) c++
}
END {print c+0}
' "$LOG_FILE")

echo "Failed SSH logins in last ${WINDOW_MINUTES} minutes: $count"

if (( count >= ALERT_THRESHOLD )); then
    echo "ALERT: failed login threshold exceeded"
    exit 1
fi

echo "OK: failed login count below threshold"
