---@diagnostic disable: undefined-global

local obj = {}
obj.__index = obj

-- URL event handler for reload
hs.urlevent.bind("reload", function(eventName, params)
    hs.reload()
end)

-- Metadata
obj.name = "Hammerflow"
obj.version = "1.0"
obj.author = "Sam Lewis <sam@saml.dev>"
obj.homepage = "https://github.com/saml-dev/Hammerflow.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- State
obj.auto_reload = false
obj._userFunctions = {}
obj._apps = {}
obj._inputWebview = nil

-- lets us package RecursiveBinder with Hammerflow to include
-- sorting and a bug fix that hasn't been merged upstream yet
-- https://github.com/Hammerspoon/Spoons/pull/333
package.path = package.path .. ";" .. hs.configdir .. "/Spoons/Hammerflow.spoon/Spoons/?.spoon/init.lua"
hs.loadSpoon("RecursiveBinder")

local function full_path(rel_path)
  local current_file = debug.getinfo(2, "S").source:sub(2) -- Get the current file's path
  local current_dir = current_file:match("(.*/)") or "."   -- Extract the directory
  return current_dir .. rel_path
end
local function loadfile_relative(path)
  local full_path = full_path(path)
  local f, err = loadfile(full_path)
  if f then
    return f()
  else
    error("Failed to require relative file: " .. full_path .. " - " .. err)
  end
end
local function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local toml = loadfile_relative("lib/tinytoml.lua")
local validateTomlStructure = loadfile_relative("toml_validator.lua")
local dynamicMenu = loadfile_relative("DynamicMenu/init.lua")

local function parseKeystroke(keystroke)
  local parts = {}
  for part in keystroke:gmatch("%S+") do
    table.insert(parts, part)
  end
  local key = table.remove(parts) -- Last part is the key
  return parts, key
end

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Action Helpers
local singleKey = spoon.RecursiveBinder.singleKey
local rect = hs.geometry.rect
local move = function(loc)
  return function()
    local w = hs.window.focusedWindow()
    w:move(loc)
    -- for some reason Firefox, and therefore Zen Browser, both
    -- animate when no other apps do, and only change size *or*
    -- position when moved, so it has to be issued twice. 0.2 is
    -- the shortest delay that works consistently.
    if hs.application.frontmostApplication():bundleID() == "app.zen-browser.zen" or
        hs.application.frontmostApplication():bundleID() == "org.mozilla.firefox" then
      os.execute("sleep 0.2")
      w:move(loc)
    end
  end
end
local open = function(link)
  return function() os.execute(string.format("open \"%s\"", link)) end
end
local raycast = function(link)
  -- raycast needs -g to keep current app as "active" for
  -- pasting from emoji picker and window management
  return function() os.execute(string.format("open -g %s", link)) end
end
local text = function(s)
  return function() hs.eventtap.keyStrokes(s) end
end
local keystroke = function(keystroke)
  local mods, key = parseKeystroke(keystroke)
  return function() hs.eventtap.keyStroke(mods, key) end
end
local cmd = function(cmd)
  return function() os.execute(cmd .. " &") end
end
local code = function(arg) return cmd("open -a 'Visual Studio Code' " .. arg) end
local launch = function(app)
  return function() hs.application.launchOrFocus(app) end
end
local hs_run = function(lua)
  return function() load(lua)() end
end
local userFunc = function(funcKey)
  local args = nil
  -- if funcKey has | in it, split on it. first is function name, rest are args for that function
  if funcKey:find("|") then
    local sp = split(funcKey, "|")
    funcKey = table.remove(sp, 1)
    args = sp
  end
  return function()
    if obj._userFunctions[funcKey] then
      obj._userFunctions[funcKey](table.unpack(args or {}))
    else
      hs.alert("Unknown function " .. funcKey, 3)
    end
  end
end
local function isApp(app)
  return function()
    local frontApp = hs.application.frontmostApplication()
    local title = frontApp:title():lower()
    local bundleID = frontApp:bundleID():lower()
    app = app:lower()
    return title == app or bundleID == app
  end
end

