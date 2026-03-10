#!/bin/bash

set -euo pipefail

DAYS="${1:-30}"

show_usage() {
    cat << EOF
Usage: $0 [older_than_days]

Report Docker images older than a threshold.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
    echo "Error: older_than_days must be a non-negative integer"
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker command not available"
    exit 1
fi

cutoff=$(date -d "-${DAYS} days" +%s 2>/dev/null || date -v-"${DAYS}"d +%s)

docker images --format '{{.Repository}}:{{.Tag}}|{{.CreatedAt}}' | while IFS='|' read -r image created_at; do
    epoch=$(date -d "$created_at" +%s 2>/dev/null || true)
    [[ -z "$epoch" ]] && continue
    if (( epoch <= cutoff )); then
        echo "OLD_IMAGE: $image created_at=$created_at"
    fi
done
