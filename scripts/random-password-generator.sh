#!/bin/bash

# Password length
LENGTH=16

# Generate random password
PASSWORD=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c $LENGTH)

# Display the password
echo "Generated password: $PASSWORD"