-- window management presets
local windowLocations = {
  ["left-half"] = move(hs.layout.left50),
  ["center-half"] = move(rect(.25, 0, .5, 1)),
  ["right-half"] = move(hs.layout.right50),
  ["first-quarter"] = move(hs.layout.left25),
  ["second-quarter"] = move(rect(.25, 0, .25, 1)),
  ["third-quarter"] = move(rect(.5, 0, .25, 1)),
  ["fourth-quarter"] = move(hs.layout.right25),
  ["left-third"] = move(rect(0, 0, 1 / 3, 1)),
  ["center-third"] = move(rect(1 / 3, 0, 1 / 3, 1)),
  ["right-third"] = move(rect(2 / 3, 0, 1 / 3, 1)),
  ["top-half"] = move(rect(0, 0, 1, .5)),
  ["bottom-half"] = move(rect(0, .5, 1, .5)),
  ["top-left"] = move(rect(0, 0, .5, .5)),
  ["top-right"] = move(rect(.5, 0, .5, .5)),
  ["bottom-left"] = move(rect(0, .5, .5, .5)),
  ["bottom-right"] = move(rect(.5, .5, .5, .5)),
  ["maximized"] = move(hs.layout.maximized),
  ["fullscreen"] = function() hs.window.focusedWindow():toggleFullScreen() end
}

