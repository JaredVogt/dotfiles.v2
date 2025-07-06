#!/usr/bin/env bash

# Install atuin
echo "This is installed with brew... continue to set up sync\n"
# Register with atuin
echo "Please lookup your atuin credentials in 1Password"
read -p "Enter username (-u): " username
read -p "Enter email (-e): " email
read -p "Enter password (-p): " password
atuin register -u "$username" -e "$email" -p "$password"

# Import existing history
atuin import auto

# Sync with atuin server
atuin sync
