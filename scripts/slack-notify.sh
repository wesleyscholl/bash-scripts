#!/bin/bash

# Variables
WEBHOOK_URL="https://hooks.slack.com/services/XXX/XXX/XXX"
MESSAGE="Deployment to production completed successfully!"
CHANNEL="#deployments"

# Send message to Slack
curl -X POST -H 'Content-type: application/json' --data "{
    \"channel\": \"$CHANNEL\",
    \"text\": \"$MESSAGE\"
}" "$WEBHOOK_URL"

echo "Notification sent to Slack channel $CHANNEL."
