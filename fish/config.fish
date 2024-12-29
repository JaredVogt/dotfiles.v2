if status is-interactive
    # Commands to run in interactive sessions can go here
    setupFisher
    fisherUpdate
end

# Disable the welcome message that appears when opening a new shell
set fish_greeting

# Enable vi mode
fish_vi_key_bindings

# Set cursor shapes for different vi modes
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

# Source all aliases
source ~/.config/fish/aliases.fish
source ~/.config/fish/aliases_git.fish

# Initialize zoxide (smart directory jumper)
zoxide init fish | source

# Initialize starship prompt
starship init fish | source

# Initialize atuin (shell history manager)
atuin init fish | source

# Bind up arrow and 'k' in vi mode to Atuin search
bind -k up _atuin_search
bind -M default k _atuin_search

# Bind Ctrl+F to accept autosuggestion in both insert and default modes
# kitty is remapping `hyper+l` to `opt+f` to trigger this command (see kitty.conf)
bind -M insert \ef accept-autosuggestion
bind \ef accept-autosuggestion

# FZF
bind -M default f _fzf_search_directory
set -gx FZF_DEFAULT_OPTS "--layout=reverse --height 90% --bind 'tab:toggle-search,shift-tab:toggle-search,J:down,K:up'"
