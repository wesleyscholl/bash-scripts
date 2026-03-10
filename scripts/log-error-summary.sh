#!/bin/bash
# log-error-summary.sh — Count and rank error patterns in a log file for rapid triage
# Usage: ./scripts/log-error-summary.sh [OPTIONS] <logfile>

set -euo pipefail

TOP_N=10
PATTERNS=("ERROR" "CRITICAL" "FATAL" "Exception" "WARN" "WARNING" "failed" "timeout")

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <logfile>

Counts occurrences of common error patterns in a log file and displays a ranked summary.

Options:
  -n, --top <n>       Number of top patterns to show (default: $TOP_N)
  -p, --pattern <re>  Add a custom grep pattern (may be specified multiple times)
  -h, --help          Show this help message

Arguments:
  logfile   Path to the log file to analyse

Examples:
  $(basename "$0") /var/log/syslog
  $(basename "$0") --top 5 --pattern "OOM" /var/log/kern.log
  $(basename "$0") /var/log/app/app.log
EOF
    exit 0
}

if [[ $# -eq 0 ]]; then
    echo "Error: log file is required."
    show_usage
fi

EXTRA_PATTERNS=()
LOG_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_usage ;;
        -n|--top)
            TOP_N="$2"
            if ! [[ "$TOP_N" =~ ^[1-9][0-9]*$ ]]; then
                echo "Error: top must be a positive integer"
                exit 1
            fi
            shift 2 ;;
        -p|--pattern)
            EXTRA_PATTERNS+=("$2")
            shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage ;;
        *) LOG_FILE="$1"; shift ;;
    esac
done

if [[ -z "$LOG_FILE" ]]; then
    echo "Error: log file is required."
    show_usage
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: log file not found: $LOG_FILE"
    exit 1
fi

if [[ ! -r "$LOG_FILE" ]]; then
    echo "Error: log file is not readable: $LOG_FILE"
    exit 1
fi

# Merge default + custom patterns
ALL_PATTERNS=("${PATTERNS[@]}" "${EXTRA_PATTERNS[@]}")

echo "Log error summary — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Log file: $LOG_FILE"
echo "  Lines:    $(wc -l < "$LOG_FILE")"
echo "---------------------------------------------------"
printf "  %-10s  %s\n" "COUNT" "PATTERN"
echo "  ----------  ----------"

declare -A counts
for pattern in "${ALL_PATTERNS[@]}"; do
    cnt=$(grep -cEi "$pattern" "$LOG_FILE" 2>/dev/null || echo 0)
    counts["$pattern"]=$cnt
done

# Sort by count descending, print top N
for pattern in "${!counts[@]}"; do
    echo "${counts[$pattern]} $pattern"
done | sort -rn | head -n "$TOP_N" | while read -r cnt pat; do
    printf "  %-10s  %s\n" "$cnt" "$pat"
done

echo "---------------------------------------------------"

# Show sample lines for the highest-count pattern
top_pattern=$(for p in "${!counts[@]}"; do echo "${counts[$p]} $p"; done | sort -rn | head -1 | awk '{print $2}')
if [[ -n "$top_pattern" && "${counts[$top_pattern]:-0}" -gt 0 ]]; then
    echo ""
    echo "Sample lines matching '$top_pattern':"
    grep -Ei "$top_pattern" "$LOG_FILE" | tail -5 | sed 's/^/  /'
fi

exit 0
