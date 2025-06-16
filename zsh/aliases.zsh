alias ipm=/Applications/Inkdrop.app/Contents/Resources/app/ipm/bin/ipm
alias lla="eza --git -l -g --icons -h -a -H --time-style=long-iso"
alias reload="source ~/.zshrc && source ~/.zshenv"
# alias reload="source ~/.zprofile"
alias proj="cd ~/projects"
alias cellar="cd /opt/homebrew/Cellar && lla"
alias rm="trash"
alias claude="~/.claude/local/claude"
alias ccr="claude -r"
alias dot='edit_dotfiles ~/projects/dotfiles.v2'
alias dotv='edit_dotfiles ~/.config/nvim'
alias dotp='edit_dotfiles ~/projects/ai_context'
alias rmd='~/projects/glow/glow -c'
alias more='bat'  # bat is better than more

function edit_dotfiles() {
    local original_dir=$(pwd)
    local target_dir=$1
    local file
    
    cd "$target_dir"
    
    file=$(fzf) && [ -n "$file" ] && nvim "$file"
    
    cd "$original_dir"
}


