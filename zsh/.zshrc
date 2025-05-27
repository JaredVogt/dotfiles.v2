# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

zstyle ':omz:update' frequency 7  # how often to update OMZ

ENABLE_CORRECTION="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$XDG_CONFIG_HOME/zsh"

# Which plugins would you like to load?
plugins=(zoxide git vi-mode web-search)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#

# Aliases
# alias ipm=/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm
# alias lla="eza --git -l -g --icons -h -a -H --time-style=long-iso"
# alias reload="source ~/.zshrc"
# # alias reload="source ~/.zprofile"
# alias proj="cd ~/projects"
# alias cellar="cd /opt/homebrew/Cellar && lla"

## VIM MODE STUFF
# Changes the cursor shape for different modes
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
# 
# # Customize the indicators
# MODE_INDICATOR="%F{white}<%F{yellow}NORMAL%F{white}>"
# INSERT_MODE_INDICATOR="%F{white}<%F{green}INSERT%F{white}>"
# VISUAL_MODE_INDICATOR="%F{white}<%F{blue}VISUAL%F{white}>"

## eza stuff
# FIXME this is fucked up - https://github.com/eza-community/eza/issues/1224
# It should be reading $XDG_CONFIG_HOME but it isn't
export EZA_CONFIG_DIR=/Users/jaredvogt/.config/eza

## starship stuff
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)" # NOTE this is supposed to be in .zshrc - and there maybe conflicts with other prompt stuff to figure out - this overrides the agnoster prompt

## atuin stuff
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Last commands to execute
# echo "popping directly into fish"
# cd ~/projects
# fish



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Added by Windsurf
export PATH="/Users/jaredvogt/.codeium/windsurf/bin:$PATH"

# Added by Windsurf - Next
export PATH="/Users/jaredvogt/.codeium/windsurf/bin:$PATH"
