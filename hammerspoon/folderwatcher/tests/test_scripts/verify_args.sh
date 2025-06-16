#!/bin/bash
# Verifies that arguments are passed correctly
# Exits with error if arguments are invalid

EVENT_TYPE="$1"
FILE_PATH="$2"
FILE_NAME="$3"

RESULTS_DIR="$(dirname "$0")/../test_results"
mkdir -p "$RESULTS_DIR"

# Check number of arguments
if [ $# -ne 3 ]; then
    echo "ERROR: Expected 3 arguments, got $#" >> "$RESULTS_DIR/errors.log"
    exit 1
fi

# Verify event type is valid
case "$EVENT_TYPE" in
    created|modified|deleted)
        ;;
    *)
        echo "ERROR: Invalid event type: $EVENT_TYPE" >> "$RESULTS_DIR/errors.log"
        exit 1
        ;;
esac

# Verify file path is absolute
if [[ "$FILE_PATH" != /* ]]; then
    echo "ERROR: File path is not absolute: $FILE_PATH" >> "$RESULTS_DIR/errors.log"
    exit 1
fi

# Verify file name matches the end of file path
if [[ "$FILE_PATH" != *"$FILE_NAME" ]]; then
    echo "ERROR: File name doesn't match path end: $FILE_NAME not in $FILE_PATH" >> "$RESULTS_DIR/errors.log"
    exit 1
fi

# All checks passed
echo "PASS: Args valid - $EVENT_TYPE | $FILE_PATH | $FILE_NAME" >> "$RESULTS_DIR/verification.log"
exit 0