#!/bin/bash

# Thresholds
CPU_THRESHOLD=90
MEM_THRESHOLD=85
DISK_THRESHOLD=75

# Log file
LOGFILE="/var/log/system_monitor.log"

# Function to send email alerts
send_alert() {
    local subject=$1
    local message=$2
    echo "$message" | mail -s "$subject" admin@example.com
}

# Check CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
if (( ${cpu_usage%.*} > CPU_THRESHOLD )); then
    message="High CPU usage detected: ${cpu_usage}%"
    echo "$(date): $message" >> "$LOGFILE"
    send_alert "CPU Usage Alert" "$message"
fi

# Check Memory usage
mem_usage=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
if (( mem_usage > MEM_THRESHOLD )); then
    message="High Memory usage detected: ${mem_usage}%"
    echo "$(date): $message" >> "$LOGFILE"
    send_alert "Memory Usage Alert" "$message"
fi

# Check Disk usage
disk_usage=$(df / | awk 'END{print $5}' | sed 's/%//')
if (( disk_usage > DISK_THRESHOLD )); then
    message="High Disk usage detected: ${disk_usage}%"
    echo "$(date): $message" >> "$LOGFILE"
    send_alert "Disk Usage Alert" "$message"
fi
