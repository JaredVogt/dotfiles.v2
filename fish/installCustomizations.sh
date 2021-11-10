#!/usr/bin/env bash

DATAPATH=~/projects/dotfiles.v2/fish
# this needs to be run inside of fish shell

# set the theme
omf theme agnoster
omf install agnoster

# install plugins
fisher install FabioAntunes/fish-nvm edc/bass
fisher install jethrokuan/fzf
fisher install laughedelic/pisces
fisher install oh-my-fish/plugin-bang-bang
fisher install oh-my-fish/plugin-pj
fisher install jethrokuan/z
fisher install danhper/fish-ssh-agent
fisher install jorgebucaran/fish-bax

# move config.fish into place
ln -sf $DATAPATH/setAbbreviations.sh ~/.config/fish/. 

