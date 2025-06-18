--- === Inyo ===
---
--- A dynamic webview message display module for Hammerspoon
---
--- Inyo allows you to display customizable messages, notifications, and interactive content
--- using webviews. It supports templates, animations, HTTP API, and URL events.
---
--- Download: [https://github.com/jaredvogt/inyo](https://github.com/jaredvogt/inyo)

---@diagnostic disable: undefined-global

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Inyo"
obj.version = "1.0"
obj.author = "Jared Vogt"
obj.homepage = "https://github.com/jaredvogt/inyo"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Spoon path (set by Hammerspoon when loading)
obj.spoonPath = nil

-- Internal state (will be initialized in init())
obj._webview = nil
obj._modal = nil
obj._httpServer = nil
obj._messageQueue = {}
obj._templates = {}
obj._config = {
    port = 8888,
    defaultDuration = nil,
    position = "center",
    size = { w = 600, h = 400 },
    opacity = 0.95,
    animationDuration = 300,
    clickThrough = false
}

--- Inyo.logger
--- Variable
--- Logger instance for debugging
obj.logger = hs.logger.new('Inyo')

-- Constructor (internal use)
function obj:new()
    local o = {}
    setmetatable(o, self)
    
    -- Instance state
    o._webview = nil
    o._modal = nil
    o._httpServer = nil
    o._messageQueue = {}
    o._templates = {}
    o._config = {
        port = 8888,
        defaultDuration = nil,
        position = "center",
        size = { w = 600, h = 400 },
        opacity = 0.95,
        animationDuration = 300,
        clickThrough = false  -- New option for click-through behavior
    }
    
    -- Create instance logger
    o.logger = hs.logger.new('Inyo')
    o.logger.setLogLevel('debug')
    
    -- Register built-in templates
    o:_registerBuiltInTemplates()
    
    return o
end

-- Helper functions
local function getScreenFrame()
    local screen = hs.screen.mainScreen()
    return screen:frame()
end

local function calculatePosition(size, config)
    local screenFrame = getScreenFrame()
    local x, y
    
    if config.position == "center" then
        x = screenFrame.x + (screenFrame.w - size.w) / 2
        y = screenFrame.y + (screenFrame.h - size.h) / 2
    elseif config.position == "top" then
        x = screenFrame.x + (screenFrame.w - size.w) / 2
        y = screenFrame.y + 50
    elseif config.position == "bottom" then
        x = screenFrame.x + (screenFrame.w - size.w) / 2
        y = screenFrame.y + screenFrame.h - size.h - 50
    else
        -- Custom position
        x = config.position.x or screenFrame.x
        y = config.position.y or screenFrame.y
    end
    
    return { x = x, y = y, w = size.w, h = size.h }
end

-- Load template file
local function loadTemplateFile(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

-- Get Spoon resource path
local function getResourcePath()
    -- Check if we're running as a Spoon
    if spoon and spoon.Inyo and spoon.Inyo.spoonPath then
        local path = spoon.Inyo.spoonPath
        obj.logger.d("[debug] Using Spoon path: " .. tostring(path))
        return path
    elseif hs.spoons and hs.spoons.scriptPath then
        -- Try to get the path from the script path
        local scriptPath = hs.spoons.scriptPath()
        if scriptPath and scriptPath:match("Inyo%.spoon") then
            local path = scriptPath:match("(.*/Inyo%.spoon)")
            obj.logger.d("[debug] Using script-based Spoon path: " .. tostring(path))
            return path
        end
    end
    
    -- Fallback for non-Spoon usage
    local path = hs.configdir .. "/Inyo"
    obj.logger.d("[debug] Using fallback resource path: " .. path)
    return path
end

-- Base HTML template
local function generateHTML(content, options, templates)
    options = options or {}
    local style = options.style or {}
    
    -- Check if using a template
    if options.template then
        obj.logger.d("[debug] Template requested: " .. options.template)
        if templates[options.template] then
            obj.logger.d("[debug] Template found: " .. options.template)
            local template = templates[options.template]
            
            -- Build custom CSS from style options
            local customCSS = ""
            for k, v in pairs(style) do
                customCSS = customCSS .. k .. ": " .. v .. "; "
            end
            
            -- Replace placeholders in template
            local html = template:gsub("{{CONTENT}}", content or "")
            html = html:gsub("{{CUSTOM_STYLE}}", customCSS)
            return html
        else
            obj.logger.e("[debug] Template not found: " .. options.template)
            local templateNames = {}
            for name, _ in pairs(templates) do
                table.insert(templateNames, name)
            end
            obj.logger.d("[debug] Available templates: " .. table.concat(templateNames, ", "))
        end
    end
    
    -- Original template generation for non-template usage
    local background = options.background or ""
    
    -- Build custom CSS from style options
    local customCSS = ""
    for k, v in pairs(style) do
        customCSS = customCSS .. k .. ": " .. v .. "; "
    end
    
    local html = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        }
        
        html, body {
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            position: relative;
            background: transparent;
        }
        
        #background-layer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            background: ]] .. (background:match("^#") and background or 
                             background:match("^rgb") and background or 
                             background:match("^linear%-gradient") and background or
                             background:match("%.gif$") and ("url('" .. background .. "') center/cover no-repeat") or
                             "rgba(0, 0, 0, 0.9)") .. [[;
        }
        
        #content-layer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 2;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: white;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            ]] .. customCSS .. [[
        }
        
        #overlay-layer {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 3;
            pointer-events: none;
        }
        
        .dismiss-hint {
            position: absolute;
            bottom: 10px;
            right: 10px;
            font-size: 12px;
            color: rgba(255, 255, 255, 0.5);
            pointer-events: none;
        }
        
        /* Animation classes */
        @keyframes fadeIn {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
        
        @keyframes fadeOut {
            from { opacity: 1; transform: scale(1); }
            to { opacity: 0; transform: scale(0.95); }
        }
        
        body {
            animation: fadeIn 0.3s ease-out forwards;
        }
    </style>
</head>
<body>
    <div id="background-layer"></div>
    <div id="content-layer">
        ]] .. content .. [[
    </div>
    <div id="overlay-layer">
        <div class="dismiss-hint">Press ESC to dismiss</div>
    </div>
    
    <script>
        // Focus handling
        window.focus();
        document.body.focus();
    </script>
</body>
</html>
    ]]
    
    return html
