#!/bin/bash

# Directory to clean up
TARGET_DIR="/var/tmp/myapp"

# Number of days to keep files
DAYS=30

# Find and delete files older than the specified number of days
find "$TARGET_DIR" -type f -mtime +$DAYS -exec rm -f {} \;

echo "Files older than $DAYS days have been deleted from $TARGET_DIR."
