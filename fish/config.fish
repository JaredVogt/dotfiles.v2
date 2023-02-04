if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_vi_key_bindings

# source all aliases
source ~/.config/fish/aliases.fish

# get zoxide running
zoxide init fish | source

# Got the chunk below from: https://github.com/fish-shell/fish-shell/issues/5471
function fish_user_key_bindings
#    fish_vi_mode
#    bind -M insert \cf accept-autosuggestion
#    bind \cf accept-autosuggestion
#    for mode in insert default visual
#      bind -M $mode \ck 'history --merge ; up-or-search'
#      bind -M $mode \cj 'history --merge ; down-or-search' 
#    end
end

# set --universal tide_vi_mode_icon_default N
# set --universal tide_vi_mode_icon_repalce R
# set --universal tide_left_prompt_items vi_mode $tide_left_prompt_items
# set -e --universal tide_right_prompt_items[(contains -i vimode $tide_right_prompt_items)]
