#!/bin/bash
# Test script that logs all received arguments
# Used to verify folderwatcher is calling scripts correctly

EVENT_TYPE="$1"
FILE_PATH="$2"
FILE_NAME="$3"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Create results directory if it doesn't exist
RESULTS_DIR="$(dirname "$0")/../test_results"
mkdir -p "$RESULTS_DIR"

# Log to test results
echo "[$TIMESTAMP] Event: $EVENT_TYPE | Path: $FILE_PATH | Name: $FILE_NAME" >> "$RESULTS_DIR/events.log"

# Also create a marker file for each event
MARKER_NAME="${EVENT_TYPE}_${FILE_NAME//\//_}_$(date +%s).marker"
touch "$RESULTS_DIR/$MARKER_NAME"

# Exit successfully
exit 0