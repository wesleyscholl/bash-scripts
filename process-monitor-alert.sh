#!/bin/bash

# Process to monitor
PROCESS_NAME="nginx"

# Check if the process is running
if pgrep "$PROCESS_NAME" > /dev/null; then
    echo "$PROCESS_NAME is running."
else
    echo "$PROCESS_NAME is not running. Sending alert..."
    # Example: send an email alert (replace with actual alert mechanism)
    echo "$PROCESS_NAME is down!" | mail -s "$PROCESS_NAME Alert" admin@example.com
fi
