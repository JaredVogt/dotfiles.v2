alias ipm=/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm
alias lla="eza --git -l -g --icons -h -a -H --time-style=long-iso"
alias reload="source ~/.zshrc && source ~/.zshenv"
# alias reload="source ~/.zprofile"
alias proj="cd ~/projects"
alias cellar="cd /opt/homebrew/Cellar && lla"

function nf() {
    local original_dir=$(pwd)
    local file
    
    cd ~/projects/dotfiles.v2
    
    file=$(fzf) && [ -n "$file" ] && nvim "$file"
    
    cd "$original_dir"
}


