# Hammerflow

A powerful Hammerspoon configuration framework for creating leader-key driven shortcuts and window management. Hammerflow provides an intuitive way to bind sequential key combinations to various actions including app launching, URL opening, text insertion, window management, and custom functions.

## Overview

Hammerflow consists of three main components:

1. **Main Module** (`init.lua`) - The core framework that parses TOML configuration and sets up keybindings
2. **Configuration** (`config.toml`) - TOML-based configuration defining your key mappings and actions
3. **RecursiveBinder** (`RecursiveBinder/init.lua`) - Enhanced version of the Hammerspoon RecursiveBinder spoon with grid layout and visual improvements

## Features

- **Leader Key System**: Use a dedicated key (like F17/F18) to trigger sequential key combinations
- **Visual Grid Interface**: Modern, translucent grid showing available keys and actions
- **TOML Configuration**: Human-readable configuration format with support for nested groups
- **Multiple Action Types**: Support for apps, URLs, commands, text input, window management, and more
- **Conditional Actions**: Different actions based on current application context
- **Auto-reload**: Automatically reload configuration when files change
- **Window Management**: Built-in presets and custom positioning
- **Extensible**: Support for custom Lua functions and Hammerspoon commands

## Quick Start

1. Set your leader key in `config.toml`:
   ```toml
   leader_key = "f17"  # or f18, f19, etc.
   ```

2. Add some basic shortcuts:
   ```toml
   k = "Kitty"                    # Launch Kitty terminal
   g = "https://google.com"       # Open Google
   v = ["Visual Studio Code", "VS Code"]  # Launch VS Code with custom label
   ```

3. Create groups for organization:
   ```toml
   [w]
   label = "[window]"
   h = "window:left-half"         # Move window to left half
   l = "window:right-half"        # Move window to right half
   f = "window:fullscreen"        # Toggle fullscreen
   ```

## Configuration Format

### Basic Settings

```toml
leader_key = "f17"              # Required: The leader key to start sequences
leader_key_mods = ""            # Optional: Modifiers for leader key (cmd, ctrl, alt, shift)
auto_reload = true              # Optional: Auto-reload on file changes (default: true)
toast_on_reload = true          # Optional: Show reload notification (default: false)
show_ui = true                  # Optional: Show visual interface (default: true)

# Grid layout options
max_grid_columns = 5            # Maximum columns in grid (default: 5)
grid_spacing = " | "            # Spacing between columns (default: " | ")
grid_separator = " ▸ "          # Separator between key and label (default: " : ")
```

### Action Types

#### Application Launching
```toml
k = "Kitty"                     # Launch by name
s = "Safari"
v = ["Visual Studio Code", "VS Code"]  # With custom label
```

#### URLs and Links
```toml
g = "https://google.com"
b = "https://github.com"
```

#### Commands and Scripts
```toml
z = "cmd:code ~/.zshrc"         # Run terminal command
r = "reload"                    # Special: reload Hammerspoon config
```

#### Text Input
```toml
e = "text:sam@example.com"      # Type text
i = "input:https://google.com/search?q={input}"  # Prompt for input
```

#### Keyboard Shortcuts
```toml
s = "shortcut:cmd shift 4"      # Trigger screenshot shortcut
c = "shortcut:cmd c"            # Copy
```

#### Window Management
```toml
h = "window:left-half"          # Use preset
l = "window:right-half"
c = "window:center-half"
m = "window:maximized"
f = "window:fullscreen"
s = "window:.4,.3,.2,.4"        # Custom: x,y,width,height as percentages
```

#### Code/File Opening
```toml
h = "code: ~/.hammerspoon"      # Open in VS Code
d = "code: ~/Documents"
```

#### Raycast Integration
```toml
c = "raycast://extensions/raycast/raycast/confetti"
e = "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"
```

#### Custom Hammerspoon Code
```toml
a = "hs:hs.alert('Hello, world!')"  # Run any Hammerspoon Lua code
```

