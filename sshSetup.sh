#!/usr/bin/env bash

# Script version
VERSION="1.7.3"

# Help documentation
show_help() {
    cat << EOF
GitHub SSH Key Setup Script v${VERSION}
----------------------------------------

DESCRIPTION
    This script automates the process of setting up a new SSH key for GitHub
    authentication on macOS. It handles creating the key, configuring SSH, and
    copying the public key to your clipboard.

USAGE
    $(basename "$0") [OPTIONS]

OPTIONS
    -h, --help     Show this help message
    -v, --version  Show script version
    -f, --force    Skip working key check and force new key setup

STEPS PERFORMED
    1. Checks for and displays any existing SSH keys in ~/.ssh/
    2. Shows any existing GitHub configuration in ~/.ssh/config
    3. Prompts for a new key name (defaults to github_jared.vogt)
    4. Verifies the new key name won't overwrite existing keys
    5. Creates a new ed25519 SSH key with enhanced security options
    6. Updates ~/.ssh/config with the new key configuration
    7. Adds the key to the SSH agent with keychain integration
    8. Copies the public key to clipboard for adding to GitHub

REQUIREMENTS
    - macOS (uses macOS-specific features like pbcopy and keychain)
    - Access to ~/.ssh/ directory
    - GitHub account to add the public key to

AFTER RUNNING
    1. The public key will be in your clipboard
    2. Visit https://github.com/settings/ssh/new
    3. Paste the key and save
    4. Test with: ssh -T git@github.com

For more information, visit:
https://docs.github.com/en/authentication/connecting-to-github-with-ssh
EOF
}

# Process command line arguments
FORCE_SETUP=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "v${VERSION}"
            exit 0
            ;;
        -f|--force)
            FORCE_SETUP=true
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            echo "Use -h or --help to show usage information"
            exit 1
            ;;
    esac
done

# Exit on error, undefined variable, or pipe failure
set -euo pipefail

# Default values
DEFAULT_KEYNAME="github_jared.vogt"
DEFAULT_EMAIL="jared.vogt@gmail.com"

echo "GitHub SSH Key Setup Script v${VERSION}"
echo "--------------------------------------"

# Check for existing working GitHub SSH authentication
if [[ "$FORCE_SETUP" == false ]]; then
    echo -n "Checking for existing GitHub SSH authentication... "
    
    # Run SSH check and wait for response
    SSH_OUTPUT=$(ssh -vT git@github.com 2>&1 || true)
    
    # Now check the output
    if echo "$SSH_OUTPUT" | grep -q "successfully authenticated"; then
        WORKING_KEY=$(echo "$SSH_OUTPUT" | grep "Server accepts key:" | sed -E 's/.*Server accepts key: ([^[:space:]]+).*/\1/')
        GITHUB_USER=$(echo "$SSH_OUTPUT" | grep "Hi" | sed -E 's/Hi ([^!]*).*/\1/')
        printf "✅\n"
        echo "Using key: $WORKING_KEY"
        echo "Authenticated as: $GITHUB_USER"
        read -p "Do you want to set up a new key anyway? (y/n) " CONTINUE
        if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
            echo "Exiting..."
            exit 0
        fi
    else
        printf "❌\n"
        echo "No working SSH authentication found."
        echo "Continuing with setup..."
        echo
    fi
fi

# Create .ssh directory if it doesn't exist and set proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cd ~/.ssh

# Create config file if it doesn't exist and set proper permissions
touch config
chmod 600 config

# Show existing SSH keys
echo "Existing SSH keys in ~/.ssh:"
echo "----------------------------------------"
# Look for private keys (no .pub extension) and show both private and public keys
find . -type f -not -name "*.pub" -not -name "known_hosts" -not -name "config" -not -name "authorized_keys" | while read -r key; do
    if [ -f "${key}.pub" ]; then
        echo "Key pair found:"
        echo "  Private: ${key#./}"
        echo "  Public:  ${key#./}.pub"
        echo ""
    fi
done || echo "No SSH key pairs found"
echo "----------------------------------------"

# Check for existing github.com configuration
echo "Checking ~/.ssh/config file..."
echo "This file tells SSH how to handle different hosts."
echo "For GitHub, it specifies which identity file (SSH key) to use."
if grep -q "Host github.com" config; then
    echo "Found existing github.com configuration:"
    echo "----------------------------------------"
    awk '/Host github.com/{p=1;print;next} /Host /{p=0} p&&NF{print}' config
    echo "----------------------------------------"
    echo "This configuration tells SSH to:"
    echo "- Use 'git' as the username for github.com"
    echo "- Use a specific SSH key file"
    echo "- Enable macOS keychain integration"
    
    read -p "Do you want to continue and add a new key? (y/n) " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
