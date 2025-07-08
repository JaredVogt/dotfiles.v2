#!/bin/bash
# Script triggered when files are deleted from ~/Downloads
# Arguments: $1=event_type $2=file_path $3=file_name

EVENT_TYPE="$1"
FILE_PATH="$2"
FILE_NAME="$3"

# Log the event
echo "[$(date)] File deleted: $FILE_NAME" >> ~/.hammerspoon/logs/folderwatcher.log

# Example actions for deleted files (commented out - only logging active)
# case "$FILE_NAME" in
#     *.tmp|*.download)
#         # Expected deletions - no action needed
#         ;;
#     *)
#         # Log unexpected deletions
#         echo "[$(date)] WARNING: Unexpected deletion: $FILE_NAME" >> ~/.hammerspoon/logs/folderwatcher.log
#         ;;
# esac