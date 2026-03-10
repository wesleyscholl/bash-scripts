#!/bin/bash

set -euo pipefail

REPO="${1:-}"

show_usage() {
    cat << EOF
Usage: $0 <owner/repo>

Fetch latest GitHub release metadata for a repository.
EOF
}

if [[ -z "$REPO" || "$REPO" == "-h" || "$REPO" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl command not available"
    exit 1
fi

api_url="https://api.github.com/repos/${REPO}/releases/latest"
response=$(curl -fsSL "$api_url" 2>/dev/null || true)

if [[ -z "$response" ]]; then
    echo "Error: unable to fetch latest release for $REPO"
    exit 1
fi

if command -v jq >/dev/null 2>&1; then
    tag=$(echo "$response" | jq -r '.tag_name // "n/a"')
    name=$(echo "$response" | jq -r '.name // "n/a"')
    published=$(echo "$response" | jq -r '.published_at // "n/a"')
else
    tag=$(echo "$response" | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | cut -d '"' -f4)
    name=$(echo "$response" | grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | cut -d '"' -f4)
    published=$(echo "$response" | grep -oE '"published_at"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | cut -d '"' -f4)
fi

echo "Repository: $REPO"
echo "Latest tag: ${tag:-n/a}"
echo "Release name: ${name:-n/a}"
echo "Published: ${published:-n/a}"
