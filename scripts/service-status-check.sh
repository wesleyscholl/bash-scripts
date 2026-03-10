#!/bin/bash

set -euo pipefail

SERVICE_NAME="${1:-}"

show_usage() {
    cat << EOF
Usage: $0 <service_name>

Check whether a systemd service is active and enabled.
EOF
}

if [[ -z "$SERVICE_NAME" || "$SERVICE_NAME" == "-h" || "$SERVICE_NAME" == "--help" ]]; then
    show_usage
    exit 0
fi

if ! command -v systemctl >/dev/null 2>&1; then
    echo "Error: systemctl command not available"
    exit 1
fi

active_state=$(systemctl is-active "$SERVICE_NAME" 2>/dev/null || true)
enabled_state=$(systemctl is-enabled "$SERVICE_NAME" 2>/dev/null || true)

echo "Service: $SERVICE_NAME"
echo "Active: ${active_state:-unknown}"
echo "Enabled: ${enabled_state:-unknown}"

if [[ "$active_state" != "active" ]]; then
    echo "ALERT: service is not active"
    exit 1
fi

echo "OK: service is active"
