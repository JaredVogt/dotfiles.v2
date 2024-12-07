if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_vi_key_bindings
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set fish_cursor_visual block

# source all aliases
source ~/.config/fish/aliases.fish

# get zoxide running
zoxide init fish | source
starship init fish | source
atuin init fish | source

# Bind up arrow and 'k' in vi mode to Atuin search
bind -k up _atuin_search
bind -M default k _atuin_search

# Got the chunk below from: https://github.com/fish-shell/fish-shell/issues/5471
function fish_user_key_bindings
#    fish_vi_mode
   bind -M insert \cf accept-autosuggestion
   bind \cf accept-autosuggestion
#    for mode in insert default visual
#      bind -M $mode \ck 'history --merge ; up-or-search'
#      bind -M $mode \cj 'history --merge ; down-or-search' 
#    end
end

# set --universal tide_vi_mode_icon_default N
# set --universal tide_vi_mode_icon_repalce R
# set --universal tide_left_prompt_items vi_mode $tide_left_prompt_items
# set -e --universal tide_right_prompt_items[(contains -i vimode $tide_right_prompt_items)]
