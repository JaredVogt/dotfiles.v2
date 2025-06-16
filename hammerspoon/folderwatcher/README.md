# Enhanced Folder Watcher

## Overview
The enhanced folder watcher allows you to monitor multiple directories and trigger bash scripts based on file events (created, modified, deleted).

## Configuration
Edit `folderwatcher_config.toml` to define:
- Folders to watch
- Scripts to execute for each event type
- File patterns to include/exclude
- Global settings (debug, notifications, timeouts)

## Script Arguments
Scripts receive 3 arguments:
1. `$1` - Event type: "created", "modified", or "deleted"
2. `$2` - Full file path
3. `$3` - File name only

## Usage in Hammerspoon
The module is already loaded in init.lua. To manually control:
```lua
-- Reload configuration
folderwatcher.reload()

-- Check status
folderwatcher.status()

-- Stop all watchers
folderwatcher.stop()
```

## Example Scripts Created
- `~/scripts/downloads/on_created.sh` - Organizes downloads by file type
- `~/scripts/screenshots/process.sh` - Moves screenshots to dated folders
- `~/scripts/downloads/on_modified.sh` - Logs file modifications

## Adding New Watchers
1. Edit `folderwatcher_config.toml`
2. Add a new `[[watchers]]` section
3. Create your bash scripts
4. Reload Hammerspoon config

## Tips
- Use `include` filters to only process specific file types
- Set `debug = true` in settings to see detailed logs
- Scripts run asynchronously with configurable timeout
- Check Hammerspoon console for error messages