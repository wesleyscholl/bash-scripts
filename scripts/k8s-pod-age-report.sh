#!/bin/bash

set -euo pipefail

HOURS="${1:-24}"

show_usage() {
    cat << EOF
Usage: $0 [older_than_hours]

Report Kubernetes pods older than a threshold.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! [[ "$HOURS" =~ ^[0-9]+$ ]]; then
    echo "Error: older_than_hours must be a non-negative integer"
    exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Error: kubectl command not available"
    exit 1
fi

cutoff=$((HOURS * 3600))
now=$(date +%s)

kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,CREATED:.metadata.creationTimestamp --no-headers | while read -r ns name created; do
    created_epoch=$(date -d "$created" +%s 2>/dev/null || true)
    [[ -z "$created_epoch" ]] && continue
    age_seconds=$((now - created_epoch))
    if (( age_seconds >= cutoff )); then
        echo "OLD_POD: namespace=$ns pod=$name age_hours=$((age_seconds/3600))"
    fi
done
