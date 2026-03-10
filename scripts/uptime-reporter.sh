#!/bin/bash
# uptime-reporter.sh — Report system uptime, boot time, and recent reboots
# Usage: ./scripts/uptime-reporter.sh [OPTIONS]

set -euo pipefail

REBOOT_HISTORY=5

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Reports system uptime, last boot time, and recent reboot history.

Options:
  -r, --reboots <n>   Number of recent reboots to show (default: $REBOOT_HISTORY)
  -h, --help          Show this help message

Examples:
  $(basename "$0")
  $(basename "$0") --reboots 10
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -r|--reboots)
            REBOOT_HISTORY="$2"
            if ! [[ "$REBOOT_HISTORY" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: reboots must be a positive integer"
                exit 1
            fi
            shift 2 ;;
        *) echo "Error: unknown option '$1'"; show_usage ;;
    esac
done

echo "Uptime report — $(date '+%Y-%m-%d %H:%M:%S')"
echo "-------------------------------------------"

# Human-readable uptime
echo "Uptime:     $(uptime -p 2>/dev/null || uptime | awk -F'up |,' '{print $2}' | sed 's/^[ \t]*//')"

# Last boot time
if command -v who >/dev/null 2>&1; then
    last_boot=$(who -b 2>/dev/null | awk '{print $3, $4}')
    [[ -n "$last_boot" ]] && echo "Last boot:  $last_boot"
fi

# Load averages
load=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')
echo "Load avg:   $load"

# Reboot history
echo ""
echo "Recent reboots (last $REBOOT_HISTORY):"
if command -v last >/dev/null 2>&1; then
    last reboot 2>/dev/null | head -n "$REBOOT_HISTORY" | grep -v "^$" || echo "  (no history available)"
else
    echo "  (last command not available)"
fi

echo "-------------------------------------------"
exit 0