fi

# Get key name from user
echo "The default key name is $DEFAULT_KEYNAME"
read -p "Enter a new one (no spaces)... or return to accept: " KEYNAME
KEYNAME=${KEYNAME:-$DEFAULT_KEYNAME}
echo "Using key name: $KEYNAME"

# Check if key already exists
if [[ -f "$KEYNAME" || -f "${KEYNAME}.pub" ]]; then
    echo "Error: Key files already exist:"
    [[ -f "$KEYNAME" ]] && echo "- Private key: $KEYNAME"
    [[ -f "${KEYNAME}.pub" ]] && echo "- Public key: ${KEYNAME}.pub"
    echo "Please either:"
    echo "1. Choose a different key name, or"
    echo "2. Remove existing keys manually using:"
    echo "   rm ~/.ssh/$KEYNAME ~/.ssh/${KEYNAME}.pub"
    exit 1
fi

# Warn about password importance
echo "⚠️  IMPORTANT: Save the password securely! ⚠️"

# Generate SSH key with enhanced security
# -N "" means no passphrase for now (will prompt for one)
ssh-keygen -t ed25519 -f "$KEYNAME" -C "$DEFAULT_EMAIL" -o -a 100 -N "" || {
    echo "Error generating SSH key. If the key exists, you'll need to remove it first."
    exit 1
}

# Set proper permissions for the new key files
chmod 600 "${KEYNAME}"
chmod 644 "${KEYNAME}.pub"

# Update SSH config
if grep -q "Host github.com" config; then
    # Comment out existing IdentityFile and add new one before it
    awk -v key="$KEYNAME" '
    BEGIN { in_github = 0 }
    /Host github.com/ { in_github = 1 }
    /Host / && !/Host github.com/ { in_github = 0 }
    {
        if (in_github && $1 == "IdentityFile") {
            print "    IdentityFile ~/.ssh/" key
            print "#" $0
        } else {
            print $0
        }
    }' config > config.tmp && mv config.tmp config
else
    # Add complete new github.com configuration
    cat >> config << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/$KEYNAME
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
EOF
fi

# Set proper permissions for config file
chmod 600 config

# Start SSH agent and add key
echo "Setting up SSH agent..."
echo "The SSH agent helps manage your SSH keys and remembers your passphrases"
echo "It should start automatically on modern macOS systems"
echo "Starting SSH agent now..."

# Check if SSH agent is running
if ! pgrep -q ssh-agent; then
    echo "SSH agent wasn't running. Starting it now..."
    eval "$(ssh-agent -s)"
else
    echo "SSH agent is already running"
fi

echo "Adding your new key to SSH agent..."
echo "This will allow you to use the key without re-entering the passphrase"
echo "Your key will be stored in the macOS keychain for convenience"
ssh-add --apple-use-keychain "$KEYNAME" || {
    echo "Error adding key to SSH agent. You might need to:"
    echo "1. Ensure SSH agent is running: eval \$(ssh-agent -s)"
    echo "2. Try adding the key manually: ssh-add --apple-use-keychain ~/.ssh/$KEYNAME"
    exit 1
}

# Copy public key to clipboard
echo "Copying your public key to clipboard..."
cat "${KEYNAME}.pub" | pbcopy

echo "✅ SSH key setup complete!"
echo
echo "Here's what was configured:"
echo "1. Created new SSH key pair in ~/.ssh/$KEYNAME"
echo "2. Updated ~/.ssh/config to use this key for GitHub"
echo "3. Added key to SSH agent with keychain integration"
echo "4. Copied public key to your clipboard"
echo
echo "Next steps:"
echo "1. Keep your private key ($KEYNAME) secure - never share it!"
echo "2. Go to GitHub: https://github.com/settings/ssh/new"
echo "3. Click 'New SSH key'"
echo "4. Add a title (like 'MacBook Pro 2024')"
echo "5. Paste your public key (it's already in your clipboard)"
echo "6. Click 'Add SSH key'"
echo
echo "To test your setup:"
echo "$ ssh -T git@github.com"
echo "You should see: 'Hi username! You've successfully authenticated with GitHub'"