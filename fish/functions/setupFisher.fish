function setupFisher
    echo "Running Fisher Setup"
    # List of desired plugins
    set -l plugin_list \
        'PatrickF1/fzf.fish' \
        'jorgebucaran/nvm.fish' \
        'jorgebucaran/autopair.fish' \
        'nickeb96/puffer-fish'

    # Check if fisher is installed - if not, install it
    if not type -q fisher
        echo "Fisher is not installed. Installing..."
        curl -sL https://git.io/fisher | source
        fisher install jorgebucaran/fisher
        # Source fisher for the first time
        source $__fish_config_dir/functions/fisher.fish
    end
    
    # Check each plugin
    set -l missing_plugins
    for plugin in $plugin_list
        set -l plugin_name (string split '/' $plugin)[-1]
        
        # For puffer-fish, check for one of its specific files
        if string match -q "puffer-fish" $plugin_name
            if not test -e $__fish_config_dir/functions/_puffer_fish_expand_bang.fish
                set -a missing_plugins $plugin
            end
        else
            # For other plugins, check the standard locations
            if not test -e $__fish_config_dir/conf.d/$plugin_name; and \
               not test -e $__fish_config_dir/functions/$plugin_name.fish; and \
               not test -e $__fish_config_dir/completions/$plugin_name.fish
                set -a missing_plugins $plugin
            end
        end
    end

    # Install any missing plugins
    if test -n "$missing_plugins"
        echo "Installing missing plugins: $missing_plugins"
        fisher install $missing_plugins
    end
end
