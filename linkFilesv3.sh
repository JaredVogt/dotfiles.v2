#!/usr/bin/env zsh

# Define base paths and colors first
REPOPATH=~/projects/dotfiles.v2
CONFIGPATH=~/.config

# Colors for status output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BRIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

# Parse command line arguments
DRY_RUN=false
CHECK_ONLY=false
HEADLESS=false

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Manages symbolic links for dotfiles configuration across various programs.

OPTIONS:
    --dry-run, -n     Show what would be done without making changes
    --check, -c       Only check link status, don't create/update links
    --headless        Execute all links without prompting (default if options given)
    --help, -h        Show this help message

DESCRIPTION:
    This script creates symbolic links from the dotfiles repository to their
    proper configuration locations:
    
    • Home directory files: .zprofile, .zshenv, .zshrc, .gitconfig, .tmux.conf
    • Config directory programs: fish, atuin, starship, wezterm, karabiner,
      nushell, vimium, yazi, kitty, ghostty, helix, popclip

    The script will create necessary directories and skip files that start
    with '.' or 'skip'.

EXAMPLES:
    $0                 # Show interactive menu
    $0 --headless      # Create/update all symlinks without prompting
    $0 --check         # Only check current link status
    $0 --dry-run       # Show what would be done
EOF
}

# Function to check if a symlink exists and points to the correct target
check_link() {
    local target=$1
    local link=$2
    
    if [[ -L "$link" ]]; then
        local current_target=$(readlink "$link")
        if [[ "$current_target" == "$target" ]]; then
            echo -e "${GREEN}✓ Linked:${NC} $link → $target"
            return 0
        else
            echo -e "${YELLOW}⚠ Incorrect link:${NC} $link → $current_target (should be → $target)"
            return 1
        fi
    elif [[ -e "$link" ]]; then
        echo -e "${RED}✗ Exists but not a link:${NC} $link"
        return 2
    else
        echo -e "${YELLOW}? Missing link:${NC} $link"
        return 3
    fi
}

# Function to run or simulate commands
run_cmd() {
    if [[ $CHECK_ONLY == true ]]; then
        return 0
    elif [[ $DRY_RUN == true ]]; then
        echo "would run: $@"
        return 0
    else
        if [[ "$1" == "ln" ]]; then
            # Run ln command quietly but capture the target for new link message
            if "$@" >/dev/null 2>&1; then
                echo -e "${BRIGHT_RED}✓ Linked:${NC} $3"
                return 0
            else
                echo -e "${RED}✗ Failed to link:${NC} $3"
                return 1
            fi
        else
            # Run other commands (like mkdir) silently
            if ! "$@" >/dev/null 2>&1; then
                echo -e "${RED}✗ Failed command:${NC} $@" >&2
                return 1
            fi
            return 0
        fi
    fi
}

# Function to handle linking with status check
handle_link() {
    local target=$1
    local link=$2
    
    # Validate inputs
    if [[ -z "$target" || -z "$link" ]]; then
        echo -e "${RED}✗ Error: Missing target or link path${NC}" >&2
        return 1
    fi
    
    # Check if target exists
    if [[ ! -e "$target" ]]; then
        echo -e "${RED}✗ Target does not exist:${NC} $target"
        return 1
    fi
    
    check_link "$target" "$link"
    local link_status=$?
    
    if [[ $link_status != 0 && $CHECK_ONLY == false ]]; then
        # Handle existing non-link files interactively
        if [[ $link_status == 2 ]]; then
            handle_existing_file "$target" "$link"
            return $?
        fi
        
        # Ensure parent directory exists
        local link_dir=$(dirname "$link")
        if [[ ! -d "$link_dir" ]]; then
            run_cmd mkdir -p "$link_dir"
        fi
        
        run_cmd ln -sfv "$target" "$link"
    fi
}