end

-- Register built-in templates
function obj:_registerBuiltInTemplates()
    local resourcePath = getResourcePath()
    local templatesDir = resourcePath .. "/templates/"
    
    self.logger.d("[debug] Looking for templates in: " .. templatesDir)
    
    -- Load jellyfish template
    local jellyfishPath = templatesDir .. "jellyfish.html"
    self.logger.d("[debug] Attempting to load jellyfish template from: " .. jellyfishPath)
    local jellyfish = loadTemplateFile(jellyfishPath)
    if jellyfish then
        self._templates["jellyfish"] = jellyfish
        self.logger.d("[debug] Successfully loaded jellyfish template")
    else
        self.logger.e("[debug] Failed to load jellyfish template from: " .. jellyfishPath)
    end
    
    -- Load existing example files as templates
    local matrix = loadTemplateFile(resourcePath .. "/examples/matrix.html")
    if matrix then
        -- Wrap in template format
        self._templates["matrix"] = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
]] .. matrix:match("<style>.-</script>") .. [[
    <div id="content-layer" style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 100; color: white; text-align: center; font-family: -apple-system, BlinkMacSystemFont, sans-serif; {{CUSTOM_STYLE}}">
        {{CONTENT}}
    </div>
</body>
</html>
        ]]
    end
    
    -- Add style-only templates
    self._templates["neon"] = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100vw; height: 100vh; overflow: hidden; background: #000; }
        #content-layer {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
            color: #fff; text-align: center; font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            text-shadow: 0 0 10px #0ff, 0 0 20px #0ff, 0 0 30px #0ff, 0 0 40px #0ff;
            {{CUSTOM_STYLE}}
        }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        body { animation: fadeIn 0.3s ease-out; }
    </style>
</head>
<body>
    <div id="content-layer">{{CONTENT}}</div>
</body>
</html>
    ]]
    
    self._templates["alert"] = [[
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100vw; height: 100vh; overflow: hidden; background: linear-gradient(135deg, #c31432, #240b36); }
        #content-layer {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
            background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.3); border-radius: 20px;
            padding: 40px; color: #fff; text-align: center;
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            {{CUSTOM_STYLE}}
        }
        @keyframes pulse { 0%, 100% { transform: translate(-50%, -50%) scale(1); } 50% { transform: translate(-50%, -50%) scale(1.05); } }
        #content-layer { animation: pulse 2s ease-in-out infinite; }
    </style>
</head>
<body>
    <div id="content-layer">{{CONTENT}}</div>
</body>
</html>
    ]]
    
    -- Load minimal template
    local minimal = loadTemplateFile(templatesDir .. "minimal.html")
    if minimal then
        self._templates["minimal"] = minimal
    end
    
    -- Load overlay template (partial click-through)
    local overlay = loadTemplateFile(templatesDir .. "overlay.html")
    if overlay then
        self._templates["overlay"] = overlay
    end
    
    -- Load HUD template (fully click-through)
    local hud = loadTemplateFile(templatesDir .. "hud.html")
    if hud then
        self._templates["hud"] = hud
    end
    
    -- Load other example templates
    local particles = loadTemplateFile(resourcePath .. "/examples/particles.html")
    if particles then
        self._templates["particles"] = particles:gsub('<div id="particles%-message">(.-)</div>', '<div id="particles-message">{{CONTENT}}</div>')
    end
    
    local waves = loadTemplateFile(resourcePath .. "/examples/gradient-wave.html")
    if waves then
        self._templates["waves"] = waves:gsub('<div id="wave%-message">(.-)</div>', '<div id="wave-message">{{CONTENT}}</div>')
    end
