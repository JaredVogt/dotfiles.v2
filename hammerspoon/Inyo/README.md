# Inyo - Dynamic Message Display for Hammerspoon

Inyo is a Hammerspoon module that displays rich, dynamic messages in a webview container. It supports everything from simple text notifications to complex interactive visualizations with animated backgrounds.

## Features

- 🎨 Rich HTML/CSS/JavaScript content
- 🌈 Animated GIF backgrounds
- ✨ Built-in animation effects (Matrix rain, particles, waves)
- 🔌 Multiple input methods (HTTP API, URL events, AppleScript, Lua)
- 📦 Message queueing
- ⌨️ Keyboard shortcuts (ESC to dismiss)
- 🎯 Customizable positioning and styling

## Installation

1. Copy the `Inyo` folder to your Hammerspoon configuration directory
2. Add to your `init.lua`:

```lua
local inyo = dofile(hs.configdir .. "/Inyo/init.lua")
inyo:init():start()
```

## Usage

### Simple Text Message

```lua
inyo:show("Hello World!", {
    background = "#1a1a2e",
    style = {
        ["font-size"] = "36px",
        ["color"] = "#00ff00"
    }
})
```

### Message with GIF Background

```lua
inyo:show("<h1>Animated!</h1>", {
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
inyo:queue("<h1>Message 1</h1>", { background = "#ff006e", duration = 2 })
inyo:queue("<h1>Message 2</h1>", { background = "#8338ec", duration = 2 })
inyo:queue("<h1>Message 3</h1>", { background = "#3a86ff", duration = 2 })
```

## Configuration

```lua
inyo:configure({
    port = 8888,              -- HTTP server port
    defaultDuration = nil,    -- nil = manual dismiss only
    position = "center",      -- "center", "top", "bottom", or {x=, y=}
    size = { w = 600, h = 400 },
    opacity = 0.95,
    animationDuration = 300   -- milliseconds
})
```

## Built-in Effects

### Matrix Rain
```lua
local matrixHTML = io.open(hs.configdir .. "/Inyo/examples/matrix.html"):read("*a")
inyo:show(matrixHTML)
```

### Interactive Particles
```lua
local particlesHTML = io.open(hs.configdir .. "/Inyo/examples/particles.html"):read("*a")
inyo:show(particlesHTML)
```

### Gradient Waves
```lua
local waveHTML = io.open(hs.configdir .. "/Inyo/examples/gradient-wave.html"):read("*a")
inyo:show(waveHTML)
```

## API Reference

### Methods

- `inyo:show(content, options)` - Display a message
- `inyo:dismiss()` - Dismiss current message
- `inyo:queue(content, options)` - Add message to queue
- `inyo:configure(config)` - Update configuration
- `inyo:startServer()` - Start HTTP server
- `inyo:stopServer()` - Stop HTTP server

### Options

- `background` - Color, gradient, or GIF URL
- `style` - CSS properties object
- `duration` - Auto-dismiss time in seconds (nil for manual)
- `queue` - Add to queue instead of replacing (HTTP API only)

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