# Place this in ~/.config/fish/functions/fish_user_key_bindings.fish

function fish_user_key_bindings
    # First, ensure we're using vi mode
    fish_vi_key_bindings

    # Clear existing bindings
    bind -e -M default \e\[A  # up arrow
    bind -e -M insert \e\[A
    bind -e -M default \e\[B  # down arrow
    bind -e -M insert \e\[B
    
    # Variable to track press state
    set -g press_count 0
    set -g last_press 0

    # Custom function to handle up arrow press
    function handle_up_arrow
        set current (date +%s)
        
        if test $press_count -eq 1
            # Check if we're within 0.5 seconds of last press
            if test (math $current - $last_press) -le 1
                set -g press_count 0
                commandline -r ""      # Clear line
                atuin search -i        # Run atuin search
                return
            end
        end
        
        # Either first press or too slow
        set -g press_count 1
        set -g last_press $current
        commandline -r ""
        set last_cmd (atuin history last --format "{command}")
        commandline -r $last_cmd
    end

    # Handle down arrow with simple clear
    function handle_down_arrow
        commandline -r ""
    end

    # Bind up arrow to our custom function in both insert and default mode
    bind -M default \e\[A handle_up_arrow
    bind -M insert \e\[A handle_up_arrow
    
    # Bind down arrow to clear command line
    bind -M default \e\[B handle_down_arrow
    bind -M insert \e\[B handle_down_arrow
    
    # Bind 'k' in normal mode to same behavior as up arrow
    bind -M default k handle_up_arrow
    
    # Bind 'j' in normal mode to same behavior as down arrow
    bind -M default j handle_down_arrow
end
