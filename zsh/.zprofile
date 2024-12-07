eval $(/opt/homebrew/bin/brew shellenv)

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Aliases
alias ipm=/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm
alias lla="eza --git -l -g --icons -h -a -H --time-style=long-iso"
# alias reload="source ~/.zprofile"
alias proj="cd ~/projects"
alias cellar="cd /opt/homebrew/Cellar && lla"
