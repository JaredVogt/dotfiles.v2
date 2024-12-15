# Handles the installation and setup of Fisher package manager and essential plugins.
# Reads plugin list from $XDG_CONFIG_HOME/fish/fish_plugins (defaults to ~/.config/fish/fish_plugins)
# Automatically installs Fisher if not present, then checks for and installs missing plugins.
# Usage: Call setupFisher to ensure Fisher and all required plugins are installed.

function setupFisher
    echo "Running Fisher Setup"
    # Determine config path
    set -l config_dir $XDG_CONFIG_HOME
    if test -z "$XDG_CONFIG_HOME"
        set config_dir ~/.config
    end
    set -l plugin_file "$config_dir/fish/fish_plugins"

    if not test -e $plugin_file
        echo "Error: $plugin_file not found"
        return 1
    end
    
    # Read plugin list from file, skipping empty lines and comments
    set -l plugin_list (cat $plugin_file | string match -rv '^#|^$')

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
