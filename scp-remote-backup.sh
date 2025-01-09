#!/bin/bash

# Variables
LOG_DIR="/var/logs/myapp"
BACKUP_DIR="/tmp"
ARCHIVE_NAME="logs_backup_$(date +%Y%m%d).tar.gz"
REMOTE_USER="user"
REMOTE_HOST="192.168.1.100"
REMOTE_DIR="/backups"

# Create a tar archive of the logs
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$LOG_DIR" .

# Transfer the archive to the remote server
scp "$BACKUP_DIR/$ARCHIVE_NAME" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

# Cleanup local backup
rm "$BACKUP_DIR/$ARCHIVE_NAME"

echo "Logs backed up to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
