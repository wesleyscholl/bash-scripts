#!/bin/bash
# Log Monitor Script
# Monitors log files for specific keywords and sends notifications
# Usage: ./log-monitor.sh <log-file> <keyword1> [keyword2 ...] [options]

# Default configuration
EMAIL_ENABLED=false
EMAIL_RECIPIENT=""
NOTIFICATION_METHOD="console"
FOLLOW_MODE=true

# Color codes for better output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to display usage information
show_usage() {
    cat << EOF
Usage: $0 <log-file> <keyword1> [keyword2 ...] [options]

Monitor a log file for specific keywords and send notifications when found.

Arguments:
    log-file        Path to the log file to monitor
    keywords        One or more keywords to search for (e.g., ERROR, WARNING)

Options:
    -e, --email <address>    Enable email notifications to specified address
    -s, --static            Monitor existing log content only (no real-time tail)
    -h, --help              Display this help message

Examples:
    # Monitor for ERROR and WARNING in real-time
    $0 /var/log/application.log ERROR WARNING

    # Monitor with email notifications
    $0 /var/log/syslog ERROR CRITICAL --email admin@example.com

    # Check existing log content only (no real-time monitoring)
    $0 /var/log/app.log ERROR --static

Requirements:
    - Read access to the log file
    - 'mail' command for email notifications (optional)
    - 'tail' command for real-time monitoring

EOF
    exit 0
}

# Function to send email notification
send_email() {
    local subject="$1"
    local message="$2"
    
    if [ "$EMAIL_ENABLED" = true ]; then
        if command -v mail &> /dev/null; then
            echo "$message" | mail -s "$subject" "$EMAIL_RECIPIENT"
            echo -e "${GREEN}✓ Email notification sent to $EMAIL_RECIPIENT${NC}"
        else
            echo -e "${YELLOW}⚠ Warning: 'mail' command not found. Cannot send email.${NC}"
        fi
    fi
}

# Function to process log line
process_log_line() {
    local line="$1"
    local matched=false
    
    # Check if line matches any keyword
    for keyword in "${KEYWORDS[@]}"; do
        if echo "$line" | grep -q "$keyword"; then
            matched=true
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            
            # Display alert to console
            echo -e "${RED}[ALERT]${NC} [$timestamp] Keyword '${YELLOW}$keyword${NC}' found:"
            echo -e "${RED}→${NC} $line"
            echo ""
            
            # Send email notification if enabled
            if [ "$EMAIL_ENABLED" = true ]; then
                local subject="Log Alert: $keyword detected in $LOG_FILE"
                local message="Time: $timestamp
Keyword: $keyword
Log File: $LOG_FILE
Log Line: $line"
                send_email "$subject" "$message"
            fi
            
            break  # Only alert once per line even if multiple keywords match
        fi
    done
}

# Parse command line arguments
# Check for help flag first
for arg in "$@"; do
    if [ "$arg" = "-h" ] || [ "$arg" = "--help" ]; then
        show_usage
    fi
done

if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Insufficient arguments${NC}"
    echo ""
    show_usage
fi

LOG_FILE="$1"
shift

# Collect keywords and parse options
KEYWORDS=()
while [ $# -gt 0 ]; do
    case "$1" in
        -e|--email)
            EMAIL_ENABLED=true
            EMAIL_RECIPIENT="$2"
            shift 2
            ;;
        -s|--static)
            FOLLOW_MODE=false
            shift
            ;;
        *)
            KEYWORDS+=("$1")
            shift
            ;;
    esac
done

# Validate inputs
if [ ${#KEYWORDS[@]} -eq 0 ]; then
    echo -e "${RED}Error: No keywords specified${NC}"
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}Error: Log file '$LOG_FILE' not found${NC}"
    exit 1
fi

if [ ! -r "$LOG_FILE" ]; then
    echo -e "${RED}Error: Log file '$LOG_FILE' is not readable${NC}"
    exit 1
fi

if [ "$EMAIL_ENABLED" = true ] && [ -z "$EMAIL_RECIPIENT" ]; then
    echo -e "${RED}Error: Email enabled but no recipient specified${NC}"
    exit 1
fi

# Display monitoring configuration
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Log Monitor Started${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo "Log File: $LOG_FILE"
echo "Keywords: ${KEYWORDS[*]}"
echo "Mode: $([ "$FOLLOW_MODE" = true ] && echo "Real-time monitoring" || echo "Static scan")"
if [ "$EMAIL_ENABLED" = true ]; then
    echo "Email Notifications: Enabled ($EMAIL_RECIPIENT)"
else
    echo "Email Notifications: Disabled"
fi
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""

# Monitor the log file
if [ "$FOLLOW_MODE" = true ]; then
    # Real-time monitoring with tail -f
    echo "Monitoring log file in real-time... (Press Ctrl+C to stop)"
    echo ""
    
    # First, scan existing content
    while IFS= read -r line; do
        process_log_line "$line"
    done < "$LOG_FILE"
    
    # Then follow new lines
    tail -f "$LOG_FILE" 2>/dev/null | while IFS= read -r line; do
        process_log_line "$line"
    done
else
    # Static scan of existing content
    echo "Scanning existing log content..."
    echo ""
    
    match_count=0
    while IFS= read -r line; do
        for keyword in "${KEYWORDS[@]}"; do
            if echo "$line" | grep -q "$keyword"; then
                process_log_line "$line"
                ((match_count++))
                break
            fi
        done
    done < "$LOG_FILE"
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo "Scan complete. Found $match_count matching lines."
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
fi
