#!/bin/bash

# Variables
LOG_FILE="/var/log/resource_monitor.log"
INTERVAL=60  # Time in seconds between checks

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | \
    sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
    awk '{print 100 - $1"%"}'
}

# Function to get memory usage
get_memory_usage() {
    free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }'
}

# Infinite loop to monitor resources
while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    CPU_USAGE=$(get_cpu_usage)
    MEM_USAGE=$(get_memory_usage)
    echo "$TIMESTAMP - CPU Usage: $CPU_USAGE, Memory Usage: $MEM_USAGE" >> "$LOG_FILE"
    sleep "$INTERVAL"
done
