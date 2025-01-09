#!/bin/bash

# Variables
USERNAME="newuser"
PASSWORD="securepassword"
GROUP="developers"

# Check if the group exists; if not, create it
if ! getent group "$GROUP" > /dev/null; then
    groupadd "$GROUP"
    echo "Group '$GROUP' created."
else
    echo "Group '$GROUP' already exists."
fi

# Check if the user exists; if not, create the user
if ! id -u "$USERNAME" > /dev/null 2>&1; then
    useradd -m -g "$GROUP" -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "User '$USERNAME' created and added to group '$GROUP'."
else
    echo "User '$USERNAME' already exists."
fi
