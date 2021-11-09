if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_vi_key_bindings


# Got the chucnk below from: https://github.com/fish-shell/fish-shell/issues/5471
function fish_user_key_bindings
#    fish_vi_mode
#    bind -M insert \cf accept-autosuggestion
#    bind \cf accept-autosuggestion
#    for mode in insert default visual
#      bind -M $mode \ck 'history --merge ; up-or-search'
#      bind -M $mode \cj 'history --merge ; down-or-search' 
#    end
end
