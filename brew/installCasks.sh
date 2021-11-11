#!/usr/bin/env bash

BREWCOMMAND="brew install --cask"
declare -a files=(
1password
alfred
iterm2
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
adobe-creative-cloud
keycastr
kindle
putio-adder
stay
brave-browser
espresso
easyfind
profind
)

for file in "${files[@]}" 
  do 
    echo "Installing $file"
    $BREWCOMMAND $file 
done
