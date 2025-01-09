#!/bin/bash

# Variables
THRESHOLD=80
ALERT_EMAIL="admin@example.com"

# Check disk usage for each mounted file system
df -h | awk '{if(NR>1) print $5 " " $6}' | while read output; do
    usage=$(echo $output | awk '{print $1}' | sed 's/%//')
    mount_point=$(echo $output | awk '{print $2}')
    if [ "$usage" -ge "$THRESHOLD" ]; then
        echo "Disk usage on $mount_point has reached $usage%." | mail -s "Disk Usage Alert" "$ALERT_EMAIL"
    fi
done
