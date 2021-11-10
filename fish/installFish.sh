#!/usr/bin/env bash

# install the basics
brew install fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish  # this installs omf 
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher  # plugin manager

