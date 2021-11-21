#!/usr/bin/env bash
BREWCOMMAND="brew install --cask"
# link these files to the home directory
declare -a files=(
# languages
node
python@3.10
ruby
luarocks
deno
# nvm
# shell
fish
fisher
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
trash
# editors
vim
neovim
tree-sitter  # I think this is the right thing - need to verify how install works
# audio
switchaudio-osx
ffmpeg
)

for file in "${files[@]}" 
  do 
    echo "Installing $file"
    $BREWCOMMAND $file 
done
