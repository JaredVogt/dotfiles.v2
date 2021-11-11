eval $(/opt/homebrew/bin/brew shellenv)

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# add lvim to path
export PATH=~/.local/bin:$PATH

# History config
#set history size
export HISTSIZE=10000
#save history after logout
export SAVEHIST=10000
#history file
export HISTFILE=~/.zhistory
#append into history file
setopt INC_APPEND_HISTORY
#save only one command if 2 common are same and consistent
setopt HIST_IGNORE_DUPS
#add timestamp for each entry
setopt EXTENDED_HISTORY


# Aliases
alias ipm=/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm
alias lla="exa --git -l -g --icons -h -a -H --time-style=long-iso"
alias reload="source ~/.zprofile"
alias proj="cd ~/projects"
alias cellar="cd /opt/homebrew/Cellar && lla"
