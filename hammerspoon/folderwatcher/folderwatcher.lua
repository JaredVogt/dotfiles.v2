-- folderwatcher.lua
-- Enhanced folder watcher with config-based script execution

local folderwatcher = {}

-- Load tinytoml the same way Hammerflow does
local function full_path(rel_path)
  local current_file = debug.getinfo(2, "S").source:sub(2)
  local current_dir = current_file:match("(.*/)") or "."
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

local toml = loadfile_relative("tinytoml.lua")

local watchers = {}
local config = nil
local logger = hs.logger.new("folderwatcher", "info")

-- Expand tilde in paths
local function expandPath(path)
  if path:sub(1,1) == "~" then
    return os.getenv("HOME") .. path:sub(2)
  end
  return path
end

-- Check if filename matches any pattern in list
local function matchesPattern(filename, patterns)
  if not patterns or #patterns == 0 then
    return true
  end
  
  for _, pattern in ipairs(patterns) do
    if string.match(filename, glob_to_pattern(pattern)) then
      return true
    end
  end
  return false
end

-- Convert glob pattern to Lua pattern
function glob_to_pattern(glob)
  local pattern = glob:gsub("([%.%+%-%?%[%]%^%$%(%)%%])", "%%%1")
  pattern = pattern:gsub("%*", ".*")
  pattern = "^" .. pattern .. "$"
  return pattern
end

-- Execute script with proper error handling
local function executeScript(scriptPath, eventType, filePath)
  if not scriptPath then
    return
  end
  
  local expandedScript = expandPath(scriptPath)
  local fileName = filePath:match("([^/]+)$") or filePath
  
  -- Check if script exists
  if not hs.fs.attributes(expandedScript) then
    logger.e("Script not found: " .. expandedScript)
    return
  end
  
  -- Build command with arguments
  local cmd = string.format('"%s" "%s" "%s" "%s"', 
    expandedScript, eventType, filePath, fileName)
  
  -- Add environment variables from config
  local env = ""
  if config.settings and config.settings.script_environment then
    for k, v in pairs(config.settings.script_environment) do
      env = env .. string.format('%s="%s" ', k, v)
    end
  end
  
  if env ~= "" then
    cmd = env .. cmd
  end
  
  logger.i("Executing: " .. cmd)
  
  -- Execute asynchronously
  local task = hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
      logger.e("Script failed: " .. expandedScript)
      logger.e("Exit code: " .. exitCode)
      logger.e("Error: " .. (stdErr or ""))
    else
      logger.i("Script completed: " .. expandedScript)
      if config.settings.debug and stdOut and stdOut ~= "" then
        logger.i("Output: " .. stdOut)
      end
    end
  end, {"-c", cmd})
  
  -- Set timeout if configured
  if config.settings and config.settings.script_timeout then
    hs.timer.doAfter(config.settings.script_timeout, function()
      if task:isRunning() then
        task:terminate()
        logger.e("Script timed out: " .. expandedScript)
      end
    end)
  end
  
  task:start()
end

-- Callback for file events
local function createCallback(watcherConfig)
  return function(files)
    for _, file in ipairs(files) do
      local filename = file:match("([^/]+)$") or file
      local attr = hs.fs.attributes(file)
      
      -- Apply filters
      local included = true
      local excluded = false
      
      if watcherConfig.filters then
        if watcherConfig.filters.include then
          included = matchesPattern(filename, watcherConfig.filters.include)
        end
        if watcherConfig.filters.exclude then
          excluded = matchesPattern(filename, watcherConfig.filters.exclude)
        end
      end
      
      if not included or excluded then
        if config.settings.debug then
          logger.i("Filtered out: " .. file)
        end
        goto continue
      end
      
      -- Determine event type
      local eventType
      if not attr then
        eventType = "deleted"
      elseif attr.modification == attr.creation then
        eventType = "created"
      elseif attr.modification > attr.creation then
        eventType = "modified"
      else
        eventType = "changed"
      end
      
      
      if config.settings.debug then
        logger.i(string.format("[%s] %s: %s", watcherConfig.name, eventType, file))
      end
      
      -- Show notification if enabled
      if config.settings.notification then
        hs.notify.new({
          title = string.format("[%s] File %s", watcherConfig.name, eventType),
          informativeText = filename
        }):send()
      end
      
      -- Execute appropriate script
      if watcherConfig.scripts then
        local scriptKey = "on_" .. eventType
        executeScript(watcherConfig.scripts[scriptKey], eventType, file)
      end
      
      ::continue::
    end
  end
end

-- Load configuration
function folderwatcher.loadConfig(configPath)
  configPath = configPath or hs.configdir .. "/folderwatcher/config.toml"
  
  -- Check if file exists
  local f = io.open(configPath, "r")
  if not f then
    logger.e("Config file not found: " .. configPath)
    return false
  end
  f:close()
  
  -- Parse TOML using tinytoml like Hammerflow does
  local ok, result = pcall(function() return toml.parse(configPath) end)
  if not ok then
    logger.e("Failed to parse config: " .. result)
    return false
  end
  
  config = result
  logger.i("Config loaded successfully")
  return true
end

-- Start watching all configured folders
function folderwatcher.start()
  if not config then
    if not folderwatcher.loadConfig() then
      return false
    end
  end
  
  -- Stop existing watchers
  folderwatcher.stop()
  
  -- Create watchers for each configured path
  for _, watcherConfig in ipairs(config.watchers or {}) do
    if watcherConfig.enabled ~= false then
      local path = expandPath(watcherConfig.path)
      
      -- Check if path exists
      if not hs.fs.attributes(path) then
        logger.e("Path does not exist: " .. path)
        goto continue
      end
      
      local watcher = hs.pathwatcher.new(path, createCallback(watcherConfig))
      
      if watcher:start() then
        logger.i("Started watching: " .. path .. " (" .. watcherConfig.name .. ")")
        table.insert(watchers, {
          watcher = watcher,
          config = watcherConfig
        })
      else
        logger.e("Failed to start watcher for: " .. path)
      end
    end
    
    ::continue::
  end
  
  return true
end

-- Stop all watchers
function folderwatcher.stop()
  for _, w in ipairs(watchers) do
    w.watcher:stop()
    logger.i("Stopped watching: " .. w.config.path)
  end
  watchers = {}
end

-- Reload configuration and restart
function folderwatcher.reload()
  logger.i("Reloading configuration...")
  folderwatcher.stop()
  config = nil
  return folderwatcher.start()
end

-- Get status of all watchers
function folderwatcher.status()
  local status = {}
  for _, w in ipairs(watchers) do
    table.insert(status, {
      name = w.config.name,
      path = w.config.path,
      running = w.watcher:running()
    })
  end
  return status
end

return folderwatcher