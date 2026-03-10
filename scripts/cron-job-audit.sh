#!/bin/bash

set -euo pipefail

show_usage() {
    cat << EOF
Usage: $0 [--path <cron_root>]

Audit cron jobs for risky patterns and missing executable targets.

Options:
  --path <cron_root>   Cron root path for scanning (default: /etc)
  -h, --help           Show help
EOF
}

CRON_ROOT="/etc"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)
            CRON_ROOT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

if [[ ! -d "$CRON_ROOT" ]]; then
    echo "Error: path does not exist: $CRON_ROOT"
    exit 1
fi

risky_regex='(curl|wget).*(sh|bash)|nc[[:space:]]+-e|bash[[:space:]]+-c'
issues=0

scan_file() {
    local file="$1"
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        if [[ "$line" =~ $risky_regex ]]; then
            echo "RISKY_PATTERN: $file :: $line"
            issues=1
        fi
    done < "$file"
}

for cron_file in "$CRON_ROOT"/crontab "$CRON_ROOT"/cron.d/*; do
    [[ -f "$cron_file" ]] || continue
    scan_file "$cron_file"
done

for cron_dir in "$CRON_ROOT"/cron.daily "$CRON_ROOT"/cron.hourly "$CRON_ROOT"/cron.weekly "$CRON_ROOT"/cron.monthly; do
    [[ -d "$cron_dir" ]] || continue
    while IFS= read -r -d '' script; do
        if [[ ! -x "$script" ]]; then
            echo "NOT_EXECUTABLE: $script"
            issues=1
        fi
        perms=$(stat -c '%a' "$script" 2>/dev/null || stat -f '%Lp' "$script")
        if [[ "$perms" =~ [2367]$ ]]; then
            echo "WORLD_WRITABLE_OR_GROUP_WRITABLE: $script ($perms)"
            issues=1
        fi
    done < <(find "$cron_dir" -maxdepth 1 -type f -print0)
done

if (( issues == 1 )); then
    echo "Cron audit completed with findings."
    exit 1
fi

echo "Cron audit passed with no findings."
