#!/bin/bash

# Usage: ./query_splunk.sh <splunk_url> <username> <password> <query> <output_file>
SPLUNK_URL=$1
USERNAME=$2
PASSWORD=$3
QUERY=$4
OUTPUT_FILE=$5

if [[ -z "$SPLUNK_URL" || -z "$USERNAME" || -z "$PASSWORD" || -z "$QUERY" || -z "$OUTPUT_FILE" ]]; then
    echo "Usage: $0 <splunk_url> <username> <password> <query> <output_file>"
    exit 1
fi

# Query Splunk
curl -X POST "$SPLUNK_URL/services/search/jobs" \
     -u "$USERNAME:$PASSWORD" \
     -d "search=$QUERY" \
     -d "output_mode=json" \
     -o "$OUTPUT_FILE"

echo "Saved Splunk query results to $OUTPUT_FILE."
