#!/bin/bash

# Directory to search for log files
LOG_DIR="/var/log"

# Find and compress log files larger than 1MB
find "$LOG_DIR" -name "*.log" -size +1M -exec gzip {} \;

echo "Log file cleanup completed."
