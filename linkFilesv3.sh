#!/usr/bin/env zsh

# Parse command line arguments
DRY_RUN=false
CHECK_ONLY=false

for arg in "$@"; do
    case $arg in
        --dry-run|-n)
            DRY_RUN=true
            echo "Dry run mode - no changes will be made"
            ;;
        --check|-c)
            CHECK_ONLY=true
            echo "Check mode - only reporting link status"
            ;;
    esac
done

# Define base paths
REPOPATH=~/projects/dotfiles.v2
CONFIGPATH=~/.config

# Colors for status output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BRIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

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
        return
    elif [[ $DRY_RUN == true ]]; then
        echo "would run: $@"
    else
        if [[ "$1" == "ln" ]]; then
            # Run ln command quietly but capture the target for new link message
            "$@" >/dev/null
            if [[ $? == 0 ]]; then
                echo -e "${BRIGHT_RED}✓ Linked:${NC} $3"
            fi
        else
            # Run other commands (like mkdir) silently
            "$@" >/dev/null
        fi
    fi
}

# Function to handle linking with status check
handle_link() {
    local target=$1
    local link=$2
    
    check_link "$target" "$link"
    local link_status=$?
    
    if [[ $link_status != 0 && $CHECK_ONLY == false ]]; then
        run_cmd ln -sfv "$target" "$link"
    fi
}

# Link home directory files
handle_link "$REPOPATH/zsh/.zprofile" ~/.zprofile
handle_link "$REPOPATH/zsh/.zshenv" ~/.zshenv
handle_link "$REPOPATH/zsh/.zshrc" ~/.zshrc
handle_link "$REPOPATH/git/.gitconfig" ~/.gitconfig
handle_link "$REPOPATH/tmux/.tmux.conf" ~/.tmux.conf
handle_link "$REPOPATH/README.md" ~/.README.md

# Array of programs to setup in .config
programs=(
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
    popclips
)

# Function to setup config directories and symlinks
setup_config_dirs() {
    local programs=($@)
    for prog in $programs; do
        echo -e "\nChecking configuration for ${GREEN}$prog${NC}"
        
        # Create main config directory
        run_cmd mkdir -p "$CONFIGPATH/$prog"
        
        # Find all subdirectories relative to the program directory
        cd "$REPOPATH/$prog" 2>/dev/null || {
            echo -e "${RED}✗ Program directory not found:${NC} $REPOPATH/$prog"
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
        for file in $(find . -type f); do
            # Remove ./ prefix if present
            local relpath=${file#./}
            # Skip files that start with . or skip
            [[ $relpath == .* || $relpath == skip* ]] && continue
            
            # Get the directory part of the relative path
            local reldir=$(dirname "$relpath")
            
            # If in root directory, use the program config dir directly
            if [[ $reldir == "." ]]; then
                handle_link "$REPOPATH/$prog/$relpath" "$CONFIGPATH/$prog/$relpath"
            else
                handle_link "$REPOPATH/$prog/$relpath" "$CONFIGPATH/$prog/$reldir/$(basename "$relpath")"
            fi
        done
        cd - > /dev/null
    done
}

# Setup all config directories
setup_config_dirs $programs

if [[ $CHECK_ONLY == true ]]; then
    echo -e "\n${GREEN}Check complete.${NC} Use without --check to create/update symlinks."
fi