#### Custom Functions
```toml
f = "function:myFunction"       # Call registered function
g = "function:myFunc|arg1|arg2" # Call with arguments
```

### Groups and Nesting

Create organized groups of actions:

```toml
[l]
label = "[links]"               # Optional group label
g = "https://github.com"
t = "https://twitter.com"

# Nested groups
[l.m]
label = "[my links]"
g = ["https://github.com/myuser", "my github"]
t = ["https://twitter.com/myuser", "my twitter"]
```

### Conditional Actions

Execute different actions based on the current application:

```toml
# Define app shortcuts in [apps] section
[apps]
browser = "safari"              # or bundle ID like "com.apple.safari"
editor = "code"

# Use conditional syntax: key_condition
c_browser = "shortcut:cmd l"    # Focus address bar in browser
c_editor = "shortcut:cmd p"     # Quick open in editor
c = "shortcut:cmd c"            # Default copy for other apps
```

The `_` condition is the fallback if no other conditions match.

## Window Management Presets

Built-in window positioning presets:

- `left-half`, `right-half`, `center-half`
- `top-half`, `bottom-half`
- `left-third`, `center-third`, `right-third`
- `first-quarter`, `second-quarter`, `third-quarter`, `fourth-quarter`
- `top-left`, `top-right`, `bottom-left`, `bottom-right`
- `maximized`, `fullscreen`

Custom positioning with percentages:
```toml
# window:x,y,width,height (all as decimals 0-1)
small = "window:.4,.3,.2,.4"    # Small centered window
wide = "window:0,.8,1,.2"       # Wide bar at bottom
```

## Custom Functions

Register custom Lua functions for advanced functionality:

```lua
-- In your Hammerspoon init.lua or other file
local hammerflow = require('Hammerflow')

local myFunctions = {
  toggleDarkMode = function()
    hs.osascript.applescript('tell app "System Events" to tell appearance preferences to set dark mode to not dark mode')
  end,
  
  openProject = function(projectName)
    os.execute("code ~/Projects/" .. projectName)
  end
}

hammerflow.registerFunctions(myFunctions)
```

Then use in your config:
```toml
d = "function:toggleDarkMode"
p = "function:openProject|my-project"
```

## File Structure

```
Hammerflow/
├── init.lua              # Main framework
├── config.toml           # Your configuration
├── RecursiveBinder/
│   └── init.lua         # Enhanced RecursiveBinder spoon
└── lib/
    └── tinytoml.lua     # TOML parser (referenced in code)
```

## Usage

1. Press your leader key (e.g., F17) to open the grid interface
2. See available keys and their actions in a visual grid
3. Press a key to execute its action or enter a submenu
4. Press Escape to cancel at any time
5. Press the leader key again while the grid is open to close it

## Advanced Features

### Auto-reload
When `auto_reload = true`, Hammerflow watches for changes to configuration files and automatically reloads, making development and tweaking very fast.

### Multiple Configuration Files
The framework can load from multiple TOML files in priority order. Modify the file loading in your main Hammerspoon config to specify which files to search for.

### Input Prompts
Use `input:` prefix to create actions that prompt for user input:
```toml
s = "input:https://google.com/search?q={input}"  # Search with prompted term
o = "input:code {input}"                         # Open file/folder in VS Code
```

### Browser-specific Fixes
The framework includes specific handling for Firefox and Zen Browser window management animations.

## Tips

- Use F17, F18, or F19 as leader keys - they're dedicated function keys that don't interfere with other shortcuts
- Organize related actions into logical groups with descriptive labels
- Use conditional actions to make the same key do different things in different apps
- Take advantage of the visual grid to discover and remember your shortcuts
- Start simple and gradually add more complex configurations as you learn

## Credits

Based on the Hammerspoon RecursiveBinder spoon with enhancements for modern UI and TOML configuration. Originally created by Sam Lewis.