#!/opt/homebrew/bin/fish

set DATAPATH ~/projects/dotfiles.v2/fish
# this needs to be run inside of fish shell

# set the theme
omf theme agnoster
omf install agnoster

# install plugins
# curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher  # plugin manager
# fisher is now being installed by brew

# fisher install IlanCosman/tide@v5  # https://github.com/IlanCosman/tide
fisher install FabioAntunes/fish-nvm edc/bass
fisher install jethrokuan/fzf
fisher install laughedelic/pisces
fisher install oh-my-fish/plugin-bang-bang
fisher install oh-my-fish/plugin-pj
fisher install jethrokuan/z
fisher install danhper/fish-ssh-agent
fisher install jorgebucaran/fish-bax

# this is required to get node working  FIXME: but it still has to be run twice to prime pump??
# https://eshlox.net/2019/01/27/how-to-use-nvm-with-fish-shell /https://superuser.com/questions/905255/how-to-get-fish-shell-and-nvm-both-installed-with-homebrew-to-work-together 
omf install nvm
set -gx NVM_DIR (brew --prefix nvm)
