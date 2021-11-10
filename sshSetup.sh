#!/usr/bin/env bash

mkdir -p ~/.ssh && cd $_
touch ~/.ssh/config
echo "The default key name is github_jared.vogt"
echo "Enter a new one (no spaces)... or return to accept"  # FIXME: allow for spaces
read KEYNAME
if [ ${#KEYNAME} -ge 1  ]
  then
    echo "New name: $KEYNAME"
  else
    KEYNAME=github_jared.vogt
fi
ssh-keygen -t ed25519 -f $KEYNAME -C "jared.vogt@gmail.com"
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/$KEYNAME
less $KEYNAME.pub | pbcopy  # get the pub key to move to github
