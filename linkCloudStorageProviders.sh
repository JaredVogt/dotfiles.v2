#!/usr/bin/env bash

VERSION="1.0.0"

print_version() {
    echo "Cloud Storage Symlink Creation Script - Version $VERSION"
}

create_symlink() {
    local source_path="$1"
    local symlink_path="$2"
    
    if [ ! -d "$source_path" ]; then
        echo "Error: Source directory does not exist - $source_path"
        return 1
    fi
    
    if [ -L "$symlink_path" ] || [ -f "$symlink_path" ] || [ -d "$symlink_path" ]; then
        rm -f "$symlink_path"
    fi
    
    ln -sfv "$source_path" "$symlink_path"
}

# Print version information
print_version

BASE_PATH="$HOME/Library/CloudStorage"

create_symlink "$BASE_PATH/Dropbox" "$HOME/Dropbox"
create_symlink "$BASE_PATH/GoogleDrive-Jared@wolffaudio.com" "$HOME/gd_wolff"
create_symlink "$BASE_PATH/GoogleDrive-jared.vogt@gmail.com" "$HOME/gd_jrv"

echo "Symlink creation complete. Please verify paths are correct."