# atuinDelete - Fish function for selective Atuin history deletion
function atuinDelete
    # Show help if no arguments or --help
    if test -z "$argv" -o "$argv[1]" = "--help"
        echo "Usage: atuinDelete [search_term]"
        echo
        echo "Selectively delete Atuin shell history entries that match the given search term."
        echo
        echo "Options:"
        echo "  --help     Show this help message"
        echo
        echo "Arguments:"
        echo "  search_term    Term to match against command history (required)"
        echo "                 For multiple words, enclose in quotes (\" or ')"
        echo
        echo "Examples:"
        echo "  atuinDelete git              Delete commands starting with 'git'"
        echo "  atuinDelete \"git commit\"     Delete commands starting with 'git commit'"
        echo "  atuinDelete 'git push'       Delete commands starting with 'git push'"
        return 1
    end

    # First search to show matches
    set matches (atuin search "^$argv")
    
    # Check if any matches were found
    if test -z "$matches"
        echo "No matches found for '$argv'"
        return 0
    end

    # Show the matches
    echo "Found these matches:"
    printf "%s\n" $matches

    # Prompt for confirmation
    read -l -P "Delete these entries? [y/N] " confirm
    
    if test "$confirm" = "y" -o "$confirm" = "Y"
        atuin search "^$argv" --delete
        echo "Entries deleted"
    else
        echo "Operation cancelled"
    end
end
