#!/usr/bin/env zsh

# Define base paths
REPOPATH=~/projects/dotfiles.v2

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to discover available programs
discover_programs() {
    local programs=()
    
    # Always include system category for special files
    programs+=("system")
    
    # Scan for directories that have config files
    for dir in "$REPOPATH"/*; do
        if [[ -d "$dir" ]]; then
            local dirname=$(basename "$dir")
            
            # Skip certain directories
            case "$dirname" in
                "logs-backups"|"brew"|"ubersicht"|"inkdrop"|".git"|"git") 
                    continue
                    ;;
            esac
            
            # Check if directory has any config files (not starting with . or skip)
            if find "$dir" -type f ! -name '.*' ! -name 'skip*' | head -1 | grep -q .; then
                programs+=("$dirname")
            fi
        fi
    done
    
    # Sort programs (except system which stays first)
    local sorted_programs=("system")
    local other_programs=()
    for prog in "${programs[@]}"; do
        [[ "$prog" != "system" ]] && other_programs+=("$prog")
    done
    
    # Sort the other programs
    IFS=$'\n' other_programs=($(sort <<<"${other_programs[*]}"))
    
    # Combine system + sorted others
    programs=("${sorted_programs[@]}" "${other_programs[@]}")
    
    printf '%s\n' "${programs[@]}"
}

# Function to show program menu
show_program_menu() {
    echo -e "${GREEN}Dotfiles Editor - Select Program${NC}"
    echo "Choose a program/category:"
    echo
    
    # Get programs dynamically
    local programs=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && programs+=("$line")
    done < <(discover_programs)
    
    # Display program menu
    for ((i=0; i<${#programs[@]}; i++)); do
        local prog="${programs[$i]}"
        printf "%3d) %s\n" $((i+1)) "$prog"
    done
    
    echo
    printf "Enter program number (1-%d) or 'q' to quit: " "${#programs[@]}"
    read choice
    
    # Handle quit
    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "Exiting..."
        exit 0
    fi
    
    # Validate choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#programs[@]} )); then
        echo "Invalid choice. Please enter a number between 1 and ${#programs[@]}."
        show_program_menu
        return
    fi
    
    # Get selected program
    local selected_program="${programs[$((choice-1))]}"
    show_file_menu "$selected_program"
}

# Function to get files for a program
get_program_files() {
    local program="$1"
    local files=()
    
    case "$program" in
        "system")
            files=(
                "README.md"
                "git/.gitconfig"
                "tmux/.tmux.conf"
            )
            ;;
        "zsh")
            files=(
                "zsh/.zprofile"
                "zsh/.zshenv"
                "zsh/.zshrc"
                "zsh/aliases.zsh"
                "zsh/functions/claudeSaveSession.sh"
            )
            ;;
        "claude")
            files=(
                "claude/claude_desktop_config.json"
            )
            ;;
        "hammerspoon")
            files=(
                "hammerspoon/init.lua"
                "hammerspoon/Hammerflow/init.lua"
                "hammerspoon/Hammerflow/RecursiveBinder/init.lua"
                "hammerspoon/Hammerflow/config.toml"
            )
            ;;
        *)
            # For other programs, scan the directory
            if [[ -d "$REPOPATH/$program" ]]; then
                cd "$REPOPATH/$program" || return
                while IFS= read -r -d '' file; do
                    local relpath=${file#./}
                    [[ $relpath == .* || $relpath == skip* ]] && continue
                    files+=("$program/$relpath")
                done < <(find . -type f -print0)
                cd - > /dev/null
            fi
            ;;
    esac
    
    printf '%s\n' "${files[@]}"
}

# Function to show file menu for a specific program
show_file_menu() {
    local program="$1"
    
    echo
    echo -e "${GREEN}Dotfiles Editor - $program files${NC}"
    echo "Choose a file to edit:"
    echo
    
    # Get files for this program
    local files=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && files+=("$line")
    done < <(get_program_files "$program")
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No files found for $program"
        echo
        printf "Press 'b' for back or 'q' to quit: "
        read choice
        
        if [[ "$choice" == "b" || "$choice" == "B" ]]; then
            show_program_menu
        else
            echo "Exiting..."
            exit 0
        fi
        return
    fi
    
    # Display file menu
    for ((i=0; i<${#files[@]}; i++)); do
        local file="${files[$i]}"
        local full_path="$REPOPATH/$file"
        
        # Check if file exists
        if [[ -f "$full_path" ]]; then
            printf "%3d) %s\n" $((i+1)) "$(basename "$file")"
        else
            printf "%3d) %s ${BLUE}(missing)${NC}\n" $((i+1)) "$(basename "$file")"
        fi
    done
    
    echo
    printf "Enter file number (1-%d), 'b' for back, or 'q' to quit: " "${#files[@]}"
    read choice
    
    # Handle back
    if [[ "$choice" == "b" || "$choice" == "B" ]]; then
        show_program_menu
        return
    fi
    
    # Handle quit
    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "Exiting..."
        exit 0
    fi
    
    # Validate choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#files[@]} )); then
        echo "Invalid choice. Please enter a number between 1 and ${#files[@]}."
        show_file_menu "$program"
        return
    fi
    
    # Get selected file
    local selected_file="${files[$((choice-1))]}"
    local full_path="$REPOPATH/$selected_file"
    
    # Check if file exists
    if [[ ! -f "$full_path" ]]; then
        echo -e "${BLUE}File doesn't exist yet. Create it? [y/N]:${NC} "
        read create_file
        if [[ ! "$create_file" =~ ^[Yy] ]]; then
            show_file_menu "$program"
            return
        fi
        
        # Create directory if needed
        mkdir -p "$(dirname "$full_path")"
        touch "$full_path"
    fi
    
    # Open in nvim
    echo -e "${GREEN}Opening:${NC} $selected_file"
    nvim "$full_path"
}

# Main script entry point
show_program_menu