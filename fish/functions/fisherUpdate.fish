function fisherUpdate
    # Get current day of month
    set -l current_day (date '+%-d')
    
    # Only run on 1st and 15th
    if test $current_day -ne 1; and test $current_day -ne 15
        return 0
    end

    echo "Running Fisher Update"
    
    # Launch update check in background with redirection
    fish -c "fisher list | fisher update --dry-run 2>&1 | grep '^Update'" >/tmp/fisher_check 2>/dev/null &
    set -l pid $last_pid
    
    # Give it 2 seconds to complete
    sleep 2
    
    # Check if process is still running
    if ps -p $pid >/dev/null
        kill $pid 2>/dev/null
        echo "Update check timed out. Are you offline?"
        return 1
    end

    # Read the results
    set -l outdated_plugins (cat /tmp/fisher_check)
    rm /tmp/fisher_check

    if test -n "$outdated_plugins"
        echo "The following plugins have updates available:"
        printf "%s\n" $outdated_plugins

        read -l -P "Would you like to update these plugins? [y/N] " confirm
        switch $confirm
            case Y y
                echo "Updating plugins..."
                # Run update in background
                fisher update &
                set -l update_pid $last_pid
                
                # Give it 5 seconds to complete
                sleep 5
                if ps -p $update_pid >/dev/null
                    kill $update_pid 2>/dev/null
                    echo "Update timed out. Check your connection and try again."
                end
            case '' N n
                echo "Update cancelled"
            case '*'
                echo "Invalid response, update cancelled"
        end
    else
        echo "All plugins are up to date!"
    end
end
