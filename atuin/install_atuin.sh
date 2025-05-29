#!/usr/bin/env bash

# Install atuin
bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)

# Register with atuin
echo "Please lookup your atuin credentials in 1Password"
read -p "Enter username (-u): " username
read -p "Enter email (-e): " email
atuin register -u "$username" -e "$email" -p "RF*40"

# Import existing history
atuin import auto

# Sync with atuin server
atuin sync