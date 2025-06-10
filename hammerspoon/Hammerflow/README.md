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
- **Custom Backgrounds**: Support for animated GIFs and static images with configurable opacity and positioning
- **Icon Support**: Display custom icons alongside menu items for visual identification
- **TOML Configuration**: Human-readable configuration format with support for nested groups
- **Multiple Action Types**: Support for apps, URLs, commands, text input, window management, and more
- **Conditional Actions**: Different actions based on current application context
- **Auto-reload**: Automatically reload configuration when files change
- **Window Management**: Built-in presets and custom positioning
- **Custom Sort Order**: Control display order with prefixed keys while keeping simple hotkeys
- **Display Modes**: Choose between modern webview interface or classic text display
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
   icon = "window.png"            # Optional group icon
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
display_mode = "webview"        # Optional: "webview" or "text" (default: "webview")

# Grid layout options (for webview mode)
max_grid_columns = 5            # Maximum columns in grid (default: 5)
grid_spacing = " | "            # Spacing between columns (default: " | ")
grid_separator = " ▸ "          # Separator between key and label (default: " : ")

# Background image configuration (optional)
[background]
image = "background.gif"        # Image filename in images/ directory
opacity = 0.6                  # Transparency: 0.0 (invisible) to 1.0 (opaque)
position = "center center"     # Position: "center center", "top left", "bottom right", etc.
size = "cover"                 # Size behavior: "cover", "contain", "auto", "100% 100%", "200px", etc.
```

### Key Naming Rules

- **Letters and numbers**: Can be used directly: `a`, `Z`, `1`, `9`
- **Special characters**: Must be quoted in TOML: `"/"`, `"."`, `"?"`, `";"`, `"'"`
- **Uppercase letters**: Automatically include shift modifier
- **All printable characters are supported** as shortcut keys

### Action Types

#### Application Launching
```toml
k = "Kitty"                     # Launch by name
s = "Safari"
v = ["Visual Studio Code", "VS Code"]  # With custom label
v = ["Visual Studio Code", "VS Code", "vscode.png"]  # With custom label and icon

# Special characters must be quoted
"/" = "Safari"                  # Forward slash requires quotes
"." = "Finder"                  # Period requires quotes
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

#### Deep Links and URL Schemes
```toml
# Raycast (built-in support)
c = "raycast://extensions/raycast/raycast/confetti"
e = "raycast://extensions/raycast/emoji-symbols/search-emoji-symbols"

# Linear (built-in support)  
l = "linear://wolffaudio/view/b8ff72ac-1c48-4955-9fda-74870f1d6130"

# Other app deep links - requires adding to init.lua
# See "Adding New Deep Link Support" section below
```

**Adding New Deep Link Support**

To support new URL schemes (like `notion://`, `slack://`, etc.), you need to add them to the `getActionAndLabel` function in `init.lua`:

```lua
-- In init.lua, around line 179-182, add new URL schemes:
elseif startswith(s, "notion://") then
  return open(s), s
elseif startswith(s, "slack://") then
  return open(s), s
```

Currently supported URL schemes:
- `http://` and `https://` (web URLs)
- `raycast://` (Raycast deep links)
- `linear://` (Linear app deep links)

#### Custom Hammerspoon Code
```toml
a = "hs:hs.alert('Hello, world!')"  # Run any Hammerspoon Lua code
```

#### Keyboard Maestro Macros
```toml
g = "km:Google_meet"                # Execute Keyboard Maestro macro
m = ["km:My_Macro", "Custom Label"] # With custom label
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
icon = "links.png"              # Optional group icon
g = "https://github.com"
t = "https://twitter.com"

# Nested groups
[l.m]
label = "[my links]"
icon = "personal.png"           # Icons work on nested groups too
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

## Icon Support

Hammerflow supports displaying custom icons alongside menu items for better visual identification.

### Adding Icons

Icons can be added to actions using the array format with a third parameter:

```toml
# Format: [action, label, icon_filename]
k = ["Kitty", "Terminal", "kitty.png"]
g = ["https://github.com", "GitHub", "github.png"]
c = ["code ~/.hammerspoon", "Config", "gear.png"]
```

Icons can also be added to groups using the `icon` property:

```toml
[l]
label = "[linear]"
icon = "linear.png"              # Group icon
b = ["linear://project/view/task-id", "Bryce Task", "bryce.png"]
c = ["linear://project/view/other-task", "Other Task", "task.png"]
```

### Icon Requirements

- **Location**: Place images in the `images/` directory within your Hammerflow folder
- **Size**: 48x48 pixels recommended (any size works, will be scaled to 48x48)
- **Format**: PNG recommended, JPEG also supported
- **Encoding**: Images are automatically base64-encoded for webview display

### Icon Directory Structure

```
Hammerflow/
├── init.lua
├── config.toml
├── images/              # Icon directory
│   ├── kitty.png       # Terminal icon
│   ├── github.png      # GitHub icon
│   ├── bryce.png       # Custom task icon
│   └── gear.png        # Settings icon
├── RecursiveBinder/
│   └── init.lua
└── lib/
    └── tinytoml.lua
```

## File Structure

```
Hammerflow/
├── init.lua              # Main framework
├── config.toml           # Your configuration
├── images/               # Icon directory (optional)
│   ├── app1.png         # 48x48px icons
│   └── app2.png
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

### Display Modes

Hammerflow supports two display modes for showing available shortcuts:

#### Webview Mode (default)
The modern visual interface with:
- Grid layout with customizable columns
- Visual icons support
- Click-to-execute functionality
- Translucent background with optional custom image
- Configurable spacing and separators

```toml
display_mode = "webview"  # Modern visual grid

# Background image configuration (optional)
[background]
image = "background.gif"        # Image filename in images/ directory
opacity = 0.6                  # Transparency: 0.0 (invisible) to 1.0 (opaque)
position = "center center"     # Position: "center center", "top left", "bottom right", etc.
size = "cover"                 # Size behavior options:
# "cover"     - Scale to fill container, may crop edges (good for full backgrounds)
# "contain"   - Scale to fit inside container, shows whole image (good for logos)
# "auto"      - Natural size, excess clipped outside container (good for large images)
# "100% 100%" - Stretch to fill exactly (may distort image)
# "200px"     - Fixed width, height scales proportionally
# "200px 150px" - Fixed width and height
```

#### Text Mode
The classic lightweight display with:
- Traditional text-based interface
- Fast and minimal resource usage
- Special sorting for mixed case (a, A, b, B, c, C...)
- Works in all environments
- No dependencies on webview

```toml
display_mode = "text"     # Classic text display
```

### Custom Sort Order

Control the display order of shortcuts using prefixed keys:

```toml
# Numeric prefixes for precise ordering
10_k = "Kitty"           # Displays as 'k', sorts as '10_k'
20_c = "Chrome"          # Displays as 'c', sorts as '20_c'
99_z = "reload"          # Displays as 'z', sorts last

# Alphabetic prefixes for general ordering
a_w = "window:left-half"  # Displays as 'w', sorts as 'a_w'
z_r = "reload"           # Displays as 'r', sorts as 'z_r'

# Regular keys work normally
g = "Google"             # Displays and sorts as 'g'

# Examples from config.toml:
"z_." = "reload"         # Period key, sorted to end
"y_/" = ["input:https://google.com/search?q={input}", "Search"]  # Slash key with prefix
```

This system allows complete control over the order items appear in the menu while keeping the actual hotkey simple. The prefix is stripped from the display but used for sorting. This is especially useful for organizing special characters and controlling which items appear first or last.

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