end

--- Inyo:registerTemplate(name, template)
--- Method
--- Register a custom template for use with the show() method
---
--- Parameters:
---  * name - String identifier for the template
---  * template - HTML string with {{CONTENT}} and {{CUSTOM_STYLE}} placeholders
---
--- Returns:
---  * The Inyo object for method chaining
function obj:registerTemplate(name, template)
    self._templates[name] = template
    return self
end

--- Inyo:show(content, options)
--- Method
--- Display a message using the webview
---
--- Parameters:
---  * content - String containing the HTML content to display
---  * options - Optional table with the following keys:
---    * background - CSS background value (color, gradient, or image URL)
---    * style - Table of CSS properties to apply to the content
---    * duration - Number of seconds before auto-dismissing
---    * template - String name of a registered template to use
---    * size - Table with w and h keys for custom dimensions
---    * opacity - Number between 0 and 1 for window opacity
---
--- Returns:
---  * The Inyo object for method chaining
---
--- Notes:
---  * Press ESC to dismiss the message manually
---  * If a message is already showing, it will be dismissed first
function obj:show(content, options)
    options = options or {}
    
    -- Close existing webview if present
    self:dismiss()
    
    -- Generate HTML
    local html = generateHTML(content, options, self._templates)
    
    -- Determine size and opacity (with template-specific overrides)
    local size = self._config.size
    local opacity = self._config.opacity
    
    -- Template-specific settings
    if options.template == "jellyfish" then
        size = { w = 1560, h = 1040 }  -- 130% bigger (original + 30%)
        opacity = 0.85  -- 15% transparent (85% opaque)
    elseif options.template == "hud" then
        -- For HUD, we could make it smaller and position at top
        size = { w = 400, h = 200 }
        if not options.position then
            self._config.position = "top"
        end
    end
    
    -- Allow options to override
    if options.size then
        size = options.size
    end
    if options.opacity then
        opacity = options.opacity
    end
    
    -- Calculate position
    local frame = calculatePosition(size, self._config)
    
    -- Create webview
    self._webview = hs.webview.new(frame)
        :windowStyle({})
        :allowTextEntry(true)
        :level(hs.drawing.windowLevels.modalPanel)
        :alpha(opacity)
        :html(html)
        :show()
        :bringToFront(true)
    
    -- Create modal for escape key handling
    self._modal = hs.hotkey.modal.new()
    self._modal:bind({}, "escape", function()
        self:dismiss()
    end)
    self._modal:enter()
    
    -- Set up auto-dismiss timer if duration specified
    if options.duration then
        hs.timer.doAfter(options.duration, function()
            self:dismiss()
        end)
    end
    
    return self
end

--- Inyo:dismiss()
--- Method
--- Dismiss the currently displayed message
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
---  * If messages are queued, the next one will be displayed automatically
function obj:dismiss()
    if self._modal then
        self._modal:exit()
        self._modal = nil
    end
    
    if self._webview then
        self._webview:delete()
        self._webview = nil
    end
    
    -- Show next message in queue if any
    if #self._messageQueue > 0 then
        local nextMessage = table.remove(self._messageQueue, 1)
        self:show(nextMessage.content, nextMessage.options)
    end
end

--- Inyo:queue(content, options)
--- Method
--- Add a message to the queue for sequential display
---
--- Parameters:
---  * content - String containing the HTML content to display
---  * options - Optional table with the same keys as show()
---
--- Returns:
---  * None
---
--- Notes:
---  * Messages are displayed in FIFO order
---  * If no message is currently showing, the queued message displays immediately
function obj:queue(content, options)
    table.insert(self._messageQueue, { content = content, options = options })
    
    -- If no message is currently showing, show this one
    if not self._webview then
        local message = table.remove(self._messageQueue, 1)
        self:show(message.content, message.options)
    end
end

