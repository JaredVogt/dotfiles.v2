#!/bin/bash
# Process screenshots from Desktop
# Arguments: $1=event_type $2=file_path $3=file_name

FILE_PATH="$2"
FILE_NAME="$3"

# Only process screenshots
if [[ ! "$FILE_NAME" =~ ^Screenshot.*\.png$ ]]; then
    exit 0
fi

# Create screenshots directory if needed
SCREENSHOT_DIR=~/Documents/Screenshots/$(date +%Y-%m)
mkdir -p "$SCREENSHOT_DIR"

# Generate new name with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NEW_NAME="screenshot_${TIMESTAMP}.png"

# Move and rename
mv "$FILE_PATH" "$SCREENSHOT_DIR/$NEW_NAME"

# Optional: Optimize PNG
# pngquant --quality 65-80 "$SCREENSHOT_DIR/$NEW_NAME" --output "$SCREENSHOT_DIR/$NEW_NAME" --force

echo "Moved $FILE_NAME to $SCREENSHOT_DIR/$NEW_NAME"