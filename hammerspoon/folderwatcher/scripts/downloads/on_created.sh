#!/bin/bash
# Script triggered when files are created in ~/Downloads
# Arguments: $1=event_type $2=file_path $3=file_name

EVENT_TYPE="$1"
FILE_PATH="$2"
FILE_NAME="$3"

# Log the event
echo "[$(date)] File created: $FILE_NAME" >> ~/.hammerspoon/logs/folderwatcher.log

# Example actions based on file type (commented out - only notifications active)
# case "$FILE_NAME" in
#     *.pdf)
#         # Move PDFs to Documents
#         echo "Moving PDF to Documents: $FILE_NAME"
#         mv "$FILE_PATH" ~/Documents/PDFs/
#         ;;
#     *.zip|*.tar.gz)
#         # Extract archives
#         echo "Archive detected: $FILE_NAME"
#         # Could add extraction logic here
#         ;;
#     *.png|*.jpg|*.jpeg)
#         # Process images
#         echo "Image file: $FILE_NAME"
#         # Could add image optimization here
#         ;;
# esac