#!/usr/bin/env zsh

VERSION="1.2.0"
printf "Dotfiles linking script v%s\n" "$VERSION"

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
BLUE='\033[0;34m'
NC='\033[0m'

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

# Function to check if a symlink exists and points to the correct target
check_link() {
    local source=$1
    local target=$2
    
    if [[ -L "$target" ]]; then
        local current_source
        current_source=$(readlink "$target" || echo "FAILED_TO_READ")
        
        if [[ "$current_source" == "$source" ]]; then
            printf "${GREEN}✓ Linked:${NC} %s → %s\n" "$target" "$source"
            return 0
        else
            printf "${YELLOW}⚠ Incorrect link:${NC} %s → %s (should be → %s)\n" "$target" "$current_source" "$source"
            return 1
        fi
    else
        if [[ -e "$target" ]]; then
            printf "${RED}✗ Exists but not a link:${NC} %s\n" "$target"
            return 2
        else
            [[ $VERBOSE == true ]] && printf "No link exists at %s\n" "$target"
            return 3
        fi
    fi
}

# Function to handle linking a single file
link_file() {
    local source=$1
    local target=$2
    
    [[ $VERBOSE == true ]] && printf "Processing: %s → %s\n" "$source" "$target"
    
    if [[ ! -f "$source" ]]; then
        printf "${RED}✗ Source file not found:${NC} %s\n" "$source"
        return 1
    fi
    
    # Check current link status
    check_link "$source" "$target"
    local link_status=$?
    
    if [[ $link_status != 0 ]]; then
        if [[ $CHECK_ONLY == true ]]; then
            return 0
        fi
        
        if [[ $DRY_RUN == true ]]; then
            printf "Would create link: %s → %s\n" "$target" "$source"
            return 0
        fi
        
        mkdir -p "$(dirname "$target")"
        
        if [[ -e "$target" ]]; then
            backup_file "$target"
        fi
        
        if ln -svf "$source" "$target"; then
            printf "${GREEN}✓ Created link:${NC} %s → %s\n" "$target" "$source"
            return 0
        else
            printf "${RED}✗ Failed to create link:${NC} %s → %s\n" "$target" "$source"
            return 1
        fi
    fi
}

# Function to setup config directories
setup_config_dirs() {
    local programs=("$@")
    for prog in "${programs[@]}"; do
        printf "\nChecking configuration for ${GREEN}%s${NC}\n" "$prog"
        
        local prog_dir="$REPOPATH/$prog"
        [[ ! -d "$prog_dir" ]] && {
            printf "${RED}✗ Program directory not found:${NC} %s\n" "$prog_dir"
            continue
        }
        
        for file in "$prog_dir"/*(.N); do
            local basename=$(basename "$file")
            [[ "$basename" == .* ]] && continue
            
            local target_path="$CONFIGPATH/$prog/$basename"
            link_file "$file" "$target_path"
        done
    done
}

# Link home directory files
printf "\nLinking home directory files\n"
link_file "$REPOPATH/zsh/.zprofile" ~/.zprofile
link_file "$REPOPATH/zsh/.zshenv" ~/.zshenv
link_file "$REPOPATH/zsh/.zshrc" ~/.zshrc
link_file "$REPOPATH/git/.gitconfig" ~/.gitconfig
link_file "$REPOPATH/tmux/.tmux.conf" ~/.tmux.conf
link_file "$REPOPATH/README.md" ~/.README.md

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

# Setup all config directories
setup_config_dirs "${programs[@]}"

if [[ $CHECK_ONLY == true ]]; then
    printf "\n${GREEN}Check complete.${NC} Use without --check to create/update symlinks.\n"
fi