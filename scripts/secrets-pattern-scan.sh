#!/bin/bash

set -euo pipefail

SCAN_PATH="${1:-.}"

show_usage() {
    cat << EOF
Usage: $0 [path]

Scan files for common hardcoded secret patterns.

Arguments:
  path    Directory or file path to scan (default: current directory)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ ! -e "$SCAN_PATH" ]]; then
    echo "Error: path not found: $SCAN_PATH"
    exit 1
fi

patterns=(
    'AKIA[0-9A-Z]{16}'
    '-----BEGIN (RSA|EC|OPENSSH|DSA)? ?PRIVATE KEY-----'
    'xox[baprs]-[0-9A-Za-z-]{10,}'
    'ghp_[0-9A-Za-z]{36}'
    'AIza[0-9A-Za-z_-]{35}'
    '(?i)(password|passwd|secret|api[_-]?key)["'"'"' ]*[:=]["'"'"' ]*[A-Za-z0-9_!@#$%^&*./+=-]{8,}'
)

if command -v rg >/dev/null 2>&1; then
    scanner="rg"
else
    scanner="grep"
fi

echo "Scanning for secrets in: $SCAN_PATH"
found=0

for pattern in "${patterns[@]}"; do
    if [[ "$scanner" == "rg" ]]; then
        if rg -n --hidden --glob '!.git' -e "$pattern" "$SCAN_PATH" >/tmp/secrets-scan.out 2>/dev/null; then
            found=1
            echo "Pattern matched: $pattern"
            cat /tmp/secrets-scan.out
        fi
    else
        if grep -RInE "$pattern" "$SCAN_PATH" --exclude-dir=.git >/tmp/secrets-scan.out 2>/dev/null; then
            found=1
            echo "Pattern matched: $pattern"
            cat /tmp/secrets-scan.out
        fi
    fi
done

rm -f /tmp/secrets-scan.out

if (( found == 1 )); then
    echo "Secret scan completed with findings."
    exit 1
fi

echo "Secret scan passed with no findings."
