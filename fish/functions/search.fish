# Search function that combines ripgrep and fzf for powerful content searching
# 
# Features:
# - Searches file contents using ripgrep (rg)
# - Interactive filtering of results using fzf
# - Previews file contents with line highlighting using bat
# - Respects ignore patterns from ~/.config/fd/ignore
# - Shows search matches in context with syntax highlighting
# - Opens selected file at the matching line in your default editor ($EDITOR)
#
# Usage: search "search term"
#   - Use Tab to toggle between search/movement modes
#   - In movement mode, use j/k to navigate results
#   - Press Enter to select a result and open in editor
#   - Use ? to see fzf keybindings
#
# Dependencies:
#   - ripgrep (rg)
#   - fzf
#   - bat (for syntax-highlighted previews)
#   - $EDITOR environment variable should be set
#
function search
    if test (count $argv) = 0
        echo "Usage: search [search_term]"
        return 1
    end
    
    # Parse ignore patterns from fd's ignore file
    # These patterns will be converted to ripgrep's glob format
    set -l ignore_patterns
    if test -f ~/.config/fd/ignore
        while read -l line
            # Skip empty lines and comments (lines starting with #)
            if test -n "$line" && not string match -q '#*' $line
                # Convert each ignore pattern to ripgrep's glob format
                # --glob !pattern tells ripgrep to ignore matching files/directories
                set ignore_patterns $ignore_patterns "--glob" "!$line"
            end
        end < ~/.config/fd/ignore
    end
    
    # Execute ripgrep with the following flags:
    # --line-number: Show line numbers
    # --no-heading: Don't group matches by file
    # --color=always: Necessary for fzf preview
    # --smart-case: Case-insensitive unless pattern contains uppercase
    # Store the search result in a variable for processing
    set -l result (rg --line-number --no-heading --color=always --smart-case --follow \
       $ignore_patterns \
       "$argv" |
    # Pipe to fzf for interactive filtering
    # --ansi: Required for colored preview
    # --delimiter: Split input on ':' for preview
    # Preview window shows file contents with current line highlighted
    fzf --ansi \
        --delimiter : \
        --preview 'bat --style=numbers --color=always {1} -H {2}' \
        --preview-window up,60%)

    # If a result was selected (user didn't cancel with Esc)
    if test -n "$result"
        # Split the result into filename and line number
        # ripgrep output format is: file:line:content
        set -l parts (string split : $result)
        set -l file $parts[1]
        set -l line $parts[2]

        # Check if we have an editor set
        if not set -q EDITOR
            echo "No editor set. Please set your EDITOR environment variable."
            return 1
        end

        # Open file at specific line in user's preferred editor
        # Note: Line number syntax might vary by editor, this assumes standard +line syntax
        $EDITOR +$line $file
    end
end
