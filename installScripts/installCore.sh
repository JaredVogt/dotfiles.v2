#!/usr/bin/env bash
BREWCOMMAND="brew install --cask"
# link these files to the home directory
declare -a files=(
jq
fzf
fish
zsh-vi-mode
vim
ruby
pygments
bash
brew isntall neovim
switchaudio-osx
loopback
audio-hijack
vlc
tmux
exa
)

for file in "${files[@]}" 
  do 
    echo "Installing $file"
    $BREWCOMMAND $file 
done
