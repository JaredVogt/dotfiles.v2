#!/usr/bin/env bash

BREWCOMMAND="brew install --cask"
declare -a files=(
1password
adobe-creative-cloud
alacritty
alfred
amethyst
audio-hijack
avibrazil-rdm
bartender
bettertouchtool
brave-browser
cheatsheet
dropbox
easyfind
espresso
font-fira-code
iina
inkdrop
iterm2
karabiner-elements
keyboard-maestro
keycastr
kindle
kitty
little-snitch
loopback
macvim
mailplane
miro
node
path-finder
profind
putio-adder
python
slack
stay
switchaudio-osx
switchresx
textexpander
vimr
vlc
witch
xbar
)

for file in "${files[@]}" 
  do 
    echo "Installing $file"
    $BREWCOMMAND $file 
done
