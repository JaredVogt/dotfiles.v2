#!/usr/bin/env bash

DATAPATH=~/projects/dotfiles.v2

# move zsh files into place
ln -sfv $DATAPATH/zsh/.zprofile ~/.
ln -sfv $DATAPATH/zsh/.zshenv ~/.
ln -sfv $DATAPATH/zsh/.zshrc ~/.

# move fish files into place
ln -sfv $DATAPATH/fish/config.fish ~/.config/fish/. 
ln -sfv $DATAPATH/fish/aliases.fish ~/.config/fish/. 
ln -sfv $DATAPATH/fish/functions/*.fish ~/.config/fish/functions/  # move all functions into place

# move git files into place
ln -sfv $DATAPATH/git/.gitconfig ~/.

# move tmux conf file into place
ln -sfv $DATAPATH/tmux/.tmux.conf ~/.

# move README.md into place 
ln -sfv $DATAPATH/README.md ~/.

