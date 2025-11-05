#!/bin/bash

# Variables
SOURCE_DIR="/path/to/source/"
DEST_USER="remote_user"
DEST_HOST="remote_host"
DEST_DIR="/path/to/destination/"
LOG_FILE="/var/log/backup.log"

# Perform backup using rsync
rsync -avz --delete "$SOURCE_DIR" "${DEST_USER}@${DEST_HOST}:${DEST_DIR}" >> "$LOG_FILE" 2>&1

# Check if rsync was successful
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup successful" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup failed" >> "$LOG_FILE"
fi
