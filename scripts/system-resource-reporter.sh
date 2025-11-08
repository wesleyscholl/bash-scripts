#!/bin/bash
# System Resource Reporter Script
# Generates comprehensive system resource usage reports
# Usage: ./system-resource-reporter.sh [options]

# Default configuration
OUTPUT_FILE=""
SHOW_CPU=true
SHOW_MEMORY=true
SHOW_DISK=true
SHOW_NETWORK=true
OUTPUT_FORMAT="table"

# Color codes for better output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display usage information
show_usage() {
    cat << EOF
Usage: $0 [options]

Generate a comprehensive system resource usage report.

Options:
    -o, --output <file>     Export report to specified file
    -c, --cpu-only          Show only CPU information
    -m, --memory-only       Show only memory information
    -d, --disk-only         Show only disk information
    -n, --network-only      Show only network information
    -f, --format <type>     Output format: table (default), json, csv
    -h, --help              Display this help message

Examples:
    # Generate full system report
    $0

    # Export report to file
    $0 --output /tmp/system-report.txt

    # Show only CPU and memory
    $0 --cpu-only --memory-only

    # Generate JSON output
    $0 --format json --output report.json

    # Export CSV format
    $0 --format csv --output system-stats.csv

Requirements:
    - Standard Unix utilities (top, free, df, ifconfig/ip)
    - Read access to /proc filesystem (Linux)

EOF
    exit 0
}

# Function to get CPU information
get_cpu_info() {
    local cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')
    local cpu_cores=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.2f", 100 - $1}')
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')
    
    if [ -z "$cpu_model" ]; then
        cpu_model="N/A"
    fi
    if [ -z "$cpu_cores" ]; then
        cpu_cores="N/A"
    fi
    
    echo "CPU_MODEL|$cpu_model"
    echo "CPU_CORES|$cpu_cores"
    echo "CPU_USAGE|$cpu_usage%"
    echo "LOAD_AVG|$load_avg"
}

# Function to get memory information
get_memory_info() {
    if command -v free &> /dev/null; then
        local mem_total=$(free -h | awk 'NR==2{print $2}')
        local mem_used=$(free -h | awk 'NR==2{print $3}')
        local mem_free=$(free -h | awk 'NR==2{print $4}')
        local mem_usage=$(free | awk 'NR==2{printf "%.2f", $3*100/$2}')
        local swap_total=$(free -h | awk 'NR==3{print $2}')
        local swap_used=$(free -h | awk 'NR==3{print $3}')
        
        echo "MEM_TOTAL|$mem_total"
        echo "MEM_USED|$mem_used"
        echo "MEM_FREE|$mem_free"
        echo "MEM_USAGE|$mem_usage%"
        echo "SWAP_TOTAL|$swap_total"
        echo "SWAP_USED|$swap_used"
    else
        echo "MEM_TOTAL|N/A"
        echo "MEM_USED|N/A"
        echo "MEM_FREE|N/A"
        echo "MEM_USAGE|N/A"
        echo "SWAP_TOTAL|N/A"
        echo "SWAP_USED|N/A"
    fi
}

# Function to get disk information
get_disk_info() {
    if command -v df &> /dev/null; then
        # Get disk usage for all mounted filesystems
        df -h | awk 'NR>1 && $1 ~ /^\/dev\// {print "DISK|" $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6}'
    else
        echo "DISK|N/A|N/A|N/A|N/A|N/A|N/A"
    fi
}

# Function to get network information
get_network_info() {
    # Try different commands for network statistics
    if [ -f /proc/net/dev ]; then
        awk 'NR>2 {
            if ($1 != "lo:") {
                iface = $1
                gsub(/:/, "", iface)
                rx_bytes = $2
                tx_bytes = $10
                # Convert to human readable
                if (rx_bytes >= 1073741824) rx_human = sprintf("%.2f GB", rx_bytes/1073741824)
                else if (rx_bytes >= 1048576) rx_human = sprintf("%.2f MB", rx_bytes/1048576)
                else if (rx_bytes >= 1024) rx_human = sprintf("%.2f KB", rx_bytes/1024)
                else rx_human = sprintf("%d B", rx_bytes)
                
                if (tx_bytes >= 1073741824) tx_human = sprintf("%.2f GB", tx_bytes/1073741824)
                else if (tx_bytes >= 1048576) tx_human = sprintf("%.2f MB", tx_bytes/1048576)
                else if (tx_bytes >= 1024) tx_human = sprintf("%.2f KB", tx_bytes/1024)
                else tx_human = sprintf("%d B", tx_bytes)
                
                print "NETWORK|" iface "|" rx_human "|" tx_human
            }
        }' /proc/net/dev
    else
        echo "NETWORK|N/A|N/A|N/A"
    fi
}

