#!/bin/bash

# Output file for open ports
OUTPUT_FILE="/tmp/open_ports_$(date +%Y%m%d).log"

# Scan open ports using netstat
netstat -tuln | awk 'NR>2 {print $4, $6}' > "$OUTPUT_FILE"

echo "Open ports logged to $OUTPUT_FILE."
