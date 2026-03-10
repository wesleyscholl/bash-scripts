#!/bin/bash

set -euo pipefail

SSH_CONFIG="${1:-/etc/ssh/sshd_config}"

show_usage() {
    cat << EOF
Usage: $0 [sshd_config_path]

Audit SSH daemon configuration for baseline hardening settings.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ ! -f "$SSH_CONFIG" ]]; then
    echo "Error: SSH config not found: $SSH_CONFIG"
    exit 1
fi

issues=0

check_setting() {
    local key="$1"
    local expected="$2"
    if grep -Ei "^[[:space:]]*${key}[[:space:]]+${expected}[[:space:]]*$" "$SSH_CONFIG" >/dev/null; then
        echo "OK: $key $expected"
    else
        echo "MISSING_OR_WEAK: expected '$key $expected'"
        issues=1
    fi
}

check_setting "PermitRootLogin" "no"
check_setting "PasswordAuthentication" "no"
check_setting "PubkeyAuthentication" "yes"
check_setting "Protocol" "2"

if (( issues == 1 )); then
    exit 1
fi

echo "SSH config audit passed."