# Function to format output as table
format_table() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local hostname=$(hostname)
    local uptime_str=$(uptime -p 2>/dev/null || uptime | awk '{print $3, $4}')
    
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║          SYSTEM RESOURCE REPORT                                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  Report Time: $timestamp"
    echo "  Hostname:    $hostname"
    echo "  Uptime:      $uptime_str"
    echo ""
    
    # CPU Section
    if [ "$SHOW_CPU" = true ]; then
        echo -e "${GREEN}┌─ CPU Information ────────────────────────────────────────────┐${NC}"
        get_cpu_info | while IFS='|' read -r key value; do
            printf "  %-20s %s\n" "$key:" "$value"
        done
        echo -e "${GREEN}└──────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi
    
    # Memory Section
    if [ "$SHOW_MEMORY" = true ]; then
        echo -e "${GREEN}┌─ Memory Information ─────────────────────────────────────────┐${NC}"
        get_memory_info | while IFS='|' read -r key value; do
            printf "  %-20s %s\n" "$key:" "$value"
        done
        echo -e "${GREEN}└──────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi
    
    # Disk Section
    if [ "$SHOW_DISK" = true ]; then
        echo -e "${GREEN}┌─ Disk Usage ─────────────────────────────────────────────────┐${NC}"
        printf "  %-20s %-10s %-10s %-10s %-10s %-15s\n" "Filesystem" "Size" "Used" "Avail" "Use%" "Mounted"
        echo "  ────────────────────────────────────────────────────────────────"
        get_disk_info | while IFS='|' read -r label fs size used avail usage mount; do
            printf "  %-20s %-10s %-10s %-10s %-10s %-15s\n" "$fs" "$size" "$used" "$avail" "$usage" "$mount"
        done
        echo -e "${GREEN}└──────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi
    
    # Network Section
    if [ "$SHOW_NETWORK" = true ]; then
        echo -e "${GREEN}┌─ Network Statistics ─────────────────────────────────────────┐${NC}"
        printf "  %-20s %-15s %-15s\n" "Interface" "RX Bytes" "TX Bytes"
        echo "  ────────────────────────────────────────────────────────────────"
        get_network_info | while IFS='|' read -r label iface rx tx; do
            printf "  %-20s %-15s %-15s\n" "$iface" "$rx" "$tx"
        done
        echo -e "${GREEN}└──────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    fi
}

# Function to format output as JSON
format_json() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local hostname=$(hostname)
    local sections=()
    
    echo "{"
    echo "  \"timestamp\": \"$timestamp\","
    echo -n "  \"hostname\": \"$hostname\""
    
    if [ "$SHOW_CPU" = true ]; then
        sections+=("cpu")
    fi
    if [ "$SHOW_MEMORY" = true ]; then
        sections+=("memory")
    fi
    if [ "$SHOW_DISK" = true ]; then
        sections+=("disk")
    fi
    if [ "$SHOW_NETWORK" = true ]; then
        sections+=("network")
    fi
    
    local section_index=0
    
    if [ "$SHOW_CPU" = true ]; then
        echo ","
        echo "  \"cpu\": {"
        local first=true
        get_cpu_info | while IFS='|' read -r key value; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"$key\": \"$value\""
        done
        echo ""
        echo -n "  }"
        ((section_index++))
    fi
    
    if [ "$SHOW_MEMORY" = true ]; then
        if [ $section_index -eq 0 ]; then
            echo ","
        else
            echo ","
        fi
        echo "  \"memory\": {"
        local first=true
        get_memory_info | while IFS='|' read -r key value; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"$key\": \"$value\""
        done
        echo ""
        echo -n "  }"
        ((section_index++))
    fi
    
    if [ "$SHOW_DISK" = true ]; then
        if [ $section_index -eq 0 ]; then
            echo ","
        else
            echo ","
        fi
        echo "  \"disk\": ["
        local first=true
        get_disk_info | while IFS='|' read -r label fs size used avail usage mount; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo "    {"
            echo "      \"filesystem\": \"$fs\","
            echo "      \"size\": \"$size\","
            echo "      \"used\": \"$used\","
            echo "      \"available\": \"$avail\","
            echo "      \"usage\": \"$usage\","
            echo "      \"mounted\": \"$mount\""
            echo -n "    }"
        done
        echo ""
        echo -n "  ]"
        ((section_index++))
    fi
    
    if [ "$SHOW_NETWORK" = true ]; then
        if [ $section_index -eq 0 ]; then
            echo ","
        else
            echo ","
        fi
        echo "  \"network\": ["
        local first=true
        get_network_info | while IFS='|' read -r label iface rx tx; do
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo "    {"
            echo "      \"interface\": \"$iface\","
            echo "      \"rx_bytes\": \"$rx\","
            echo "      \"tx_bytes\": \"$tx\""
            echo -n "    }"
        done
        echo ""
        echo -n "  ]"
    fi
    
    echo ""
    echo "}"
}

