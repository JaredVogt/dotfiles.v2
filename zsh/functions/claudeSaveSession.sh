#!/usr/bin/env bash

# Script to run Claude and save output to a specified file
# Usage: Create an alias 'cc' to this script in your .bashrc or .zshrc file
# Example: alias cc='/path/to/this/script.sh'

# Function to check if Claude CLI is installed
check_claude() {
    if ! command -v claude &> /dev/null; then
        echo "Error: Claude CLI is not installed or not in your PATH."
        echo "Please install Claude CLI first."
        exit 1
    fi
}

# Main function
main() {
    # Check if Claude is installed
    check_claude

    # Prompt for the output file name
    echo -n "Enter output file name (default: session_output.txt): "
    read filename

    # Use default if no filename is provided
    if [ -z "$filename" ]; then
        filename="session_output.txt"
    fi

    # Check if file exists and prompt for overwrite
    if [ -f "$filename" ]; then
        echo -n "File $filename already exists. Overwrite? (y/n): "
        read overwrite
        if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
            echo "Operation cancelled."
            exit 0
        fi
    fi

    # Start Claude and redirect output to the specified file
    echo "Starting Claude session. Output will be saved to $filename"
    echo "Type 'exit' or press Ctrl+D to end the session."
    echo "-------------------------------------------"

    # Run Claude and tee output to the file, preserving colors
    # Force color output with environment variable
    FORCE_COLOR=1 claude | tee "$filename"

    echo "-------------------------------------------"
    echo "Session ended. Output saved to $filename"
}

# Run the main function
main
