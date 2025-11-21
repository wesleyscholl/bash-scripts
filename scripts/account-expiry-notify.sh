#!/bin/bash

# Days before expiry to notify
THRESHOLD=7

# Check for accounts expiring within the threshold
echo "Checking user accounts expiring in the next $THRESHOLD days..."
while IFS=: read -r username _ _ _ _ expiry_date _; do
    if [[ "$expiry_date" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        days_left=$(( ( $(date -d "$expiry_date" +%s) - $(date +%s) ) / 86400 ))
        if [ "$days_left" -le "$THRESHOLD" ]; then
            echo "User $username's account will expire in $days_left days."
        fi
    fi
done < <(chage -l "$USER" | grep 'Account expires')
