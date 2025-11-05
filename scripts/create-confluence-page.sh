#!/bin/bash

# Variables
CONFLUENCE_URL="https://confluence.example.com"
CONFLUENCE_USER="user@example.com"
CONFLUENCE_API_TOKEN="your-confluence-api-token"
SPACE_KEY="DEVOPS"
PAGE_TITLE="Deployment Report $(date +%Y-%m-%d)"
PAGE_CONTENT="<h1>Deployment Summary</h1><p>All systems are operational.</p>"

# Create the page
curl -X POST "$CONFLUENCE_URL/rest/api/content" \
     -u "$CONFLUENCE_USER:$CONFLUENCE_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{
        \"type\": \"page\",
        \"title\": \"$PAGE_TITLE\",
        \"space\": { \"key\": \"$SPACE_KEY\" },
        \"body\": {
            \"storage\": {
                \"value\": \"$PAGE_CONTENT\",
                \"representation\": \"storage\"
            }
        }
     }"

echo "Page '$PAGE_TITLE' created in Confluence."
