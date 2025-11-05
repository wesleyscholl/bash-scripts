#!/bin/bash

# Variables
CONTAINER_NAME="my-container"
ERROR_PATTERN="ERROR"
OPSGENIE_API_KEY="your-opsgenie-api-key"
ALERT_MESSAGE="Error detected in container logs for $CONTAINER_NAME"

# Monitor logs
docker logs -f "$CONTAINER_NAME" | while read -r line; do
    if [[ "$line" =~ $ERROR_PATTERN ]]; then
        curl -X POST "https://api.opsgenie.com/v2/alerts" \
             -H "Authorization: GenieKey $OPSGENIE_API_KEY" \
             -H "Content-Type: application/json" \
             -d "{
                \"message\": \"$ALERT_MESSAGE\",
                \"description\": \"$line\"
             }"
        echo "Alert sent for error: $line"
    fi
done
