#!/bin/bash
# Handle modified files in Downloads
# Arguments: $1=event_type $2=file_path $3=file_name

FILE_PATH="$2"
FILE_NAME="$3"

# Log modification
echo "[$(date)] File modified: $FILE_NAME" >> ~/.hammerspoon/logs/folderwatcher.log

# Example: Check if download is complete (file size stable)
# Could implement logic to wait for file size to stabilize
# then trigger processing