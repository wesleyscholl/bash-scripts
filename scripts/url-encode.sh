#!/bin/bash

set -euo pipefail

INPUT="${1:-}"

show_usage() {
    cat << EOF
Usage: $0 <string>

URL-encode a string for safe query usage.
EOF
}

if [[ -z "$INPUT" || "$INPUT" == "-h" || "$INPUT" == "--help" ]]; then
    show_usage
    exit 0
fi

encoded=""
for (( i=0; i<${#INPUT}; i++ )); do
    c="${INPUT:$i:1}"
    case "$c" in
        [a-zA-Z0-9.~_-])
            encoded+="$c"
            ;;
        ' ')
            encoded+="%20"
            ;;
        *)
            hex=$(printf '%02X' "'${c}")
            encoded+="%${hex}"
            ;;
    esac
done

echo "$encoded"
