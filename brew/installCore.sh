#!/usr/bin/env bash
BREWCOMMAND="brew install --cask"
# link these files to the home directory
declare -a files=(
# languages
node
python@3.10
ruby
# shell
fish
bash
zsh-vi-mode
# tools/help stuff
jq
fzf
tmux
exa
peco
dockutil
wget
pygments
# editors
vim
neovim
# audio
switchaudio-osx
ffmpeg
)

for file in "${files[@]}" 
  do 
    echo "Installing $file"
    $BREWCOMMAND $file 
done
