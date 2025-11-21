#!/bin/bash

# Variables
URL="https://example.com"
EXPECTED_CODE=200

# Check HTTP response code
STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" "$URL")

# Compare the status code with the expected value
if [ "$STATUS_CODE" -eq "$EXPECTED_CODE" ]; then
    echo "Website is up. Status code: $STATUS_CODE"
else
    echo "Website is down or returned an unexpected status code: $STATUS_CODE"
fi
