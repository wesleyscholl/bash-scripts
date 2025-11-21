#!/bin/bash

# Service name
SERVICE="nginx"

# Check if the service is running
if systemctl is-active --quiet "$SERVICE"; then
    echo "$SERVICE is running."
else
    echo "$SERVICE is not running. Attempting to start..."
    systemctl start "$SERVICE"
    # Verify if the service started successfully
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE started successfully."
    else
        echo "Failed to start $SERVICE."
    fi
fi
