#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Check for upgradable packages
UPGRADES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)

if [ "$UPGRADES" -gt 0 ]; then
    echo "$UPGRADES package(s) can be upgraded. Installing updates..."
    sudo apt upgrade -y
else
    echo "No packages need to be upgraded."
fi
