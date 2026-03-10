#!/bin/bash

set -euo pipefail

HOST="${1:-}"
PORT="${2:-443}"
DAYS_THRESHOLD="${3:-30}"

show_usage() {
    cat << EOF
Usage: $0 <host> [port] [days_threshold]

Validate SSL certificate chain and expiry window.

Arguments:
  host            TLS host to check
  port            TLS port (default: 443)
  days_threshold  Alert if cert expires in less than this many days (default: 30)
EOF
}

if [[ -z "$HOST" || "$HOST" == "-h" || "$HOST" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! command -v openssl >/dev/null 2>&1; then
    echo "Error: openssl command not available"
    exit 1
fi

if ! [[ "$PORT" =~ ^[0-9]+$ ]] || ! [[ "$DAYS_THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: port and days_threshold must be non-negative integers"
    exit 1
fi

cert_output=$(echo | openssl s_client -servername "$HOST" -connect "$HOST:$PORT" 2>/dev/null)
if [[ -z "$cert_output" ]]; then
    echo "Error: failed to fetch certificate from $HOST:$PORT"
    exit 1
fi

verify_line=$(echo "$cert_output" | grep -E "Verify return code" | tail -1)
enddate=$(echo "$cert_output" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

if [[ -z "$enddate" ]]; then
    echo "Error: unable to parse certificate expiration"
    exit 1
fi

expiry_epoch=$(date -d "$enddate" +%s 2>/dev/null || true)
if [[ -z "$expiry_epoch" ]]; then
    echo "Error: unable to parse certificate date format"
    exit 1
fi

now_epoch=$(date +%s)
days_left=$(( (expiry_epoch - now_epoch) / 86400 ))

echo "Host: $HOST"
echo "Port: $PORT"
echo "Certificate expires: $enddate"
echo "Days remaining: $days_left"
echo "Verification: ${verify_line:-unknown}"

if (( days_left < DAYS_THRESHOLD )); then
    echo "ALERT: certificate expires in less than ${DAYS_THRESHOLD} days"
    exit 1
fi

if [[ "$verify_line" != *"Verify return code: 0"* ]]; then
    echo "ALERT: certificate chain verification failed"
    exit 1
fi

echo "OK: certificate chain valid and expiry above threshold"
