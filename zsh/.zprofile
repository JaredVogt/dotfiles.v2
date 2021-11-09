eval $(/opt/homebrew/bin/brew shellenv)

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
alias lla="ls -la"
alias reload="source ~/.zprofile"
alias proj="cd ~/projects"
alias cellar="cd /opt/homebrew/Cellar && lla"
