#!/usr/bin/env bash
BREWCOMMAND="brew install --cask"
# link these files to the home directory
declare -a files=(
1password
alfred
avibrazil-rdm
mailplane
macvim
dropbox
path-finder
keyboard-maestro
switchresx
inkdrop
bettertouchtool
little-snitch
karabiner-elements
slack
xbar
node
python
bartender
amethyst
kitty
alacritty
vimr
font-fira-code
switchaudio-osx
loopback
audio-hijack
vlc
textexpander
)

for file in "${files[@]}" 
  do 
    echo "Installing $file"
    $BREWCOMMAND $file 
done
