#!/bin/bash
# dns-lookup-check.sh — Verify DNS resolution for a list of hostnames and detect failures or unexpected IPs
# Usage: ./scripts/dns-lookup-check.sh [OPTIONS] <hostname> [hostname...]

set -euo pipefail

EXPECTED_IP=""
TIMEOUT=5
ALERT_COUNT=0

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <hostname> [hostname...]

Resolves each hostname via DNS and reports failures or mismatches.

Options:
  -e, --expected <ip>   Alert if resolved IP does not match this value
  -h, --help            Show this help message

Arguments:
  hostname              One or more hostnames to resolve

Examples:
  $(basename "$0") example.com api.example.com
  $(basename "$0") --expected 93.184.216.34 example.com
EOF
    exit 0
}

if [[ $# -eq 0 ]]; then
    echo "Error: at least one hostname is required."
    show_usage
fi

HOSTNAMES=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -e|--expected) EXPECTED_IP="$2"; shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage ;;
        *) HOSTNAMES+=("$1"); shift ;;
    esac
done

if [[ ${#HOSTNAMES[@]} -eq 0 ]]; then
    echo "Error: at least one hostname is required."
    show_usage
fi

if ! command -v dig >/dev/null 2>&1 && ! command -v nslookup >/dev/null 2>&1 && ! command -v host >/dev/null 2>&1; then
    echo "Error: dig, nslookup, or host command is required"
    exit 1
fi

resolve_hostname() {
    local hostname="$1"
    if command -v dig >/dev/null 2>&1; then
        dig +short +time="$TIMEOUT" "$hostname" A 2>/dev/null | grep -E '^[0-9]+\.' | head -1
    elif command -v host >/dev/null 2>&1; then
        host -W "$TIMEOUT" "$hostname" 2>/dev/null | awk '/has address/{print $4}' | head -1
    else
        nslookup "$hostname" 2>/dev/null | awk '/^Address:/{print $2}' | tail -1
    fi
}

echo "DNS lookup check — $(date '+%Y-%m-%d %H:%M:%S')"
echo "-----------------------------------------------"

for hostname in "${HOSTNAMES[@]}"; do
    resolved=$(resolve_hostname "$hostname")
    if [[ -z "$resolved" ]]; then
        echo "FAIL:  $hostname — could not resolve"
        (( ALERT_COUNT++ ))
    elif [[ -n "$EXPECTED_IP" && "$resolved" != "$EXPECTED_IP" ]]; then
        echo "MISMATCH: $hostname — resolved to $resolved (expected $EXPECTED_IP)"
        (( ALERT_COUNT++ ))
    else
        echo "OK:    $hostname → $resolved"
    fi
done

echo "-----------------------------------------------"
if [[ "$ALERT_COUNT" -gt 0 ]]; then
    echo "Result: $ALERT_COUNT issue(s) detected"
    exit 1
fi
echo "Result: all hostnames resolved successfully"
exit 0
