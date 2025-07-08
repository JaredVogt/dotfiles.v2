-- Cursor window switcher generator
-- Returns a list of Cursor editor windows that can be focused
-- Always fetches fresh data (no caching)

return function(args)
  local items = {}
  
  -- Run AppleScript to get Cursor windows
  local ok, result = hs.osascript.applescript([[
    tell application "System Events"
      set cursorWindows to name of windows of application process "Cursor"
    end tell
  ]])
  
  if ok and result then
    -- Result is an array of window names
    for _, windowName in ipairs(result) do
      table.insert(items, {
        label = windowName,
        icon = "cursor.png",
        action = {
          type = "km",
          macro = "CursorWindows",
          variables = {
            CursorWindowName = windowName
          }
        }
      })
    end
  end
  
  return items
end