#!/bin/bash

set -euo pipefail

DAYS="${1:-90}"
SHOW_MERGED="${2:-true}"

show_usage() {
    cat << EOF
Usage: $0 [days] [show_merged]

Report local git branches not updated recently.

Arguments:
  days         Branch inactivity threshold in days (default: 90)
  show_merged  true/false, include merged branches section (default: true)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo "Error: days must be a non-negative integer"
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: run inside a git repository"
    exit 1
fi

default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
default_branch=${default_branch:-main}
cutoff_epoch=$(date -d "-${DAYS} days" +%s 2>/dev/null || date -v-"${DAYS}"d +%s)

print_branches() {
    local merged_flag="$1"
    local title="$2"

    echo "$title"
    git for-each-ref --format='%(refname:short)|%(committerdate:unix)|%(committerdate:short)' refs/heads | while IFS='|' read -r branch epoch date_str; do
        [[ "$branch" == "$default_branch" ]] && continue

        if [[ "$merged_flag" == "merged" ]] && ! git branch --merged "$default_branch" | grep -q "^[* ] ${branch}$"; then
            continue
        fi

        if [[ "$merged_flag" == "unmerged" ]] && git branch --merged "$default_branch" | grep -q "^[* ] ${branch}$"; then
            continue
        fi

        if (( epoch <= cutoff_epoch )); then
            echo "  $branch (last commit: $date_str)"
        fi
    done
}

if [[ "$SHOW_MERGED" == "true" ]]; then
    print_branches "merged" "Merged stale branches:"
fi

print_branches "unmerged" "Unmerged stale branches:"
