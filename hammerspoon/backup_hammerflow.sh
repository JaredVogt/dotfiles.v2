#!/usr/bin/env bash

# backup_hammerflow.sh
# Backs up the Hammerflow.spoon directory from ~/.hammerspoon to the dotfiles repo

set -e  # Exit on any error

# Define paths
HAMMERSPOON_DIR="$HOME/.hammerspoon"
HAMMERFLOW_SOURCE_DIR="$HAMMERSPOON_DIR/Spoons/Hammerflow.spoon"
DOTFILES_HAMMERSPOON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_ZIP="$DOTFILES_HAMMERSPOON_DIR/Hammerflow_Current.zip"
BACKUPS_DIR="$DOTFILES_HAMMERSPOON_DIR/backups"

echo "🔨 Backing up Hammerflow.spoon..."

# Check if source directory exists
if [ ! -d "$HAMMERFLOW_SOURCE_DIR" ]; then
    echo "❌ Error: Hammerflow.spoon directory not found at $HAMMERFLOW_SOURCE_DIR"
    echo "   Make sure Hammerspoon is installed and Hammerflow.spoon is in the Spoons directory"
    exit 1
fi

# Create backups directory if it doesn't exist
mkdir -p "$BACKUPS_DIR"

# If current zip exists, create a dated backup
if [ -f "$CURRENT_ZIP" ]; then
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUPS_DIR/Hammerflow_$TIMESTAMP.zip"
    echo "📦 Moving existing backup to: $(basename "$BACKUP_FILE")"
    mv "$CURRENT_ZIP" "$BACKUP_FILE"
fi

# Create new zip backup
echo "📦 Creating new backup: Hammerflow_Current.zip"
cd "$HAMMERSPOON_DIR/Spoons"
zip -r "$CURRENT_ZIP" "Hammerflow.spoon" -x "*.DS_Store*" > /dev/null

# Verify the backup was created
if [ -f "$CURRENT_ZIP" ]; then
    SIZE=$(du -h "$CURRENT_ZIP" | cut -f1)
    echo "✅ Backup complete! Size: $SIZE"
    echo "   Location: $CURRENT_ZIP"
    
    # Show backup count
    BACKUP_COUNT=$(ls -1 "$BACKUPS_DIR"/*.zip 2>/dev/null | wc -l | tr -d ' ')
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo "   Previous backups: $BACKUP_COUNT files in backups/"
    fi
else
    echo "❌ Error: Backup failed to create"
    exit 1
fi