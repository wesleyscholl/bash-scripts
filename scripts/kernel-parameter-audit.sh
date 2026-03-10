#!/bin/bash
# kernel-parameter-audit.sh — Check critical kernel sysctl parameters against secure baselines
# Usage: ./scripts/kernel-parameter-audit.sh [OPTIONS]

set -euo pipefail

FAIL_COUNT=0

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Audits kernel sysctl parameters against a security and performance baseline.
Exits non-zero if any parameter does not match the expected value.

Options:
  -h, --help   Show this help message

Examples:
  $(basename "$0")
  $(basename "$0") --help
EOF
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && show_usage

if ! command -v sysctl >/dev/null 2>&1; then
    echo "Error: sysctl command is required"
    exit 1
fi

# Format: "parameter expected_value description"
CHECKS=(
    "net.ipv4.ip_forward 0 IP forwarding disabled (non-router hosts)"
    "net.ipv4.conf.all.send_redirects 0 ICMP send_redirects disabled"
    "net.ipv4.conf.all.accept_redirects 0 ICMP accept_redirects disabled"
    "net.ipv4.conf.all.accept_source_route 0 Source routing disabled"
    "net.ipv4.tcp_syncookies 1 SYN flood protection enabled"
    "net.ipv4.conf.all.log_martians 1 Martian packet logging enabled"
    "net.ipv4.icmp_echo_ignore_broadcasts 1 Broadcast ping ignored"
    "kernel.randomize_va_space 2 ASLR fully enabled"
    "fs.suid_dumpable 0 SUID core dumps disabled"
    "net.ipv6.conf.all.accept_redirects 0 IPv6 ICMP redirects disabled"
)

check_param() {
    local param="$1" expected="$2" description="$3"
    local actual
    actual=$(sysctl -n "$param" 2>/dev/null || echo "UNAVAILABLE")
    if [[ "$actual" == "UNAVAILABLE" ]]; then
        echo "SKIP:  $param — not available on this kernel"
    elif [[ "$actual" == "$expected" ]]; then
        echo "OK:    $param = $actual  ($description)"
    else
        echo "FAIL:  $param = $actual (expected $expected)  ($description)"
        (( FAIL_COUNT++ ))
    fi
}

echo "Kernel parameter audit — $(date '+%Y-%m-%d %H:%M:%S')"
echo "-------------------------------------------------------"

for check in "${CHECKS[@]}"; do
    read -r param expected description <<< "$check"
    check_param "$param" "$expected" "$description"
done

echo "-------------------------------------------------------"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo "Result: $FAIL_COUNT parameter(s) do not match the secure baseline"
    exit 1
fi
echo "Result: all checked parameters match the secure baseline"
exit 0
