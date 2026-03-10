#!/bin/bash

set -euo pipefail

THRESHOLD="${1:-3}"
NAMESPACE="${2:-all}"

show_usage() {
    cat << EOF
Usage: $0 [restart_threshold] [namespace|all]

Report Kubernetes pods with restart counts above threshold.

Arguments:
  restart_threshold   Restart count threshold (default: 3)
  namespace           Namespace to scan or 'all' (default: all)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Error: kubectl command not available"
    exit 1
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: restart_threshold must be a non-negative integer"
    exit 1
fi

if [[ "$NAMESPACE" == "all" ]]; then
    cmd=(kubectl get pods -A -o "custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,RESTARTS:.status.containerStatuses[*].restartCount" --no-headers)
else
    cmd=(kubectl get pods -n "$NAMESPACE" -o "custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,RESTARTS:.status.containerStatuses[*].restartCount" --no-headers)
fi

echo "Pods with restart count >= $THRESHOLD"
findings=0

"${cmd[@]}" | awk -v t="$THRESHOLD" '
{
    restarts = 0
    split($3, values, ",")
    for (i in values) {
        restarts += values[i]
    }
    if (restarts >= t) print $1 "|" $2 "|" restarts
}' | while IFS='|' read -r ns pod restarts; do
    echo "ALERT: namespace=$ns pod=$pod restarts=$restarts"
done

if "${cmd[@]}" | awk -v t="$THRESHOLD" '{
    restarts = 0
    split($3, values, ",")
    for (i in values) {
        restarts += values[i]
    }
    if (restarts >= t) found=1
} END {exit !found}'; then
    exit 1
fi

echo "OK: no pods above restart threshold"
