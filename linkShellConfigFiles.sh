#!/usr/bin/env bash

REPOPATH=~/projects/dotfiles.v2
CONFIGPATH=~/.config

# move zsh files into place
ln -sfv $REPOPATH/zsh/.zprofile ~/.
ln -sfv $REPOPATH/zsh/.zshenv ~/.
ln -sfv $REPOPATH/zsh/.zshrc ~/.

# move fish files into place
ln -sfv $REPOPATH/fish/config.fish $CONFIGPATH/fish/. 
ln -sfv $REPOPATH/fish/aliases.fish $CONFIGPATH/fish/. 
ln -sfv $REPOPATH/fish/aliases_git.fish $CONFIGPATH/fish/. 
ln -sfv $REPOPATH/fish/functions/*.fish $CONFIGPATH/fish/functions/  # move all functions into place

# move git files into place
ln -sfv $REPOPATH/git/.gitconfig ~/.

# move tmux conf file into place
ln -sfv $REPOPATH/tmux/.tmux.conf ~/.

# move README.md into place 
ln -sfv $REPOPATH/README.md ~/.

# move atuin file into place
ln -sfv $REPOPATH/atuin/config.toml $CONFIGPATH/atuin/. 

# move starship file into place
ln -sfv $REPOPATH/starship/starship.toml $CONFIGPATH/starship/. 

# move wezterm file into place
ln -sfv $REPOPATH/wezterm/wezterm.lua $CONFIGPATH/wezterm/. 

# move karabiner file into place
ln -sfv $REPOPATH/karabiner/karabiner.json $CONFIGPATH/karabiner/. 

# move nushell file into place
ln -sfv $REPOPATH/nushell/config.nu $CONFIGPATH/nushell/. 
ln -sfv $REPOPATH/nushell/env.nu $CONFIGPATH/nushell/. 

# move vimium-options file into place
ln -sfv $REPOPATH/vimium/vimium-options.json $CONFIGPATH/vimium/. 

# move yazi file into place
ln -sfv $REPOPATH/yazi/yazi.toml $CONFIGPATH/yazi/. 

# move kitty file into place
ln -sfv $REPOPATH/kitty/kitty.conf $CONFIGPATH/kitty/. 

