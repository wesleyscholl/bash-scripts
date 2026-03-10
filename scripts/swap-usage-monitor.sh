#!/bin/bash
# swap-usage-monitor.sh — Monitor swap usage and alert when it exceeds a threshold
# Usage: ./scripts/swap-usage-monitor.sh [OPTIONS]

set -euo pipefail

THRESHOLD=50  # percent

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Reports current swap usage and exits non-zero when usage exceeds the threshold.

Options:
  -t, --threshold <pct>   Alert threshold as a percentage (default: $THRESHOLD)
  -h, --help              Show this help message

Examples:
  $(basename "$0")
  $(basename "$0") --threshold 80
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -t|--threshold)
            THRESHOLD="$2"
            if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 1 || THRESHOLD > 100 )); then
                echo "Error: threshold must be an integer between 1 and 100"
                exit 1
            fi
            shift 2 ;;
        *) echo "Error: unknown option '$1'"; show_usage ;;
    esac
done

get_swap_info() {
    if command -v free >/dev/null 2>&1; then
        local total used
        total=$(free | awk 'NR==3{print $2}')
        used=$(free  | awk 'NR==3{print $3}')
        if [[ "$total" -eq 0 ]]; then
            echo "0 0 0"
        else
            local pct
            pct=$(awk "BEGIN{printf \"%d\", ($used/$total)*100}")
            echo "$total $used $pct"
        fi
    else
        # macOS fallback via vm_stat
        local total_pages free_pages
        total_pages=$(sysctl -n vm.swapusage 2>/dev/null | awk '{print $3}' | tr -d 'M' || echo 0)
        free_pages=$(sysctl -n vm.swapusage  2>/dev/null | awk '{print $7}' | tr -d 'M' || echo 0)
        echo "$total_pages $free_pages 0"
    fi
}

echo "Swap usage monitor — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Alert threshold: ${THRESHOLD}%"
echo "------------------------------------"

read -r swap_total swap_used swap_pct <<< "$(get_swap_info)"

if [[ "$swap_total" -eq 0 ]]; then
    echo "OK: no swap configured on this system"
    exit 0
fi

echo "Swap total:  ${swap_total} kB"
echo "Swap used:   ${swap_used} kB"
echo "Swap usage:  ${swap_pct}%"

if (( swap_pct >= THRESHOLD )); then
    echo "ALERT: swap usage ${swap_pct}% exceeds threshold ${THRESHOLD}%"
    exit 1
fi
echo "OK: swap usage ${swap_pct}% is within threshold"
exit 0
