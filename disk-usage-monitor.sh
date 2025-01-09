#!/bin/bash

# Threshold percentage
THRESHOLD=80

# Email for alerts
EMAIL="admin@example.com"

# Check disk usage
CURRENT_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

# Compare current usage with threshold
if [ "$CURRENT_USAGE" -gt "$THRESHOLD" ]; then
    echo "Disk usage is above $THRESHOLD%. Current usage is ${CURRENT_USAGE}%." | mail -s "Disk Usage Alert" "$EMAIL"
fi
