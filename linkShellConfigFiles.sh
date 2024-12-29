#!/usr/bin/env zsh

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
CHECK_ONLY=false
VERBOSE=false

for arg in "$@"; do
    case $arg in
        --dry-run|-n)
            DRY_RUN=true
            printf "Dry run mode - no changes will be made\n"
            ;;
        --check|-c)
            CHECK_ONLY=true
            printf "Check mode - only reporting link status\n"
            ;;
        --verbose|-v)
            VERBOSE=true
            printf "Verbose mode enabled\n"
            ;;
    esac
done

# Define base paths
REPOPATH=~/projects/dotfiles.v2
CONFIGPATH=~/.config

[[ ! -d "$REPOPATH" ]] && { printf "Error: %s not found\n" "$REPOPATH"; exit 1; }

# Colors for status output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BRIGHT_RED='\033[1;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a symlink exists and points to the correct target
check_link() {
    local target=$1
    local link=$2
    
    if [[ -L "$link" ]]; then
        local current_target=$(readlink "$link")
        if [[ "$current_target" == "$target" ]]; then
            printf "${GREEN}✓ Linked:${NC} %s → %s\n" "$link" "$target"
            return 0
        else
            printf "${YELLOW}⚠ Incorrect link:${NC} %s → %s (should be → %s)\n" "$link" "$current_target" "$target"
            return 1
        fi
    elif [[ -e "$link" ]]; then
        printf "${RED}✗ Exists but not a link:${NC} %s\n" "$link"
        return 2
    else
        printf "${YELLOW}? Missing link:${NC} %s\n" "$link"
        return 3
    fi
}

# Function to create backup of existing file
backup_file() {
    local file=$1
    if [[ -e "$file" && ! -L "$file" ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local dir=$(dirname "$file")
        local filename=$(basename "$file")
        local backup_name="${dir}/${timestamp}_backup_${filename}"
        
        if [[ $DRY_RUN == false && $CHECK_ONLY == false ]]; then
            cp -R "$file" "$backup_name"
            printf "${BLUE}ℹ Backup created:${NC} %s\n" "$backup_name"
        elif [[ $DRY_RUN == true ]]; then
            printf "would backup: %s → %s\n" "$file" "$backup_name"
        fi
    fi
}

# Function to run or simulate commands
run_cmd() {
    if [[ $CHECK_ONLY == true ]]; then
        return
    elif [[ $DRY_RUN == true ]]; then
        printf "would run: %s\n" "$*"
    else
        if [[ "$1" == "ln" ]]; then
            # Run ln command quietly but capture the target for new link message
            "$@" >/dev/null
            if [[ $? == 0 ]]; then
                printf "${BRIGHT_RED}✓ Linked:${NC} %s\n" "$3"
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
    
    [[ $VERBOSE == true ]] && printf "Checking link: %s → %s\n" "$link" "$target"
    
    check_link "$target" "$link"
    local link_status=$?
    
    if [[ $link_status != 0 && $CHECK_ONLY == false ]]; then
        backup_file "$link"
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
)

# Function to setup config directories and symlinks
setup_config_dirs() {
    local programs=("$@")
    for prog in "${programs[@]}"; do
        printf "\nChecking configuration for ${GREEN}%s${NC}\n" "$prog"
        
        # Create main config directory
        run_cmd mkdir -p "$CONFIGPATH/$prog"
        
        # Check if program directory exists
        if [[ ! -d "$REPOPATH/$prog" ]]; then
            printf "${RED}✗ Program directory not found:${NC} %s\n" "$REPOPATH/$prog"
            continue
        fi
        
        # Find all subdirectories relative to the program directory
        while IFS= read -r dir; do
            # Skip current directory
            [[ "$dir" == "." ]] && continue
            # Remove ./ prefix if present
            dir=${dir#./}
            # Create the corresponding directory in config
            [[ $VERBOSE == true ]] && printf "Creating directory: %s\n" "$CONFIGPATH/$prog/$dir"
            run_cmd mkdir -p "$CONFIGPATH/$prog/$dir"
        done < <(cd "$REPOPATH/$prog" && find . -type d -print0 | xargs -0)
        
        # Link all files from current directory
        while IFS= read -r file; do
            # Remove ./ prefix if present
            local relpath=${file#./}
            # Skip files that start with . or skip
            [[ "$relpath" == .* || "$relpath" == skip* ]] && continue
            
            # Get the directory part of the relative path
            local reldir=$(dirname "$relpath")
            
            # If in root directory, use the program config dir directly
            if [[ "$reldir" == "." ]]; then
                handle_link "$REPOPATH/$prog/$relpath" "$CONFIGPATH/$prog/$relpath"
            else
                handle_link "$REPOPATH/$prog/$relpath" "$CONFIGPATH/$prog/$reldir/$(basename "$relpath")"
            fi
        done < <(cd "$REPOPATH/$prog" && find . -type f -print0 | xargs -0)
    done
}

# Setup all config directories
setup_config_dirs "${programs[@]}"

if [[ $CHECK_ONLY == true ]]; then
    printf "\n${GREEN}Check complete.${NC} Use without --check to create/update symlinks.\n"
fi