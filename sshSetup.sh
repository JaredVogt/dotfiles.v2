#!/usr/bin/env bash

# Create .ssh directory if it doesn't exist and change to it
mkdir -p ~/.ssh && cd $_

# Create config file if it doesn't exist
touch ~/.ssh/config

# Check for existing github.com configuration
if grep -q "Host github.com" ~/.ssh/config; then
    echo "Found existing github.com configuration:"
    echo "----------------------------------------"
    awk '/Host github.com/{p=1;print;next} /Host /{p=0} p&&NF{print}' ~/.ssh/config
    echo "----------------------------------------"
    
    echo "Do you want to continue and add a new key? (y/n)"
    read CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
fi

echo "The default key name is github_jared.vogt"
echo "Enter a new one (no spaces)... or return to accept"  # FIXME: allow for spaces
read KEYNAME

if [ ${#KEYNAME} -ge 1  ]
  then
    echo "New name: $KEYNAME"
  else
    KEYNAME=github_jared.vogt
fi

echo "Save the password!!!!"

# Generate SSH key
ssh-keygen -t ed25519 -f $KEYNAME -C "jared.vogt@gmail.com"

# Check if github.com host entry exists
if grep -q "Host github.com" ~/.ssh/config; then
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
    }' ~/.ssh/config > ~/.ssh/config.tmp && mv ~/.ssh/config.tmp ~/.ssh/config
else
    # Add complete new github.com configuration if no existing entry
    cat >> ~/.ssh/config << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/$KEYNAME
    IdentitiesOnly yes
EOF
fi

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/$KEYNAME

# Copy public key to clipboard
less $KEYNAME.pub | pbcopy  # get the pub key to move to github

echo "SSH key setup complete!"
echo "The public key has been copied to your clipboard."
echo "Please add it to your GitHub account at: https://github.com/settings/ssh/new"