# Function to handle existing non-link files interactively
handle_existing_file() {
    local target=$1
    local link=$2
    
    echo -e "\n${YELLOW}⚠ File exists but is not a symlink:${NC} $link"
    
    # Check if files are the same
    if cmp -s "$target" "$link" 2>/dev/null; then
        echo -e "${GREEN}✓ Files are identical${NC}"
    else
        echo -e "${YELLOW}⚠ Files differ${NC}"
        if command -v diff >/dev/null 2>&1; then
            echo -e "${YELLOW}Comparing:${NC}"
            echo -e "  ${GREEN}Dotfiles version:${NC} $target"
            echo -e "  ${RED}Current file:${NC} $link"
            echo
            # Use colordiff if available, otherwise fall back to diff
            local diff_cmd="diff"
            if command -v colordiff >/dev/null 2>&1; then
                diff_cmd="colordiff"
            fi
            
            local diff_output=$($diff_cmd "$link" "$target")
            local diff_lines=$(echo "$diff_output" | wc -l)
            
            if [[ $diff_lines -le 20 ]]; then
                echo -e "${YELLOW}All differences:${NC}"
                echo "$diff_output"
            else
                echo -e "${YELLOW}Differences (first 20 lines):${NC}"
                echo "$diff_output" | head -20
                echo -e "${YELLOW}... ($((diff_lines - 20)) more lines)${NC}"
                echo
                printf "Show all differences? [y/N]: "
                read show_all
                if [[ $show_all =~ ^[Yy] ]]; then
                    echo -e "${YELLOW}Complete diff:${NC}"
                    echo "$diff_output"
                fi
            fi
        fi
    fi
    
    echo
    echo "What would you like to do?"
    echo "1) Create link (overwrite existing file)"
    echo "2) Backup existing file and create link"
    echo "3) Skip this file"
    echo "4) Overwrite dotfiles version with existing file, then create link"
    echo
    printf "Choose option [1-4]: "
    read choice
    
    case $choice in
        1)
            echo -e "${YELLOW}Overwriting existing file...${NC}"
            # Ensure parent directory exists
            local link_dir=$(dirname "$link")
            if [[ ! -d "$link_dir" ]]; then
                run_cmd mkdir -p "$link_dir"
            fi
            run_cmd ln -sfv "$target" "$link"
            return $?
            ;;
        2)
            echo -e "${YELLOW}Backing up existing file...${NC}"
            local backup_file="$target.bak"
            if cp "$link" "$backup_file" 2>/dev/null; then
                echo -e "${GREEN}✓ Backed up to:${NC} $backup_file"
                # Ensure parent directory exists
                local link_dir=$(dirname "$link")
                if [[ ! -d "$link_dir" ]]; then
                    run_cmd mkdir -p "$link_dir"
                fi
                run_cmd ln -sfv "$target" "$link"
                return $?
            else
                echo -e "${RED}✗ Failed to backup file${NC}"
                return 1
            fi
            ;;
        3)
            echo -e "${YELLOW}Skipping file${NC}"
            return 2
            ;;
        4)
            echo -e "${YELLOW}Backing up dotfiles version and overwriting with existing file...${NC}"
            local backup_dotfiles="$target.bak"
            if cp "$target" "$backup_dotfiles" 2>/dev/null; then
                echo -e "${GREEN}✓ Backed up dotfiles version to:${NC} $backup_dotfiles"
                if cp "$link" "$target" 2>/dev/null; then
                    echo -e "${GREEN}✓ Overwrote dotfiles version with existing file${NC}"
                    # Ensure parent directory exists
                    local link_dir=$(dirname "$link")
                    if [[ ! -d "$link_dir" ]]; then
                        run_cmd mkdir -p "$link_dir"
                    fi
                    run_cmd ln -sfv "$target" "$link"
                    return $?
                else
                    echo -e "${RED}✗ Failed to overwrite dotfiles version${NC}"
                    return 1
                fi
            else
                echo -e "${RED}✗ Failed to backup dotfiles version${NC}"
                return 1
            fi
            ;;
        *)
            echo "Invalid choice. Skipping file."
            return 2
            ;;
    esac
}

# Function to setup custom links
setup_custom_links() {
    echo -e "\n${GREEN}Setting up Custom Links${NC}"
    
    handle_link "$REPOPATH/zsh/.zprofile" ~/.zprofile
    handle_link "$REPOPATH/zsh/.zshenv" ~/.zshenv
    handle_link "$REPOPATH/zsh/.zshrc" ~/.zshrc
    handle_link "$REPOPATH/git/.gitconfig" ~/.gitconfig
    handle_link "$REPOPATH/tmux/.tmux.conf" ~/.tmux.conf
    handle_link "$REPOPATH/README.md" ~/.README.md
    
    # Hammerspoon configuration links
    handle_link "$REPOPATH/hammerspoon/init.lua" ~/.hammerspoon/init.lua
    handle_link "$REPOPATH/hammerspoon/folderwatcher" ~/.hammerspoon/folderwatcher
    handle_link "$REPOPATH/hammerspoon/Hammerflow/init.lua" ~/.hammerspoon/Spoons/Hammerflow.spoon/init.lua
    handle_link "$REPOPATH/hammerspoon/Hammerflow/RecursiveBinder/init.lua" ~/.hammerspoon/Spoons/Hammerflow.spoon/Spoons/RecursiveBinder.spoon/init.lua
    handle_link "$REPOPATH/hammerspoon/Hammerflow/config.toml" ~/.hammerspoon/Spoons/Hammerflow.spoon/config.toml
    handle_link "$REPOPATH/hammerspoon/Hammerflow/toml_validator.lua" ~/.hammerspoon/Spoons/Hammerflow.spoon/toml_validator.lua
}

