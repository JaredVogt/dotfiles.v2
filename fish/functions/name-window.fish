function name-window
    if test -n "$argv[1]"
        kitty @ set-window-title "$argv[1]"
    else
        echo "Usage: name-window <title>"
    end
end
