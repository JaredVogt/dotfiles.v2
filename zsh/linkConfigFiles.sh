#!/opt/homebrew/bin/fish
# this needs to be run inside of fish shell

set DATAPATH ~/projects/dotfiles.v2/zsh

# move files into place
ln -sf $DATAPATH/.zprofile ~/.
ln -sf $DATAPATH/.zshenv ~/.
ln -sf $DATAPATH/.zshrc ~/.