-- helper functions
local function startswith(s, prefix)
  return s:sub(1, #prefix) == prefix
end

local function postfix(s)
  --  return the string after the colon
  return s:sub(s:find(":") + 1)
end

-- Custom input dialog with aggressive focus handling
local function showCustomInputDialog(prompt, callback)
  -- Close existing input dialog if present and clean up ALL handlers
  if obj._inputWebview then
    if obj._inputWebview.modal then
      obj._inputWebview.modal:exit()
      obj._inputWebview.modal = nil
    end
    obj._inputWebview:delete()
    obj._inputWebview = nil
  end
  
  local html = [[
  <!DOCTYPE html>
  <html>
  <head>
      <style>
          html, body {
              background: transparent !important;
              margin: 0;
              padding: 0;
              height: 100vh;
              width: 100vw;
              display: flex;
              align-items: center;
              justify-content: center;
              overflow: hidden;
          }
          .input-container {
              background-color: rgba(0, 0, 0, 0.9);
              border: 3px solid #00ff00;
              border-radius: 12px;
              padding: 25px;
              text-align: center;
              font-family: 'Menlo', monospace;
              color: white;
              min-width: 400px;
              max-width: 450px;
              box-shadow: 0 0 20px rgba(0, 255, 0, 0.5);
              box-sizing: border-box;
          }
          .prompt-text {
              font-size: 18px;
              margin-bottom: 20px;
              color: #00ff00;
              text-shadow: 0 0 5px #00ff00;
          }
          .input-field {
              width: 100%;
              padding: 12px;
              font-size: 16px;
              font-family: 'Menlo', monospace;
              background-color: rgba(255, 255, 255, 0.1);
              border: 2px solid #00ff00;
              border-radius: 6px;
              color: white;
              outline: none;
              margin-bottom: 20px;
              box-sizing: border-box;
          }
          .input-field:focus {
              border-color: #00ff00;
              box-shadow: 0 0 10px rgba(0, 255, 0, 0.5);
          }
          .button-container {
              display: flex;
              gap: 15px;
              justify-content: center;
          }
          .btn {
              padding: 10px 20px;
              font-size: 14px;
              font-family: 'Menlo', monospace;
              border: 2px solid #00ff00;
              border-radius: 6px;
              background-color: rgba(0, 255, 0, 0.1);
              color: #00ff00;
              cursor: pointer;
              transition: all 0.2s ease;
              min-width: 80px;
          }
          .btn:hover {
              background-color: rgba(0, 255, 0, 0.2);
              transform: scale(1.05);
          }
          .btn-primary {
              background-color: rgba(0, 255, 0, 0.2);
          }
      </style>
  </head>
  <body>
      <div class="input-container">
          <div class="prompt-text">]] .. (prompt or "Enter text:") .. [[</div>
          <input type="text" class="input-field" id="userInput" placeholder="Click here and type...">
          <div class="button-container">
              <button class="btn btn-primary" onclick="submit()">Submit</button>
              <button class="btn" onclick="cancel()">Cancel</button>
          </div>
      </div>
      <script>
          function submit() {
              const input = document.getElementById('userInput').value;
              window.location.href = 'hammerflow://input/submit/' + encodeURIComponent(input);
          }
          
          function cancel() {
              window.location.href = 'hammerflow://input/cancel';
          }
          
          // Submit on Enter key - multiple event handlers for reliability
          document.getElementById('userInput').addEventListener('keydown', function(e) {
              console.log('debug: Input keydown:', e.key, e.keyCode);
              if (e.key === 'Enter' || e.keyCode === 13) {
                  console.log('debug: Enter detected on input - submitting');
                  e.preventDefault();
                  e.stopPropagation();
                  submit();
                  return false;
              }
          });
          
          document.getElementById('userInput').addEventListener('keypress', function(e) {
              console.log('debug: Input keypress:', e.key, e.keyCode);
              if (e.key === 'Enter' || e.keyCode === 13) {
                  console.log('debug: Enter keypress detected - submitting');
                  e.preventDefault();
                  e.stopPropagation();
                  submit();
                  return false;
              }
          });
          
          // Global keyboard handlers
          document.addEventListener('keydown', function(e) {
              console.log('debug: Document keydown:', e.key, e.keyCode);
              if (e.key === 'Enter' || e.keyCode === 13) {
                  console.log('debug: Global Enter detected - submitting');
                  e.preventDefault();
                  e.stopPropagation();
                  submit();
                  return false;
              } else if (e.key === 'Escape' || e.keyCode === 27) {
                  console.log('debug: Escape detected - cancelling');
                  e.preventDefault();
                  e.stopPropagation();
                  cancel();
                  return false;
              }
          });
          
          // Focus input field when clicking anywhere
          document.addEventListener('click', function() {
              document.getElementById('userInput').focus();
          });
          
          // Auto-focus on load
          window.addEventListener('load', function() {
              document.getElementById('userInput').focus();
          });
      </script>
  </body>
  </html>
  ]]
  
  -- Create webview
  local screen = hs.screen.mainScreen()
  local screenFrame = screen:frame()
  
  local dialogWidth = 500
  local dialogHeight = 250
  local webviewFrame = {
    x = screenFrame.x + (screenFrame.w - dialogWidth) / 2,
    y = screenFrame.y + (screenFrame.h - dialogHeight) / 2,
    w = dialogWidth,
    h = dialogHeight
  }
  
  obj._inputWebview = hs.webview.new(webviewFrame)
    :windowStyle({})
    :allowTextEntry(true)
    :level(hs.drawing.windowLevels.modalPanel)
    :transparent(true)
    :html(html)
    :show()
    :bringToFront(true)
  
  -- Force focus with click simulation
  hs.timer.doAfter(0.2, function()
    if obj._inputWebview then
      local center = {
        x = webviewFrame.x + webviewFrame.w / 2,
        y = webviewFrame.y + webviewFrame.h / 2
      }
      -- Simulate a click in the center of the dialog
      hs.eventtap.leftClick(center)
    end
  end)
  
  -- Set up navigation callback
  obj._inputWebview:navigationCallback(function(action, webview, navID, url)
    if action == "didStartProvisionalNavigation" then
      if url:match("hammerflow://input/submit/(.*)") then
        local userInput = url:match("hammerflow://input/submit/(.*)")
        userInput = hs.http.urlDecode(userInput) or ""
        -- Clean up ALL handlers
        if obj._inputWebview.modal then
          obj._inputWebview.modal:exit()
          obj._inputWebview.modal = nil
        end
        obj._inputWebview:delete()
        obj._inputWebview = nil
        callback(userInput)
        return false
      elseif url:match("hammerflow://input/cancel") then
        -- Clean up ALL handlers
        if obj._inputWebview.escapeHandler then
          obj._inputWebview.escapeHandler:delete()
        end
        if obj._inputWebview.enterHandler then
          obj._inputWebview.enterHandler:delete()
        end
        obj._inputWebview:delete()
        obj._inputWebview = nil
        callback(nil)
        return false
      end
    end
    return true
  end)
  
  -- Create a modal that captures keys only when dialog is active
  local modal = hs.hotkey.modal.new()
  
  -- Enter key handler
  modal:bind({}, "return", function()
    -- Immediately exit modal to release keys
    modal:exit()
    
    if obj._inputWebview then
      -- Get the input value using JavaScript
      obj._inputWebview:evaluateJavaScript("document.getElementById('userInput').value", function(result)
        local userInput = result or ""
        obj._inputWebview:delete()
        obj._inputWebview = nil
        callback(userInput)
      end)
    end
  end)
  
  -- Escape key handler
  modal:bind({}, "escape", function()
    -- Immediately exit modal to release keys
    modal:exit()
    
    if obj._inputWebview then
      obj._inputWebview:delete()
      obj._inputWebview = nil
      callback(nil)
    end
  end)
  
  -- Enter the modal
  modal:enter()
  obj._inputWebview.modal = modal
  
  -- Focus on the webview
  hs.timer.doAfter(0.3, function()
    if obj._inputWebview then
      obj._inputWebview:evaluateJavaScript([[
        document.getElementById('userInput').focus();
        document.getElementById('userInput').select();
      ]])
    end
  end)
end

local function getActionAndLabel(s)
  if s:find("^http[s]?://") then
    return open(s), s:sub(5, 5) == "s" and s:sub(9) or s:sub(8), nil
  elseif s == "reload" then
    return function()
      hs.reload()
      hs.console.clearConsole()
    end, s, nil
  elseif startswith(s, "raycast://") then
    return raycast(s), s, nil
  elseif startswith(s, "linear://") then
    return open(s), s, nil
  elseif startswith(s, "hs:") then
    return hs_run(postfix(s)), s, nil
  elseif startswith(s, "cmd:") then
    local arg = postfix(s)
    return cmd(arg), arg, nil
  elseif startswith(s, "input:") then
    local remaining = postfix(s)
    local _, label = getActionAndLabel(remaining)
    return function()
      -- user input takes focus and doesn't return it
      local focusedWindow = hs.window.focusedWindow()
      
      showCustomInputDialog("Enter text:", function(userInput)
        -- restore focus
        focusedWindow:focus()
        
        if userInput == nil then return end -- User cancelled
        
        -- replace text and execute remaining action
        local replaced = string.gsub(remaining, "{input}", userInput)
        local action, _ = getActionAndLabel(replaced)
        action()
      end)
    end, label, nil
  elseif startswith(s, "shortcut:") then
    local arg = postfix(s)
    return keystroke(arg), arg, nil
  elseif startswith(s, "function:") then
    local funcKey = postfix(s)
    return userFunc(funcKey), funcKey .. "()", nil
  elseif startswith(s, "km:") then
    local macroName = postfix(s)
    local kmCmd = string.format('osascript -e \'tell application "Keyboard Maestro Engine" to do script "%s"\'', macroName)
    return cmd(kmCmd), "km: " .. macroName, nil
  elseif startswith(s, "code:") then
    local arg = postfix(s)
    return code(arg), "code " .. arg, nil
  elseif startswith(s, "text:") then
    local arg = postfix(s)
    return text(arg), arg, nil
  elseif startswith(s, "dynamic:") then
    local arg = postfix(s)
    -- Parse generator name and optional arguments
    local generatorName, args = arg:match("^([^|]+)|?(.*)$")
    if not generatorName then
      generatorName = arg
      args = nil
    end
    
    -- Create a closure that captures layout options
    local function createDynamicMenu(capturedLayoutOptions)
      return function()
      local items, err = dynamicMenu:generate(generatorName, args)
      if not items then
        hs.alert("Dynamic menu error: " .. (err or "unknown"), nil, nil, 5)
        return
      end
      
      -- Convert items to Hammerflow keymap format
      local keyMap = {}
      for k, v in pairs(items) do
        if type(v) == "string" then
          -- Simple string -> launch app
          local action, label, icon = getActionAndLabel(v)
          keyMap[singleKey(k, label)] = {action = action, icon = icon}
        elseif type(v) == "table" then
          if v.action then
            -- Item with custom action
            local action, label, icon
            if type(v.action) == "function" then
              action = v.action
              label = v.label or "Action"
            elseif type(v.action) == "table" and v.action.type == "km" then
              -- Keyboard Maestro action with variables
              action = function()
                -- Build AppleScript to set multiple variables and trigger macro
                local script = 'tell application "Keyboard Maestro Engine"\n'
                if v.action.variables then
                  for varName, varValue in pairs(v.action.variables) do
                    script = script .. string.format('  setvariable "%s" to "%s"\n', 
                      varName, tostring(varValue):gsub('"', '\\"'))
                  end
                end
                script = script .. string.format('  do script "%s"\n', v.action.macro)
                script = script .. 'end tell'
                hs.osascript.applescript(script)
              end
              label = v.label or v.action.macro
            else
              action, label, icon = getActionAndLabel(v.action)
            end
            keyMap[singleKey(k, v.label or label)] = {action = action, icon = v.icon or icon}
          else
            -- Nested submenu
            keyMap[singleKey(k, v.label or k)] = v
          end
        end
      end
      
        -- Show the dynamic menu with layout options
        spoon.RecursiveBinder.recursiveBind(keyMap, nil, capturedLayoutOptions)()
      end
    end
    return createDynamicMenu, "→ " .. generatorName, nil
  elseif startswith(s, "window:") then
    local loc = postfix(s)
    if windowLocations[loc] then
      return windowLocations[loc], s, nil
    else
      -- Parse values, now supporting negative numbers for pixels
      local x, y, w, h = loc:match("^([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)$")
      if not x then
        hs.alert('Invalid window location: "' .. loc .. '"', nil, nil, 5)
        return
      end
      
      -- Convert string values to numbers
      x, y, w, h = tonumber(x), tonumber(y), tonumber(w), tonumber(h)
      
      -- Function to convert pixel values to percentages
      local function convertValue(value, dimension, isPosition)
        -- Values between -1 and 1 are percentages
        if value >= -1 and value <= 1 then
          return value
        end
        
        -- Get screen dimensions
        local screen = hs.screen.mainScreen()
        local screenFrame = screen:frame()
        local screenSize = dimension == "width" and screenFrame.w or screenFrame.h
        
        -- Convert pixels to percentage
        if value < 0 then
          -- Negative pixels: position from right/bottom edge
          if isPosition then
            return 1 + (value / screenSize)  -- e.g., -1000px from right = 1 + (-1000/2560)
          else
            -- For width/height, negative doesn't make sense, treat as positive
            return math.abs(value) / screenSize
          end
        else
          -- Positive pixels: position from left/top edge
          return value / screenSize
        end
      end
      
      -- Convert each value
      x = convertValue(x, "width", true)
      y = convertValue(y, "height", true)
      w = convertValue(w, "width", false)
      h = convertValue(h, "height", false)
      
      return move(rect(x, y, w, h)), s, nil
    end
    return
  else
    return launch(s), s, nil
  end
end

function obj.loadFirstValidTomlFile(paths)
  -- parse TOML file
  local configFile = nil
  local configFileName = ""
  local searchedPaths = {}
  for _, path in ipairs(paths) do
    if not startswith(path, "/") then
      path = hs.configdir .. "/" .. path
    end
    table.insert(searchedPaths, path)
    if file_exists(path) then
      -- Validate TOML structure before parsing
      local success, message = validateTomlStructure(path)
      if not success then
        print("TOML validation failed: " .. message)
      end
      
      local success, result = pcall(function() return toml.parse(path) end)
      if success then
        configFile = result
        configFileName = path
        break
      else
        print("Parse error in " .. path .. ": " .. tostring(result))
        hs.notify.show("Hammerflow", "Parse error", path .. "\n" .. tostring(result))
      end
    end
  end
  if not configFile then
    print("No TOML config found!")
    print("Searched paths:")
    for _, path in ipairs(searchedPaths) do
      print("  - " .. path)
    end
    hs.alert("No toml config found! Searched for: " .. table.concat(searchedPaths, ', '), 5)
    obj.auto_reload = true
    return
  end
  if configFile.leader_key == nil or configFile.leader_key == "" then
    hs.alert("You must set leader_key at the top of " .. configFileName .. ". Exiting.", 5)
    return
  end

  -- settings
  local leader_key = configFile.leader_key or "f18"
  local leader_key_mods = configFile.leader_key_mods or ""
  if configFile.auto_reload == nil or configFile.auto_reload then
    obj.auto_reload = true
  end
  if configFile.toast_on_reload == true then
    hs.alert('🔁 Reloaded config')
  end
  if configFile.show_ui == false then
    spoon.RecursiveBinder.showBindHelper = false
  end
  
  -- Set display mode (default to webview)
  local display_mode = configFile.display_mode or "webview"
  spoon.RecursiveBinder.displayMode = display_mode

  spoon.RecursiveBinder.helperFormat = {
    atScreenEdge = 0,
    strokeColor = { white = 0, alpha = 0.8 },
    fillColor = { white = 0, alpha = 0.8 },
    textColor = { red = 0, green = 1, blue = 0, alpha = 1 },
    textFont = 'Menlo',
    textSize = 48,
    radius = 8,
    padding = 16
  }

  -- Grid layout configuration
  local maxCols = configFile.max_grid_columns or 5
  local gridSpacing = configFile.grid_spacing or " | "
  local gridSeparator = configFile.grid_separator or " : "
  local layoutMode = configFile.layout_mode or "horizontal"
  local maxColumnHeight = configFile.max_column_height or 10

  -- Background configuration
  local backgroundConfig = configFile.background or {}
  local backgroundImage = backgroundConfig.image or nil
  local backgroundOpacity = backgroundConfig.opacity or 0.6
  local backgroundPosition = backgroundConfig.position or "center center"
  local backgroundSize = backgroundConfig.size or "cover"

  -- Pass to RecursiveBinder
  spoon.RecursiveBinder.maxColumns = maxCols
  spoon.RecursiveBinder.gridSpacing = gridSpacing
  spoon.RecursiveBinder.gridSeparator = gridSeparator
  spoon.RecursiveBinder.layoutMode = layoutMode
  spoon.RecursiveBinder.maxColumnHeight = maxColumnHeight
  spoon.RecursiveBinder.backgroundImage = backgroundImage
  spoon.RecursiveBinder.backgroundOpacity = backgroundOpacity
  spoon.RecursiveBinder.backgroundPosition = backgroundPosition
  spoon.RecursiveBinder.backgroundSize = backgroundSize

  -- clear settings from table so we don't have to account
  -- for them in the recursive processing function
  configFile.leader_key = nil
  configFile.leader_key_mods = nil
  configFile.auto_reload = nil
  configFile.toast_on_reload = nil
  configFile.show_ui = nil
  configFile.display_mode = nil
  configFile.max_grid_columns = nil
  configFile.grid_spacing = nil
  configFile.grid_separator = nil
  configFile.layout_mode = nil
  configFile.max_column_height = nil
  configFile.background = nil

  local function parseKeyMap(config)
    local keyMap = {}
    local conditionalActions = nil
    
    for k, v in pairs(config) do
      if k == "label" then
        -- continue
      elseif k == "icon" then
        -- continue
      elseif k == "apps" then
        for shortName, app in pairs(v) do
          obj._apps[shortName] = app
        end
      elseif string.find(k, "_") then
        -- Check if this is a sort key (prefix + single char) or conditional
        local prefix, suffix = k:match("^(.+)_(.+)$")
        if prefix and suffix and #suffix == 1 then
          -- This is a sort key like "01_w" or "z_k"
          local displayKey = suffix  -- "w" or "k"
          local sortKey = k          -- "01_w" or "z_k"
          
          -- Process the value same as regular keys
          if type(v) == "string" then
            local action, label, icon = getActionAndLabel(v)
            keyMap[singleKey(displayKey, label)] = {action = action, icon = icon, sortKey = sortKey}
          elseif type(v) == "table" and v[1] then
            local action, defaultLabel, icon = getActionAndLabel(v[1])
            local customIcon = v[3] or icon
            local layoutOptions = v[4] or {}
            -- If action is a dynamic menu factory, call it with layout options
            if type(action) == "function" and v[1]:find("^dynamic:") then
              action = action(layoutOptions)
            end
            keyMap[singleKey(displayKey, v[2] or defaultLabel)] = {action = action, icon = customIcon, sortKey = sortKey, layoutOptions = layoutOptions}
          else
            -- Nested submenu
            keyMap[singleKey(displayKey, v.label or displayKey)] = parseKeyMap(v)
          end
        else
          -- This is a conditional like "w_chrome"
          local key = k:sub(1, 1)
          local cond = k:sub(3)
          if conditionalActions == nil then conditionalActions = {} end
          local actionString = v
          if type(v) == "table" then
            actionString = v[1]
          end
          if conditionalActions[key] then
            conditionalActions[key][cond] = getActionAndLabel(actionString)
          else
            conditionalActions[key] = { [cond] = getActionAndLabel(actionString) }
          end
        end
      elseif type(v) == "string" then
        local action, label, icon = getActionAndLabel(v)
        keyMap[singleKey(k, label)] = {action = action, icon = icon, sortKey = k}
      elseif type(v) == "table" and v[1] then
        local action, defaultLabel, icon = getActionAndLabel(v[1])
        local customIcon = v[3] or icon
        local layoutOptions = v[4] or {}
        -- If action is a dynamic menu factory, call it with layout options
        if type(action) == "function" and v[1]:find("^dynamic:") then
          action = action(layoutOptions)
        end
        keyMap[singleKey(k, v[2] or defaultLabel)] = {action = action, icon = customIcon, sortKey = k, layoutOptions = layoutOptions}
      else
        local nestedKeyMap = parseKeyMap(v)
        local layoutOptions = {}
        local groupLabel = v.label
        -- Check if group label is in array format with layout options
        if type(v.label) == "table" and v.label[1] then
          groupLabel = v.label[1]  -- Extract the actual label
          layoutOptions = v.label[4] or {}
        end
        keyMap[singleKey(k, groupLabel or k)] = {keyMap = nestedKeyMap, icon = v.icon, sortKey = k, layoutOptions = layoutOptions}
      end
    end

    -- parse labels and default action for conditional actions
    local conditionalLabels = {}
    if conditionalActions ~= nil then
      -- get the default action if it exists
      for key_, value_ in pairs(keyMap) do
        if conditionalActions[key_[2]] then
          conditionalActions[key_[2]]["_"] = value_
          keyMap[key_] = nil
          conditionalLabels[key_[2]] = key_[3]
        end
      end
      -- add conditionalActions to keyMap
      for key_, value_ in pairs(conditionalActions) do
        keyMap[singleKey(key_, conditionalLabels[key_] or "conditional")] = {
          action = function()
            local fallback = true
            for cond, fn in pairs(value_) do
              if (obj._userFunctions[cond] and obj._userFunctions[cond]())
                  or (obj._userFunctions[cond] == nil and isApp(cond)())
              then
                fn()
                fallback = false
                break
              end
            end
            if fallback and value_["_"] then
              value_["_"]()
            end
          end,
          icon = nil
        }
      end
    end

    -- add apps to userFunctions if there isn't a function with the same name
    for k, v in pairs(obj._apps) do
      if obj._userFunctions[k] == nil then
        obj._userFunctions[k] = isApp(v)
      end
    end

    return keyMap
  end

  -- Note: TOML parsing validation cannot be done on the parsed table since
  -- Lua tables don't preserve order. The TOML parser will already ignore
  -- keys defined after table sections, so we rely on the documentation
  -- to guide users on proper TOML structure.

  local keys = parseKeyMap(configFile)
  hs.hotkey.bind(leader_key_mods, leader_key, spoon.RecursiveBinder.recursiveBind(keys, nil, nil))
end

function obj.registerFunctions(...)
  for _, funcs in pairs({ ... }) do
    for k, v in pairs(funcs) do
      obj._userFunctions[k] = v
    end
  end
end

-- Expose DynamicMenu for custom generators
obj.dynamicMenu = dynamicMenu

return obj
