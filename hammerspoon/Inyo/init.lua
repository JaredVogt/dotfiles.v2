---@diagnostic disable: undefined-global

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Inyo"
obj.version = "1.0"
obj.author = "Jared Vogt"
obj.homepage = "https://github.com/jaredvogt/inyo"
obj.license = "MIT"

-- Constructor
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

-- Base HTML template
local function generateHTML(content, options, templates)
    options = options or {}
    local style = options.style or {}
    
    -- Check if using a template
    if options.template and templates[options.template] then
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
    local templatesDir = hs.configdir .. "/Inyo/templates/"
    
    -- Load jellyfish template
    local jellyfish = loadTemplateFile(templatesDir .. "jellyfish.html")
    if jellyfish then
        self._templates["jellyfish"] = jellyfish
    end
    
    -- Load existing example files as templates
    local matrix = loadTemplateFile(hs.configdir .. "/Inyo/examples/matrix.html")
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
    local particles = loadTemplateFile(hs.configdir .. "/Inyo/examples/particles.html")
    if particles then
        self._templates["particles"] = particles:gsub('<div id="particles%-message">(.-)</div>', '<div id="particles-message">{{CONTENT}}</div>')
    end
    
    local waves = loadTemplateFile(hs.configdir .. "/Inyo/examples/gradient-wave.html")
    if waves then
        self._templates["waves"] = waves:gsub('<div id="wave%-message">(.-)</div>', '<div id="wave-message">{{CONTENT}}</div>')
    end
end

-- Register custom template
function obj:registerTemplate(name, template)
    self._templates[name] = template
    return self
end

-- Show message in webview
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

-- Dismiss current message
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

-- Queue a message
function obj:queue(content, options)
    table.insert(self._messageQueue, { content = content, options = options })
    
    -- If no message is currently showing, show this one
    if not self._webview then
        local message = table.remove(self._messageQueue, 1)
        self:show(message.content, message.options)
    end
end

-- Start HTTP server
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
                        duration = data.duration
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

-- Stop HTTP server
function obj:stopServer()
    if self._httpServer then
        self._httpServer:stop()
        self._httpServer = nil
    end
end

-- Configuration
function obj:configure(config)
    for k, v in pairs(config) do
        self._config[k] = v
    end
    return self
end

-- Initialize
function obj:init()
    return self
end

-- Start (auto-start server)
function obj:start()
    self:startServer()
    return self
end

-- Stop
function obj:stop()
    self:stopServer()
    self:dismiss()
    return self
end

-- Create singleton instance
local instance = obj:new()

-- Bind URL event handler to instance
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
    
    instance:show(content, options)
end)

return instance