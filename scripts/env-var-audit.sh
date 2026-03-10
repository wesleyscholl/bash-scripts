#!/bin/bash

set -euo pipefail

VARS=(PATH HOME USER SHELL LANG)

show_usage() {
    cat << EOF
Usage: $0 [VAR1 VAR2 ...]

Audit required environment variables and report missing values.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
fi

if [[ $# -gt 0 ]]; then
    VARS=("$@")
fi

missing=0

for var in "${VARS[@]}"; do
    value="${!var:-}"
    if [[ -z "$value" ]]; then
        echo "MISSING: $var"
        missing=1
    else
        echo "OK: $var is set"
    fi
done

if (( missing == 1 )); then
    exit 1
fi

echo "Environment variable audit passed."
