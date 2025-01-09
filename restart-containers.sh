#!/bin/bash

# Usage: ./restart_container.sh <container_name>
CONTAINER_NAME=$1

if [[ -z "$CONTAINER_NAME" ]]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

# Restart the container
docker restart "$CONTAINER_NAME"

echo "Restarted Docker container: $CONTAINER_NAME"
