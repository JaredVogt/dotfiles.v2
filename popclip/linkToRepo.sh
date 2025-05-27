#!/usr/bin/env bash
# Minimal script to symlink from ~/projects/popclips to current directory

SOURCE="$HOME/projects/popclips"
TARGET="$(pwd)"

# Check if source exists
[ ! -d "$SOURCE" ] && echo "Error: $SOURCE not found!" && exit 1

# Track results
success=0
errors=0

# Create symlinks
for item in "$SOURCE"/*; do
  name=$(basename "$item")
  if [ -e "$TARGET/$name" ]; then
    echo "Skip: $name (exists)"
    ((errors++))
  elif ln -s "$item" "$TARGET/$name"; then
    echo "Linked: $name"
    ((success++))
  else
    echo "Failed: $name"
    ((errors++))
  fi
done

# Summary
echo "Created $success links ($errors errors)"
[ $errors -gt 0 ] && exit 1 || exit 0
