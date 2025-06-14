-- folderwatcher.lua
-- Watches ~/Downloads using hs.pathwatcher
-- Infers Created / Modified / Deleted based on fs attributes and sends a notification

local folderwatcher = {}

local watchPath = os.getenv("HOME") .. "/Downloads"
local watcher = nil

-- callback function triggered on file events
local function onFilesChanged(files)
  for _, file in ipairs(files) do
    local attr = hs.fs.attributes(file)

    local eventType

    if not attr then
      eventType = "Deleted"
    elseif attr.modification == attr.creation then
      eventType = "Created"
    elseif attr.modification > attr.creation then
      eventType = "Modified"
    else
      eventType = "Changed"
    end

    hs.notify.new({
      title = "File " .. eventType,
      informativeText = file
    }):send()
  end
end

-- Start watching
function folderwatcher.start()
  if watcher then
    watcher:stop()
  end
  watcher = hs.pathwatcher.new(watchPath, onFilesChanged)
  watcher:start()
end

-- Stop watching
function folderwatcher.stop()
  if watcher then
    watcher:stop()
    watcher = nil
  end
end

return folderwatcher-- folderwatcher.lua
