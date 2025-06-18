# Inyo - Dynamic Message Display for Hammerspoon

Inyo is a Hammerspoon module that displays rich, dynamic messages in a webview container. It supports everything from simple text notifications to complex interactive visualizations with animated backgrounds.

## Features

- 🎨 Rich HTML/CSS/JavaScript content
- 🌈 Animated GIF backgrounds
- ✨ Built-in templates (jellyfish, neon, alert, minimal, matrix, particles, waves)
- 🔌 Multiple input methods (HTTP API, URL events, AppleScript, Lua)
- 📦 Message queueing
- ⌨️ Keyboard shortcuts (ESC to dismiss)
- 🎯 Customizable positioning and styling
- 🎭 Template system with custom styling overrides

## Installation

1. Copy the `Inyo.spoon` folder to your Hammerspoon Spoons directory:
   ```bash
   cp -r Inyo.spoon ~/.hammerspoon/Spoons/
   ```

2. Add to your `init.lua`:
   ```lua
   hs.loadSpoon("Inyo")
   spoon.Inyo:init():start()
   ```

3. Reload Hammerspoon configuration

## Usage

### Using Templates

```lua
-- Jellyfish animation (p5.js powered)
spoon.Inyo:show("<h1>System Alert</h1><p>Beautiful animation!</p>", {template = "jellyfish"})

-- Neon glow effect
spoon.Inyo:show("<h1>NEON</h1>", {template = "neon"})

-- Alert style with pulsing animation
spoon.Inyo:show("<h1>⚠️ Warning!</h1>", {template = "alert"})

-- Clean minimal style
spoon.Inyo:show("<h1>Simple Message</h1>", {template = "minimal"})

-- Override template styles
spoon.Inyo:show("<h1>Custom Styled</h1>", {
    template = "jellyfish",
    style = {
        ["font-size"] = "48px",
        ["color"] = "yellow"
    }
})
```

### Simple Text Message

```lua
spoon.Inyo:show("Hello World!", {
    background = "#1a1a2e",
    style = {
        ["font-size"] = "36px",
        ["color"] = "#00ff00"
    }
})
```

### Message with GIF Background

```lua
spoon.Inyo:show("<h1>Animated!</h1>", {
    background = "path/to/animation.gif",
    duration = 5  -- Auto-dismiss after 5 seconds
})
```

### HTTP API

Send messages via HTTP POST:

```bash
curl -X POST http://localhost:8888/message \
  -H "Content-Type: application/json" \
  -d '{
    "content": "<h1>Hello via HTTP!</h1>",
    "background": "linear-gradient(45deg, #ff006e, #8338ec)",
    "duration": 3
  }'
```

### URL Events

Open URLs to trigger messages:

```bash
open "hammerspoon://inyo?message=Hello%20from%20URL&background=%23ff006e"
```

### AppleScript

```applescript
tell application "Hammerspoon"
    execute lua code "spoon.Inyo:show(\"Hello from AppleScript!\")"
end tell
```

### Message Queue

Queue multiple messages:

```lua
spoon.Inyo:queue("<h1>Message 1</h1>", { background = "#ff006e", duration = 2 })
spoon.Inyo:queue("<h1>Message 2</h1>", { background = "#8338ec", duration = 2 })
spoon.Inyo:queue("<h1>Message 3</h1>", { background = "#3a86ff", duration = 2 })
```

## Configuration

```lua
spoon.Inyo:configure({
    port = 8888,              -- HTTP server port
    defaultDuration = nil,    -- nil = manual dismiss only
    position = "center",      -- "center", "top", "bottom", or {x=, y=}
    size = { w = 600, h = 400 },
    opacity = 0.95,
    animationDuration = 300   -- milliseconds
})
```

## Built-in Templates

- **jellyfish** - p5.js animated jellyfish with customized size (1560x1040) and opacity (0.85)
- **neon** - Glowing cyan text effect on black background
- **alert** - Red gradient background with pulsing white glass-morphism container
- **minimal** - Clean white background with subtle slide-in animation
- **matrix** - Matrix rain effect (from examples)
- **particles** - Interactive particle system that responds to mouse
- **waves** - Animated gradient waves

## Register Custom Templates

```lua
-- Register a custom template
spoon.Inyo:registerTemplate("mytemplate", [[
<!DOCTYPE html>
<html>
<head>
    <style>
        #content-layer {
            /* your styles */
            {{CUSTOM_STYLE}}
        }
    </style>
</head>
<body>
    <div id="content-layer">{{CONTENT}}</div>
</body>
</html>
]])

-- Use your custom template
spoon.Inyo:show("Hello!", {template = "mytemplate"})
```

## API Reference

### Methods

- `spoon.Inyo:show(content, options)` - Display a message
- `spoon.Inyo:dismiss()` - Dismiss current message
- `spoon.Inyo:queue(content, options)` - Add message to queue
- `spoon.Inyo:configure(config)` - Update configuration
- `spoon.Inyo:registerTemplate(name, html)` - Register a custom template
- `spoon.Inyo:startServer()` - Start HTTP server
- `spoon.Inyo:stopServer()` - Stop HTTP server

### Options

- `template` - Name of built-in template to use
- `background` - Color, gradient, or GIF URL (when not using template)
- `style` - CSS properties object
- `duration` - Auto-dismiss time in seconds (nil for manual)
- `queue` - Add to queue instead of replacing (HTTP API only)
- `size` - Override window size { w = width, h = height }
- `opacity` - Override window opacity (0.0 to 1.0)

## Creating Custom Effects

Create your own HTML effects by combining HTML, CSS, and JavaScript:

```html
<style>
    /* Your custom styles */
</style>

<div id="content">
    <!-- Your content -->
</div>

<script>
    // Your JavaScript code
    // Use window.inyo.dismiss() to programmatically dismiss
    // Use window.inyo.update(content) to update content
    // Use window.inyo.setBackground(bg) to change background
</script>
```

## Tips

- Press ESC to dismiss messages
- Use `duration` for temporary notifications
- Combine with other Hammerspoon features for powerful automation
- Check `examples/` folder for inspiration

## License

MIT