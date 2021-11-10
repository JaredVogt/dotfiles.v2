#!/usr/bin/env bash

mkdir .ssh && cd $_
touch ~/.ssh/config
ssh-keygen -t ed25519 -C "jared.vogt@gmail.com"
# this will prompt for a file name. The commands below expect that filename to be `github_jared.vogt`
eval "$(ssh-agent -s)"
ssh-add -K ~/.ssh/github_jared.vogt
less github_jared.vogt.pub | pbcopy  # get the pub key to move to github
