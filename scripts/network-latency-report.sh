#!/bin/bash
# network-latency-report.sh — Ping a list of hosts and report round-trip time statistics
# Usage: ./scripts/network-latency-report.sh [OPTIONS] <host> [host...]

set -euo pipefail

COUNT=5
THRESHOLD=200  # ms
ALERT_COUNT=0

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <host> [host...]

Pings each host and reports average latency. Alerts when latency exceeds threshold.

Options:
  -c, --count <n>         Number of ping packets to send (default: $COUNT)
  -t, --threshold <ms>    Latency alert threshold in ms (default: ${THRESHOLD}ms)
  -h, --help              Show this help message

Arguments:
  host    One or more hostnames or IP addresses to probe

Examples:
  $(basename "$0") 8.8.8.8 1.1.1.1
  $(basename "$0") --count 10 --threshold 100 google.com
EOF
    exit "${1:-0}"
}

if [[ $# -eq 0 ]]; then
    echo "Error: at least one host is required."
    show_usage 2
fi

HOSTS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -c|--count)
            COUNT="$2"
            if ! [[ "$COUNT" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: count must be a positive integer"
                exit 1
            fi
            shift 2 ;;
        -t|--threshold)
            THRESHOLD="$2"
            if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
                echo "Error: threshold must be a non-negative integer"
                exit 1
            fi
            shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage 2 ;;
        *) HOSTS+=("$1"); shift ;;
    esac
done

if [[ ${#HOSTS[@]} -eq 0 ]]; then
    echo "Error: at least one host is required."
    show_usage 2
fi

if ! command -v ping >/dev/null 2>&1; then
    echo "Error: ping command is required"
    exit 1
fi

echo "Network latency report — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Packets: $COUNT  |  Alert threshold: ${THRESHOLD}ms"
echo "------------------------------------------------------"

for host in "${HOSTS[@]}"; do
    output=$(ping -c "$COUNT" -W 2 "$host" 2>/dev/null || true)
    avg=$(echo "$output" | awk -F'/' '/^(round-trip|rtt)/{print $5}' 2>/dev/null || true)
    if [[ -z "$avg" ]]; then
        echo "UNREACHABLE: $host — no response"
        (( ALERT_COUNT++ ))
        continue
    fi
    avg_int=$(echo "$avg" | awk '{printf "%d", $1}')
    if (( avg_int > THRESHOLD )); then
        echo "HIGH:  $host — avg ${avg}ms (threshold ${THRESHOLD}ms)"
        (( ALERT_COUNT++ ))
    else
        echo "OK:    $host — avg ${avg}ms"
    fi
done

echo "------------------------------------------------------"
if [[ "$ALERT_COUNT" -gt 0 ]]; then
    echo "Result: $ALERT_COUNT host(s) with issues"
    exit 1
fi
echo "Result: all hosts within threshold"
exit 0
