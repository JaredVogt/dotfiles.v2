# Hammerspoon Custom Configuration

This directory contains a custom Hammerspoon setup with symbolic links to track key configuration files in the dotfiles repo.

## Overview

This setup tracks four key files using symbolic links:
- **init.lua**: Main Hammerspoon configuration file that loads Hammerflow
- **Hammerflow/init.lua**: Init file for the Hammerflow spoon
- **Hammerflow/RecursiveBinder/init.lua**: Init file for the RecursiveBinder component
- **config.toml**: Custom leader key mappings and settings

## File Management Strategy

Instead of managing complex backups, this setup uses symbolic links to track the essential configuration files within the dotfiles repository. The files are organized in subdirectories to mirror the Hammerspoon structure.

### Directory Structure

```
hammerspoon/
├── init.lua                     # Main Hammerspoon init
├── Hammerflow/
│   ├── init.lua                 # Hammerflow spoon init
│   ├── config.toml              # Leader key mappings
│   └── RecursiveBinder/
│       └── init.lua             # RecursiveBinder component init
└── backup_hammerflow.sh         # Backup script
```

### Files Tracked

1. **Main init.lua** (`~/.hammerspoon/init.lua`): Primary configuration file
2. **Hammerflow spoon init.lua** (`~/.hammerspoon/Spoons/Hammerflow.spoon/init.lua`): Hammerflow spoon configuration
3. **RecursiveBinder init.lua** (`~/.hammerspoon/Spoons/Hammerflow.spoon/Spoons/RecursiveBinder.spoon/init.lua`): RecursiveBinder component configuration
4. **config.toml** (`~/.hammerspoon/Spoons/Hammerflow.spoon/config.toml`): Custom key mappings configuration

### Symbolic Link Setup

Create symbolic links from the dotfiles repo to the Hammerspoon directory:

```bash
# Link main init.lua
ln -sf /Users/jaredvogt/projects/dotfiles.v2/hammerspoon/init.lua ~/.hammerspoon/init.lua

# Link Hammerflow spoon init.lua
ln -sf /Users/jaredvogt/projects/dotfiles.v2/hammerspoon/Hammerflow/init.lua ~/.hammerspoon/Spoons/Hammerflow.spoon/init.lua

# Link RecursiveBinder init.lua
ln -sf /Users/jaredvogt/projects/dotfiles.v2/hammerspoon/Hammerflow/RecursiveBinder/init.lua ~/.hammerspoon/Spoons/Hammerflow.spoon/Spoons/RecursiveBinder.spoon/init.lua

# Link config.toml
ln -sf /Users/jaredvogt/projects/dotfiles.v2/hammerspoon/Hammerflow/config.toml ~/.hammerspoon/Spoons/Hammerflow.spoon/config.toml
```

## Configuration Details

### init.lua
The main configuration file loads the Hammerflow spoon and sets up auto-reload functionality. It now looks for config files in this order:

```lua
hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
    "home.toml",
    "work.toml", 
    "Spoons/Hammerflow.spoon/config.toml"
})
```

### config.toml
Contains all custom leader key mappings including:
- Leader key configuration (`f17`)
- Application shortcuts
- URL shortcuts  
- Window management
- Custom prefixes for special actions

### Hammerflow/init.lua
Contains the main Hammerflow spoon initialization and any custom modifications.

### Hammerflow/RecursiveBinder/init.lua
Contains the RecursiveBinder component configuration and any custom modifications made to the recursive binding functionality.

## Workflow

1. **Making Changes**: Edit files in the dotfiles repo - changes are immediately reflected via symbolic links
2. **Testing**: Changes auto-reload if `auto_reload = true` in config.toml
3. **Version Control**: Use git in the dotfiles repo to track all changes

## Benefits

- **Centralized Management**: All Hammerspoon config tracked in dotfiles repo
- **Automatic Sync**: Changes immediately available via symbolic links
- **Version Control**: Full git history of configuration changes
- **Simplified Backup**: Part of overall dotfiles backup strategy
- **Clean Separation**: Only track the essential customized files

## Setup Instructions

1. Install Hammerspoon and required spoons
2. Create symbolic links as shown above
3. Reload Hammerspoon configuration
4. Verify auto-reload functionality is working

This approach provides clean version control of Hammerspoon customizations while keeping them integrated with the broader dotfiles management system.