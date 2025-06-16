-- Inyo Usage Examples

-- Load Inyo
local inyo = dofile(hs.configdir .. "/Inyo/init.lua")

-- Initialize and start the HTTP server
inyo:init():start()

-- Example 1: Simple text message
inyo:show("Hello from Inyo!", {
    background = "#1a1a2e",
    style = {
        ["font-size"] = "36px",
        ["color"] = "#00ff00"
    }
})

-- Example 1b: Using templates
-- inyo:show("<h1>System Alert</h1><p>Using jellyfish template</p>", {template = "jellyfish"})
-- inyo:show("<h1>Warning!</h1>", {template = "alert"})
-- inyo:show("<h1>Neon Style</h1>", {template = "neon"})
-- inyo:show("<h1>Clean Message</h1>", {template = "minimal"})

-- Example 2: Message with GIF background
-- inyo:show("<h1>Animated Background</h1>", {
--     background = "https://media.giphy.com/media/xT9IgzoKnwFNmISR8I/giphy.gif",
--     duration = 5  -- Auto-dismiss after 5 seconds
-- })

-- Example 3: Load matrix effect
-- local matrixHTML = io.open(hs.configdir .. "/Inyo/examples/matrix.html"):read("*a")
-- inyo:show(matrixHTML)

-- Example 4: Load particle effect
-- local particlesHTML = io.open(hs.configdir .. "/Inyo/examples/particles.html"):read("*a")
-- inyo:show(particlesHTML)

-- Example 5: Using HTTP API (curl from terminal)
-- curl -X POST http://localhost:8888/message \
--   -H "Content-Type: application/json" \
--   -d '{"content": "<h1>Hello via HTTP!</h1>", "background": "linear-gradient(45deg, #ff006e, #8338ec)", "duration": 3}'

-- Example 6: Using URL event (from terminal)
-- open "hammerspoon://inyo?message=Hello%20from%20URL&background=%23ff006e"

-- Example 7: Queue multiple messages
-- inyo:queue("<h1>Message 1</h1>", { background = "#ff006e", duration = 2 })
-- inyo:queue("<h1>Message 2</h1>", { background = "#8338ec", duration = 2 })
-- inyo:queue("<h1>Message 3</h1>", { background = "#3a86ff", duration = 2 })

-- Example 8: Custom positioned message
-- inyo:configure({
--     position = { x = 100, y = 100 },
--     size = { w = 400, h = 300 }
-- })
-- inyo:show("Custom position!")

-- Example 9: AppleScript integration
-- From terminal: osascript -e 'tell application "Hammerspoon" to execute lua code "spoon.Inyo:show(\"Hello from AppleScript!\")"'

return inyo