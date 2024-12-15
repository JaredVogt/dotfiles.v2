#!/usr/bin/env zsh

# Parse command line arguments
DRY_RUN=false
if [[ $1 == "--dry-run" || $1 == "-n" ]]; then
    DRY_RUN=true
    echo "Dry run mode - no changes will be made"
fi

# Define base paths
REPOPATH=~/projects/dotfiles.v2
CONFIGPATH=~/.config

# Function to run or simulate commands
run_cmd() {
    if [[ $DRY_RUN == true ]]; then
        echo "would run: $@"
    else
        "$@"
    fi
}

# Link home directory files
run_cmd ln -sfv $REPOPATH/zsh/.zprofile ~/.
run_cmd ln -sfv $REPOPATH/zsh/.zshenv ~/.
run_cmd ln -sfv $REPOPATH/zsh/.zshrc ~/.
run_cmd ln -sfv $REPOPATH/git/.gitconfig ~/.
run_cmd ln -sfv $REPOPATH/tmux/.tmux.conf ~/.
run_cmd ln -sfv $REPOPATH/README.md ~/.

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
)

# Function to setup config directories and symlinks
setup_config_dirs() {
    local programs=($@)
    for prog in $programs; do
        # Create main config directory
        run_cmd mkdir -p $CONFIGPATH/$prog
        
        # Find all subdirectories relative to the program directory
        cd $REPOPATH/$prog
        for dir in $(find . -type d); do
            # Skip current directory
            [[ $dir == "." ]] && continue
            # Remove ./ prefix if present
            dir=${dir#./}
            # Create the corresponding directory in config
            run_cmd mkdir -p $CONFIGPATH/$prog/$dir
        done

        # Link all files from current directory
        for file in $(find . -type f); do
            # Remove ./ prefix if present
            local relpath=${file#./}
            # Skip files that start with . or skip
            [[ $relpath == .* || $relpath == skip* ]] && continue
            # Get the directory part of the relative path
            local reldir=$(dirname $relpath)
            # If in root directory, use the program config dir directly
            if [[ $reldir == "." ]]; then
                run_cmd ln -sfv $REPOPATH/$prog/$relpath $CONFIGPATH/$prog/.
            else
                run_cmd ln -sfv $REPOPATH/$prog/$relpath $CONFIGPATH/$prog/$reldir/.
            fi
        done
        cd - > /dev/null
    done
}

# Setup all config directories
setup_config_dirs $programs
