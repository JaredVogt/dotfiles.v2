--- === DynamicMenu ===
---
--- A module for generating dynamic menu items for Hammerflow
--- Generators are loaded from the generators/ directory

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "DynamicMenu"
obj.version = "2.0"
obj.author = "Hammerflow Dynamic Menu System"
obj.license = "MIT"

-- State
obj._generators = {}
obj._cache = {}
obj._cacheTimeout = 300 -- 5 minutes default

-- Helper to get the module directory
local function getModuleDir()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)") or "."
end

--- DynamicMenu:loadGenerators()
--- Method
--- Load all generators from the generators/ directory
---
--- Returns:
---  * The DynamicMenu object for chaining
function obj:loadGenerators()
  local moduleDir = getModuleDir()
  local generatorsDir = moduleDir .. "generators"
  
  -- Get list of lua files in generators directory
  local handle = io.popen('ls "' .. generatorsDir .. '"/*.lua 2>/dev/null')
  if handle then
    for file in handle:lines() do
      -- Extract filename without extension
      local name = file:match("([^/]+)%.lua$")
      if name then
        -- Load the generator
        local success, generator = pcall(dofile, file)
        if success and type(generator) == "function" then
          obj._generators[name] = generator
          -- print("Loaded generator: " .. name)
        else
          print("Failed to load generator: " .. name .. " - " .. tostring(generator))
        end
      end
    end
    handle:close()
  end
  
  return obj
end

--- DynamicMenu:parseGeneratorCall(str)
--- Method
--- Parse a generator call string like "cursor" or "files(~/Downloads)"
---
--- Parameters:
---  * str - The generator call string
---
--- Returns:
---  * name - Generator name
---  * args - Arguments (string or nil)
local function parseGeneratorCall(str)
  -- Match pattern: name(args) or just name
  local name, args = str:match("^([^%(]+)%((.*)%)$")
  if not name then
    -- No parentheses, just the name
    return str, nil
  end
  
  -- Remove quotes if present
  if args then
    args = args:gsub("^['\"]", ""):gsub("['\"]$", "")
  end
  
  return name, args
end

--- DynamicMenu:generate(generatorCall)
--- Method
--- Generate menu items using a generator from the generators/ directory
---
--- Parameters:
---  * generatorCall - Generator call string like "cursor" or "files(~/Downloads)"
---
--- Returns:
---  * Table of menu items or nil if generator not found
function obj:generate(generatorCall)
  local name, args = parseGeneratorCall(generatorCall)
  
  -- Try to load generator if not already loaded
  if not obj._generators[name] then
    local moduleDir = getModuleDir()
    local generatorPath = moduleDir .. "generators/" .. name .. ".lua"
    local success, generator = pcall(dofile, generatorPath)
    if success and type(generator) == "function" then
      obj._generators[name] = generator
    else
      return nil, "Generator '" .. name .. "' not found or failed to load"
    end
  end
  
  local generator = obj._generators[name]
  if not generator then
    return nil, "Generator '" .. name .. "' not found"
  end
  
  -- For cursor generator, skip cache entirely
  local skipCache = (name == "cursor")
  
  -- Check cache first (unless skipping)
  if not skipCache then
    local cacheKey = generatorCall
    local cached = obj._cache[cacheKey]
    if cached and (os.time() - cached.time) < obj._cacheTimeout then
      return cached.items
    end
  end
  
  -- Generate new items
  local success, items = pcall(generator, args)
  if not success then
    return nil, "Generator error: " .. tostring(items)
  end
  
  -- Process and validate items
  local processedItems = obj:processItems(items)
  
  -- Cache the results (unless skipping)
  if not skipCache then
    local cacheKey = generatorCall
    obj._cache[cacheKey] = {
      items = processedItems,
      time = os.time()
    }
  end
  
  return processedItems
end

--- DynamicMenu:processItems(items)
--- Method
--- Process raw items into Hammerflow-compatible format with auto-assigned shortcuts
---
--- Parameters:
---  * items - Array of items or key-value pairs
---
--- Returns:
---  * Processed items with shortcuts assigned
function obj:processItems(items)
  local processed = {}
  local shortcuts = obj:generateShortcuts(#items)
  
  -- Handle different input formats
  if type(items) == "table" then
    if #items > 0 then
      -- Array format
      for i, item in ipairs(items) do
        if i <= #shortcuts then
          local shortcut = shortcuts[i]
          processed[shortcut] = item
        end
      end
    else
      -- Key-value format: shortcuts already specified
      for k, v in pairs(items) do
        processed[k] = v
      end
    end
  end
  
  return processed
end

--- DynamicMenu:generateShortcuts(count)
--- Method
--- Generate a sequence of shortcuts for menu items
---
--- Parameters:
---  * count - Number of shortcuts needed
---
--- Returns:
---  * Array of shortcut keys
function obj:generateShortcuts(count)
  local shortcuts = {}
  
  -- First use single letters a-z
  for i = 1, math.min(count, 26) do
    table.insert(shortcuts, string.char(96 + i))
  end
  
  -- Then use numbers 1-9
  if count > 26 then
    for i = 1, math.min(count - 26, 9) do
      table.insert(shortcuts, tostring(i))
    end
  end
  
  -- Then use uppercase letters A-Z
  if count > 35 then
    for i = 1, math.min(count - 35, 26) do
      table.insert(shortcuts, string.char(64 + i))
    end
  end
  
  return shortcuts
end

--- DynamicMenu:clearCache(generatorName)
--- Method
--- Clear cache for a specific generator or all generators
---
--- Parameters:
---  * generatorName - Optional generator name, clears all if nil
function obj:clearCache(generatorName)
  if generatorName then
    for key, _ in pairs(obj._cache) do
      if key:sub(1, #generatorName) == generatorName then
        obj._cache[key] = nil
      end
    end
  else
    obj._cache = {}
  end
end

--- DynamicMenu:listGenerators()
--- Method
--- List all available generators
---
--- Returns:
---  * Array of generator names
function obj:listGenerators()
  local names = {}
  for name, _ in pairs(obj._generators) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

-- Initialize by loading generators
-- obj:loadGenerators()  -- Lazy load instead

return obj