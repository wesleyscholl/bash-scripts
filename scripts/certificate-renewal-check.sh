#!/bin/bash
# certificate-renewal-check.sh — Check whether TLS certificates need renewal and output actionable status
# Usage: ./scripts/certificate-renewal-check.sh [OPTIONS] <cert-file-or-host> [...]

set -euo pipefail

WARN_DAYS=30
CRIT_DAYS=7
ALERT_COUNT=0

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <cert-file-or-host[:port]> [...]

Checks certificate expiry for local PEM files or live HTTPS/SMTPS/IMAPS hosts.
Exits non-zero if any certificate is within the critical or warning window.

Options:
  -w, --warn-days <days>   Warn threshold in days (default: $WARN_DAYS)
  -c, --crit-days <days>   Critical threshold in days (default: $CRIT_DAYS)
  -h, --help               Show this help message

Arguments:
  cert-file-or-host   Path to a PEM certificate file, or host[:port] for a live check

Examples:
  $(basename "$0") /etc/ssl/certs/my.crt
  $(basename "$0") --warn-days 60 --crit-days 14 example.com:443 api.example.com
EOF
    exit "${1:-0}"
}

if [[ $# -eq 0 ]]; then
    echo "Error: at least one certificate file or host is required."
    show_usage 2
fi

TARGETS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -w|--warn-days)
            WARN_DAYS="$2"
            if ! [[ "$WARN_DAYS" =~ ^[0-9]+$ ]]; then echo "Error: warn-days must be an integer"; exit 1; fi
            shift 2 ;;
        -c|--crit-days)
            CRIT_DAYS="$2"
            if ! [[ "$CRIT_DAYS" =~ ^[0-9]+$ ]]; then echo "Error: crit-days must be an integer"; exit 1; fi
            shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage 2 ;;
        *) TARGETS+=("$1"); shift ;;
    esac
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo "Error: at least one certificate file or host is required."
    show_usage 2
fi

if ! command -v openssl >/dev/null 2>&1; then
    echo "Error: openssl command is required"
    exit 1
fi

check_cert() {
    local target="$1"
    local enddate

    if [[ -f "$target" ]]; then
        enddate=$(openssl x509 -in "$target" -noout -enddate 2>/dev/null | cut -d= -f2)
    else
        local host port
        host="${target%%:*}"
        port="${target##*:}"
        [[ "$port" == "$host" ]] && port=443
        enddate=$(echo | openssl s_client -servername "$host" -connect "${host}:${port}" 2>/dev/null \
            | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    fi

    if [[ -z "$enddate" ]]; then
        echo "ERROR: $target — could not retrieve certificate"
        (( ALERT_COUNT++ ))
        return
    fi

    local expiry_epoch now_epoch days_left
    expiry_epoch=$(date -d "$enddate" +%s 2>/dev/null || date -jf "%b %d %T %Y %Z" "$enddate" +%s 2>/dev/null)
    now_epoch=$(date +%s)
    days_left=$(( (expiry_epoch - now_epoch) / 86400 ))

    if (( days_left < 0 )); then
        echo "EXPIRED:  $target — expired $(( -days_left )) day(s) ago ($enddate)"
        (( ALERT_COUNT++ ))
    elif (( days_left <= CRIT_DAYS )); then
        echo "CRITICAL: $target — expires in ${days_left} day(s) ($enddate)"
        (( ALERT_COUNT++ ))
    elif (( days_left <= WARN_DAYS )); then
        echo "WARNING:  $target — expires in ${days_left} day(s) ($enddate)"
        (( ALERT_COUNT++ ))
    else
        echo "OK:       $target — expires in ${days_left} day(s) ($enddate)"
    fi
}

echo "Certificate renewal check — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Warning:  < ${WARN_DAYS} days"
echo "  Critical: < ${CRIT_DAYS} days"
echo "-----------------------------------------------------------"

for target in "${TARGETS[@]}"; do
    check_cert "$target"
done

echo "-----------------------------------------------------------"
if [[ "$ALERT_COUNT" -gt 0 ]]; then
    echo "Result: $ALERT_COUNT certificate(s) require attention"
    exit 1
fi
echo "Result: all certificates are within acceptable validity"
exit 0