# Function to setup Application Support directory
setup_application_support() {
    echo -e "\n${GREEN}Setting up Application Support (~/Library/Application Support/)${NC}"
    
    handle_link "$REPOPATH/claude/claude_desktop_config.json" ~/Library/Application\ Support/Claude/claude_desktop_config.json
    handle_link "$REPOPATH/claude/CLAUDE.md" ~/.claude/CLAUDE.md
}

# Function to setup config directories and symlinks
setup_config_directory() {
    echo -e "\n${GREEN}Setting up Config Directory (~/.config/)${NC}"
    
    local programs=(
        zsh
        fish
        atuin
        starship
        wezterm
        karabiner
        nushell
        vimium
        yazi
        kitty
        ghostty
        helix
        popclip
    )
    
    for prog in "${programs[@]}"; do
        echo -e "\nChecking configuration for ${GREEN}$prog${NC}"
        
        # Create main config directory
        run_cmd mkdir -p "$CONFIGPATH/$prog"
        
        # Check if program directory exists
        if [[ ! -d "$REPOPATH/$prog" ]]; then
            echo -e "${RED}✗ Program directory not found:${NC} $REPOPATH/$prog"
            continue
        fi
        
        # Find all subdirectories relative to the program directory
        cd "$REPOPATH/$prog" || {
            echo -e "${RED}✗ Cannot access directory:${NC} $REPOPATH/$prog"
            continue
        }
        
        for dir in $(find . -type d); do
            # Skip current directory
            [[ $dir == "." ]] && continue
            # Remove ./ prefix if present
            dir=${dir#./}
            # Create the corresponding directory in config
            run_cmd mkdir -p "$CONFIGPATH/$prog/$dir"
        done
        
        # Link all files from current directory
        local files=()
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find . -type f -print0)
        
        for file in "${files[@]}"; do
            # Remove ./ prefix if present
            local relpath=${file#./}
            # Skip files that start with . or skip
            [[ $relpath == .* || $relpath == skip* ]] && continue
            
            # Get the directory part of the relative path
            local reldir=$(dirname "$relpath")
            
            # Verify source file exists
            if [[ ! -f "$REPOPATH/$prog/$relpath" ]]; then
                echo -e "${RED}✗ Source file not found:${NC} $REPOPATH/$prog/$relpath"
                continue
            fi
            
            # If in root directory, use the program config dir directly
            if [[ $reldir == "." ]]; then
                handle_link "$REPOPATH/$prog/$relpath" "$CONFIGPATH/$prog/$relpath"
            else
                handle_link "$REPOPATH/$prog/$relpath" "$CONFIGPATH/$prog/$reldir/$(basename "$relpath")"
            fi
        done
        cd - > /dev/null || echo -e "${RED}✗ Warning: Could not return to previous directory${NC}" >&2
    done
}

# Main execution function
run_dotfiles_setup() {
    setup_custom_links
    setup_application_support
    setup_config_directory

    # Summary
    if [[ $CHECK_ONLY == true ]]; then
        echo -e "\n${GREEN}Check complete.${NC} Use without --check to create/update symlinks."
    elif [[ $DRY_RUN == true ]]; then
        echo -e "\n${GREEN}Dry run complete.${NC} No changes were made."
    else
        echo -e "\n${GREEN}Dotfiles linking complete!${NC}"
    fi
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run|-n)
            DRY_RUN=true
            ;;
        --check|-c)
            CHECK_ONLY=true
            ;;
        --headless)
            HEADLESS=true
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Show interactive menu if no options were given
if [[ $# -eq 0 ]]; then
    while true; do
        echo -e "${GREEN}Dotfiles Link Manager${NC}"
        echo "========================"
        echo "1) Create/update all symlinks"
        echo "2) Check link status only"
        echo "3) Dry run (show what would be done)"
        echo "4) Show help"
        echo "5) Exit"
        echo
        printf "Choose an option [1-5]: "
        read choice
        
        case $choice in
            1)
                HEADLESS=true
                run_dotfiles_setup
                exit 0
                ;;
            2)
                CHECK_ONLY=true
                run_dotfiles_setup
                exit 0
                ;;
            3)
                DRY_RUN=true
                echo "Dry run mode - no changes will be made"
                run_dotfiles_setup
                DRY_RUN=false
                echo
                ;;
            4)
                show_help
                echo
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose 1-5."
                echo
                ;;
        esac
    done
else
    # Command line mode - run once
    run_dotfiles_setup
fi