# Function to format output as CSV
format_csv() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local hostname=$(hostname)
    
    if [ "$SHOW_CPU" = true ]; then
        echo "Section,Metric,Value"
        get_cpu_info | while IFS='|' read -r key value; do
            echo "CPU,$key,$value"
        done
    fi
    
    if [ "$SHOW_MEMORY" = true ]; then
        if [ "$SHOW_CPU" = false ]; then
            echo "Section,Metric,Value"
        fi
        get_memory_info | while IFS='|' read -r key value; do
            echo "Memory,$key,$value"
        done
    fi
    
    if [ "$SHOW_DISK" = true ]; then
        if [ "$SHOW_CPU" = false ] && [ "$SHOW_MEMORY" = false ]; then
            echo "Filesystem,Size,Used,Available,Usage,Mounted"
        fi
        get_disk_info | while IFS='|' read -r label fs size used avail usage mount; do
            echo "$fs,$size,$used,$avail,$usage,$mount"
        done
    fi
    
    if [ "$SHOW_NETWORK" = true ]; then
        if [ "$SHOW_CPU" = false ] && [ "$SHOW_MEMORY" = false ] && [ "$SHOW_DISK" = false ]; then
            echo "Interface,RX_Bytes,TX_Bytes"
        fi
        get_network_info | while IFS='|' read -r label iface rx tx; do
            echo "$iface,$rx,$tx"
        done
    fi
}

# Parse command line arguments
ONLY_FLAGS_USED=false

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_usage
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -c|--cpu-only)
            if [ "$ONLY_FLAGS_USED" = false ]; then
                SHOW_CPU=false
                SHOW_MEMORY=false
                SHOW_DISK=false
                SHOW_NETWORK=false
                ONLY_FLAGS_USED=true
            fi
            SHOW_CPU=true
            shift
            ;;
        -m|--memory-only)
            if [ "$ONLY_FLAGS_USED" = false ]; then
                SHOW_CPU=false
                SHOW_MEMORY=false
                SHOW_DISK=false
                SHOW_NETWORK=false
                ONLY_FLAGS_USED=true
            fi
            SHOW_MEMORY=true
            shift
            ;;
        -d|--disk-only)
            if [ "$ONLY_FLAGS_USED" = false ]; then
                SHOW_CPU=false
                SHOW_MEMORY=false
                SHOW_DISK=false
                SHOW_NETWORK=false
                ONLY_FLAGS_USED=true
            fi
            SHOW_DISK=true
            shift
            ;;
        -n|--network-only)
            if [ "$ONLY_FLAGS_USED" = false ]; then
                SHOW_CPU=false
                SHOW_MEMORY=false
                SHOW_DISK=false
                SHOW_NETWORK=false
                ONLY_FLAGS_USED=true
            fi
            SHOW_NETWORK=true
            shift
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            if [ "$OUTPUT_FORMAT" != "table" ] && [ "$OUTPUT_FORMAT" != "json" ] && [ "$OUTPUT_FORMAT" != "csv" ]; then
                echo -e "${RED}Error: Invalid format '$OUTPUT_FORMAT'. Must be 'table', 'json', or 'csv'${NC}"
                exit 1
            fi
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo ""
            show_usage
            ;;
    esac
done

# Generate report based on format
if [ -n "$OUTPUT_FILE" ]; then
    # Output to file
    case "$OUTPUT_FORMAT" in
        table)
            format_table > "$OUTPUT_FILE"
            ;;
        json)
            format_json > "$OUTPUT_FILE"
            ;;
        csv)
            format_csv > "$OUTPUT_FILE"
            ;;
    esac
    echo -e "${GREEN}✓ Report exported to: $OUTPUT_FILE${NC}"
else
    # Output to console
    case "$OUTPUT_FORMAT" in
        table)
            format_table
            ;;
        json)
            format_json
            ;;
        csv)
            format_csv
            ;;
    esac
fi
