#!/bin/bash

# Variables
LOG_FILE="/var/log/application.log"
MAX_SIZE=10485760  # 10 MB in bytes
BACKUP_DIR="/var/log/backup/"
TIMESTAMP=$(date '+%Y%m%d%H%M%S')

# Check if log file exists
if [ -f "$LOG_FILE" ]; then
    # Get the size of the log file
    FILE_SIZE=$(stat -c%s "$LOG_FILE")

    # Compare file size with the maximum allowed size
    if [ "$FILE_SIZE" -ge "$MAX_SIZE" ]; then
        # Create backup directory if it doesn't exist
        mkdir -p "$BACKUP_DIR"

        # Move the log file to the backup directory with a timestamp
        mv "$LOG_FILE" "${BACKUP_DIR}application.log.$TIMESTAMP"

        # Create a new empty log file
        touch "$LOG_FILE"

        # Set appropriate permissions
        chmod 644 "$LOG_FILE"

        echo "Log file rotated successfully."
    else
        echo "Log file size is under the threshold."
    fi
else
    echo "Log file does not exist."
fi