--- Inyo:startServer()
--- Method
--- Start the HTTP server for external message control
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
---
--- Notes:
---  * Server listens on the configured port (default 8888)
---  * Endpoint: POST /message with JSON body
---  * Example: curl -X POST http://localhost:8888/message -H "Content-Type: application/json" -d '{"content": "Hello", "background": "#ff0000"}'
function obj:startServer()
    if self._httpServer then
        self._httpServer:stop()
    end
    
    local serverSelf = self
    self._httpServer = hs.httpserver.new()
        :setPort(self._config.port)
        :setCallback(function(method, path, headers, body)
            if method == "POST" and path == "/message" then
                local success, data = pcall(hs.json.decode, body)
                if success and data then
                    local content = data.content or "No content"
                    local options = {
                        background = data.background,
                        style = data.style,
                        duration = data.duration,
                        template = data.template,
                        size = data.size,
                        opacity = data.opacity
                    }
                    
                    if data.queue then
                        serverSelf:queue(content, options)
                    else
                        serverSelf:show(content, options)
                    end
                    
                    return "OK", 200, { ["Content-Type"] = "text/plain" }
                else
                    return "Invalid JSON", 400, { ["Content-Type"] = "text/plain" }
                end
            else
                return "Not Found", 404, { ["Content-Type"] = "text/plain" }
            end
        end)
        :start()
    
    print("Inyo HTTP server started on port " .. self._config.port)
end

--- Inyo:stopServer()
--- Method
--- Stop the HTTP server
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:stopServer()
    if self._httpServer then
        self._httpServer:stop()
        self._httpServer = nil
    end
end

--- Inyo:configure(config)
--- Method
--- Update configuration options
---
--- Parameters:
---  * config - Table with configuration options:
---    * port - HTTP server port (default: 8888)
---    * defaultDuration - Default auto-dismiss duration in seconds
---    * position - String "center", "top", "bottom", or table with x,y coordinates
---    * size - Table with w and h keys for default dimensions
---    * opacity - Default window opacity (0-1)
---    * animationDuration - Animation duration in milliseconds
---    * clickThrough - Boolean for click-through behavior
---
--- Returns:
---  * The Inyo object for method chaining
function obj:configure(config)
    for k, v in pairs(config) do
        self._config[k] = v
    end
    return self
end

--- Inyo:debug()
--- Method
--- Print debug information about the current state
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function obj:debug()
    print("=== Inyo Debug Info ===")
    print("Resource path: " .. (getResourcePath() or "nil"))
    print("Templates loaded:")
    if self._templates then
        for name, _ in pairs(self._templates) do
            print("  - " .. name)
        end
    else
        print("  No templates table!")
    end
    print("Config:")
    print(hs.inspect(self._config))
end

--- Inyo:init()
--- Method
--- Initialize the Inyo spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Inyo object
---
--- Notes:
---  * This method is called automatically by hs.loadSpoon()
---  * Sets up templates and URL event handlers
function obj:init()
    -- Initialize instance state if not already done
    if not self._templates then
        self._webview = nil
        self._modal = nil
        self._httpServer = nil
        self._messageQueue = {}
        self._templates = {}
        self._config = self._config or {
            port = 8888,
            defaultDuration = nil,
            position = "center",
            size = { w = 600, h = 400 },
            opacity = 0.95,
            animationDuration = 300,
            clickThrough = false
        }
    end
    
    -- Set spoonPath if we're running as a Spoon
    if not self.spoonPath and spoon and spoon.Inyo == self then
        self.spoonPath = hs.configdir .. "/Spoons/Inyo.spoon"
    end
    
    -- Register built-in templates
    self:_registerBuiltInTemplates()
    
    -- Bind URL event handler
    hs.urlevent.bind("inyo", function(eventName, params)
        local content = params.content or params.message or "No content"
        local options = {
            background = params.background,
            duration = tonumber(params.duration),
            style = {}
        }
        
        -- Parse style parameters
        for k, v in pairs(params) do
            if k:match("^style%.") then
                local styleKey = k:gsub("^style%.", "")
                options.style[styleKey] = v
            end
        end
        
        self:show(content, options)
    end)
    
    return self
end

--- Inyo:start()
--- Method
--- Start the Inyo spoon (starts HTTP server)
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Inyo object for method chaining
function obj:start()
    self:startServer()
    return self
end

--- Inyo:stop()
--- Method
--- Stop the Inyo spoon (stops HTTP server and dismisses any messages)
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Inyo object for method chaining
function obj:stop()
    self:stopServer()
    self:dismiss()
    return self
end

-- Return the object (not an instance) for Spoon compatibility
return obj