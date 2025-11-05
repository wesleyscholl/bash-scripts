#!/bin/bash
# Script to check SSL certificate expiration date for a website

# Default values
DOMAIN="${1:-example.com}"
PORT="${2:-443}"
WARNING_DAYS=30

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    echo "Error: openssl is not installed"
    exit 1
fi

echo "Checking SSL certificate for $DOMAIN:$PORT..."
echo ""

# Get certificate information
CERT_INFO=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)

if [ -z "$CERT_INFO" ]; then
    echo "Error: Unable to retrieve certificate information"
    echo "Please check if the domain is correct and accessible"
    exit 1
fi

# Extract expiration date
EXPIRY_DATE=$(echo "$CERT_INFO" | grep "notAfter" | cut -d= -f2)

# Convert dates to epoch for comparison
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$EXPIRY_DATE" +%s 2>/dev/null)
CURRENT_EPOCH=$(date +%s)

# Calculate days until expiration
DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))

# Display results
echo "Certificate expiration date: $EXPIRY_DATE"
echo "Days until expiration: $DAYS_UNTIL_EXPIRY"
echo ""

# Warning if expiring soon
if [ "$DAYS_UNTIL_EXPIRY" -lt 0 ]; then
    echo "⚠️  WARNING: Certificate has EXPIRED!"
    exit 2
elif [ "$DAYS_UNTIL_EXPIRY" -lt "$WARNING_DAYS" ]; then
    echo "⚠️  WARNING: Certificate expires in less than $WARNING_DAYS days!"
    exit 1
else
    echo "✓ Certificate is valid"
fi

# Additional certificate information
echo ""
echo "Additional information:"
echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null | openssl x509 -noout -subject -issuer 2>/dev/null
