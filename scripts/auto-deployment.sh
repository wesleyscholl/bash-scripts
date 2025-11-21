#!/bin/bash

# Variables
REPO_DIR="/path/to/repo"  # Local repository directory
SERVICE="myapp"           # Application service name

# Navigate to the repository directory
cd "$REPO_DIR" || { echo "Repository directory not found."; exit 1; }

# Pull the latest code
echo "Pulling latest code from repository."
git pull origin main

# Check if the pull was successful
if [ $? -eq 0 ]; then
    echo "Code updated successfully."
    # Restart the application service
    echo "Restarting $SERVICE service."
    systemctl restart "$SERVICE"
    # Verify if the service restarted successfully
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE restarted successfully."
    else
        echo "Failed to restart $SERVICE."
    fi
else
    echo "Failed to update code. Deployment aborted."
fi
