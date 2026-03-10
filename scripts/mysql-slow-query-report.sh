#!/bin/bash
# mysql-slow-query-report.sh — Parse a MySQL slow query log and report the top offenders
# Usage: ./scripts/mysql-slow-query-report.sh [OPTIONS] <slow-query-log>

set -euo pipefail

TOP_N=10
MIN_TIME=1  # seconds

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <slow-query-log>

Parses a MySQL slow query log and summarises the slowest queries.

Options:
  -n, --top <n>           Number of top queries to display (default: $TOP_N)
  -m, --min-time <secs>   Minimum query time to include (default: ${MIN_TIME}s)
  -h, --help              Show this help message

Arguments:
  slow-query-log   Path to the MySQL slow query log file

Examples:
  $(basename "$0") /var/log/mysql/mysql-slow.log
  $(basename "$0") --top 5 --min-time 2 /var/log/mysql/mysql-slow.log
EOF
    exit "${1:-0}"
}

if [[ $# -eq 0 ]]; then
    echo "Error: slow query log file is required."
    show_usage 2
fi

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
        -m|--min-time)
            MIN_TIME="$2"
            if ! [[ "$MIN_TIME" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                echo "Error: min-time must be a non-negative number"
                exit 1
            fi
            shift 2 ;;
        -*) echo "Error: unknown option '$1'"; show_usage 2 ;;
        *) LOG_FILE="$1"; shift ;;
    esac
done

if [[ -z "${LOG_FILE:-}" ]]; then
    echo "Error: slow query log file is required."
    show_usage 2
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: log file not found: $LOG_FILE"
    exit 1
fi

if [[ ! -r "$LOG_FILE" ]]; then
    echo "Error: log file is not readable: $LOG_FILE"
    exit 1
fi

echo "MySQL slow query report — $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Log file:   $LOG_FILE"
echo "  Min time:   ${MIN_TIME}s"
echo "  Top N:      $TOP_N"
echo "-----------------------------------------------------------"

total=0
total=$(grep -c "^# Query_time:" "$LOG_FILE" 2>/dev/null) || total=0
echo "Total slow queries in log: $total"
echo ""

if [[ "$total" -eq 0 ]]; then
    echo "No slow queries found in log."
    exit 0
fi

echo "Top $TOP_N slowest queries (Query_time >= ${MIN_TIME}s):"
echo ""

# Extract query_time and the following SQL line, sort by time descending
awk -v min="$MIN_TIME" '
/^# Query_time:/ {
    split($3, a, ":")
    qt = a[1]
    if (qt+0 >= min+0) { found=1; qt_val=qt }
    else { found=0 }
    next
}
/^(SELECT|INSERT|UPDATE|DELETE|REPLACE|CREATE|DROP|ALTER|CALL)/ {
    if (found) {
        printf "%.3fs  %s\n", qt_val, substr($0,1,120)
        found=0
    }
}
' "$LOG_FILE" | sort -rn | head -n "$TOP_N"

exit 0
