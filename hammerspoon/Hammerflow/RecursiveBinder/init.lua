--- === RecursiveBinder ===
---
--- A spoon that let you bind sequential bindings.
--- It also (optionally) shows a bar about current keys bindings.
---
--- [Click to download](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/RecursiveBinder.spoon.zip)

local obj={}
obj.__index = obj


-- Metadata
obj.name = "RecursiveBinder"
obj.version = "0.7"
obj.author = "Yuan Fu <casouri@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"


--- RecursiveBinder.escapeKey
--- Variable
--- key to abort, default to {keyNone, 'escape'}
obj.escapeKey = {keyNone, 'escape'}

--- RecursiveBinder.helperEntryEachLine
--- Variable
--- Number of entries each line of helper. Default to 5.
obj.helperEntryEachLine = 5

--- RecursiveBinder.helperEntryLengthInChar
--- Variable
--- Length of each entry in char. Default to 20.
obj.helperEntryLengthInChar = 20

--- RecursiveBinder.helperFormat
--- Variable
--- format of helper, the helper is just a hs.alert
--- default to {atScreenEdge=2,
---             strokeColor={ white = 0, alpha = 2 },
---             textFont='SF Mono'
---             textSize=20}
obj.helperFormat = {atScreenEdge=2,
                    strokeColor={ white = 0, alpha = 2 },
                    textFont='Courier',
                    textSize=20}

--- RecursiveBinder.showBindHelper()
--- Variable
--- whether to show helper, can be true of false
obj.showBindHelper = true

--- RecursiveBinder.displayMode
--- Variable
--- Display mode for the helper: "webview" or "text"
--- Default to "webview"
obj.displayMode = "webview"

--- RecursiveBinder.helperModifierMapping()
--- Variable
--- The mapping used to display modifiers on helper.
--- Default to {
---  command = '⌘',
---  control = '⌃',
---  option = '⌥',
---  shift = '⇧',
--- }
obj.helperModifierMapping = {
   command = '⌘',
   control = '⌃',
   option = '⌥',
   shift = '⇧',
}

-- used by next model to close previous helper
local previousHelperID = nil

-- track if modal is currently active for toggle functionality
local modalActive = false

-- webview for grid display
local gridWebview = nil

-- this function is used by helper to display 
-- appropriate 'shift + key' bindings
-- it turns a lower key to the corresponding
-- upper key on keyboard
local function keyboardUpper(key)
   local upperTable = {
    a='A', 
    b='B', 
    c='C', 
    d='D', 
    e='E', 
    f='F', 
    g='G', 
    h='H', 
    i='I', 
    j='J', 
    k='K', 
    l='L', 
    m='M', 
    n='N', 
    o='O', 
    p='P', 
    q='Q', 
    r='R', 
    s='S', 
    t='T', 
    u='U', 
    v='V', 
    w='W', 
    x='X', 
    y='Y', 
    z='Z', 
    ['`']='~',
    ['1']='!',
    ['2']='@',
    ['3']='#',
    ['4']='$',
    ['5']='%',
    ['6']='^',
    ['7']='&',
    ['8']='*',
    ['9']='(',
    ['0']=')',
    ['-']='_',
    ['=']='+',
    ['[']='}',
    [']']='}',
    ['\\']='|',
    [';']=':',
    ['\'']='"',
    [',']='<',
    ['.']='>',
    ['/']='?'
   }
   uppperKey = upperTable[key]
   if uppperKey then
      return uppperKey
   else
      return key
   end
end

--- RecursiveBinder.singleKey(key, name)
--- Method
--- this function simply return a table with empty modifiers also it translates capital letters to normal letter with shift modifer
---
--- Parameters:
---  * key - a letter
---  * name - the description to pass to the keys binding function
---
--- Returns:
---  * a table of modifiers and keys and names, ready to be used in keymap
---    to pass to RecursiveBinder.recursiveBind()
function obj.singleKey(key, name)
   local mod = {}
   if key == keyboardUpper(key) and string.len(key) == 1 then
      mod = {'shift'}
      key = string.lower(key)
   end

   if name then
      return {mod, key, name}
   else
      return {mod, key, 'no name'}
   end
end


-- generate a string representation of a key spec
-- {{'shift', 'command'}, 'a} -> 'shift+command+a'
local function createKeyName(key)
   -- key is in the form {{modifers}, key, (optional) name}
   -- create proper key name for helper
   local modifierTable = key[1]
   local keyString = key[2]
   -- add a little mapping for space
   if keyString == 'space' then keyString = 'SPC' end
   -- If it's a single letter with only shift modifier, show as uppercase
   if #modifierTable == 1 and modifierTable[1] == 'shift' and string.len(keyString) == 1 then
      -- shift + key map to Uppercase key
      -- shift + d --> D
      return keyboardUpper(keyString)
   else
      -- append each modifiers together
      local keyName = ''
      if #modifierTable >= 1 then
         for count = 1, #modifierTable do
            local modifier = modifierTable[count]
            if count == 1 then
               keyName = obj.helperModifierMapping[modifier]..' + '
            else 
               keyName = keyName..obj.helperModifierMapping[modifier]..' + '
            end
         end
      end
      -- finally append key, e.g. 'f', after modifers
      return keyName..keyString
   end
end

-- Function to compare two letters
-- It sorts according to the ASCII code, and for letters, it will be alphabetical
-- However, for capital letters (65-90), I'm adding 32.5 (this came from 97 - 65 + 0.5, where 97 is a and 65 is A) to the ASCII code before comparing
-- This way, each capital letter comes after the corresponding simple letter but before letters that come after it in the alphabetical order
local function compareLetters(a, b)
   local asciiA = string.byte(a)
   local asciiB = string.byte(b)
   if asciiA >= 65 and asciiA <= 90 then
       asciiA = asciiA + 32.5
   end
   if asciiB >= 65 and asciiB <= 90 then
       asciiB = asciiB + 32.5
   end
   return asciiA < asciiB
end

-- format bindings as grid layout
local function formatBindingsAsGrid(keymap)
  local MAX_COLS = obj.maxColumns or 7
  local KEY_LABEL_SEP = obj.gridSeparator or " : "
  local COL_SPACING = obj.gridSpacing or "   "
  local items = {}
  
  -- Collect and sort items
  for key, binding in pairs(keymap) do
    -- Based on Hammerflow's singleKey structure: key = {mode, keyChar, label}
    local keyChar = key[2] or "?"
    -- Check if this is an uppercase key (shift modifier with single lowercase letter)
    if #key[1] == 1 and key[1][1] == 'shift' and string.len(keyChar) == 1 then
       keyChar = string.upper(keyChar)
    end
    local label = key[3] or keyChar
    local icon = nil
    if type(binding) == "table" and binding.icon then
      icon = binding.icon
    end
    table.insert(items, {key = keyChar, label = label, icon = icon})
  end
  
  -- Sort alphabetically by key
  table.sort(items, function(a, b) return a.key < b.key end)
  
  if #items == 0 then return "" end
  
  -- Calculate grid dimensions
  local numCols = math.min(#items, MAX_COLS)
  local numRows = math.ceil(#items / numCols)
  
  -- Create grid structure and calculate column widths
  local grid = {}
  local colWidths = {}
  
  -- Initialize column widths
  for col = 1, numCols do
    colWidths[col] = 0
  end
  
  -- Fill grid and find max width per column
  for row = 1, numRows do
    grid[row] = {}
    for col = 1, numCols do
      local itemIndex = (row - 1) * numCols + col
      if itemIndex <= #items then
        local item = items[itemIndex]
        local cellContent = item.key .. KEY_LABEL_SEP .. item.label
        grid[row][col] = cellContent
        
        -- Update column width if this entry is wider
        colWidths[col] = math.max(colWidths[col], string.len(cellContent))
      else
        grid[row][col] = nil -- Empty cell
      end
    end
  end
  
  -- Build final formatted rows
  local rows = {}
  for row = 1, numRows do
    local rowItems = {}
    for col = 1, numCols do
      if grid[row][col] then
        -- Left-align and pad to column width
        local padded = grid[row][col] .. string.rep(" ", colWidths[col] - string.len(grid[row][col]))
        table.insert(rowItems, padded)
      else
        -- Empty cell - maintain alignment
        table.insert(rowItems, string.rep(" ", colWidths[col]))
      end
    end
    table.insert(rows, table.concat(rowItems, COL_SPACING))
  end
  
  return table.concat(rows, "\n")
end

-- show helper of available keys of current layer
local function showHelper(keyFuncNameTable, keyFuncSortTable)
   -- keyFuncNameTable is a table that key is key name and value is description
   -- keyFuncSortTable is a table that maps key names to sort keys
   local helper = ''
   local separator = '' -- first loop doesn't need to add a separator, because it is in the very front. 
   local lastLine = ''
   local count = 0

   local sortedKeyFuncNameTable = {}
   for keyName, funcName in pairs(keyFuncNameTable) do
       local sortKey = keyFuncSortTable and keyFuncSortTable[keyName] or keyName
       table.insert(sortedKeyFuncNameTable, {keyName = keyName, funcName = funcName, sortKey = sortKey})
   end
   
   -- Sort by sortKey if available, otherwise use compareLetters for backward compatibility
   if keyFuncSortTable then
      table.sort(sortedKeyFuncNameTable, function(a, b) return a.sortKey < b.sortKey end)
   else
      table.sort(sortedKeyFuncNameTable, function(a, b) return compareLetters(a.keyName, b.keyName) end)
   end

   for _, value in ipairs(sortedKeyFuncNameTable) do
      local keyName = value.keyName
      local funcName = value.funcName
      count = count + 1
      local newEntry = keyName..' → '..funcName
      -- make sure each entry is of the same length
      if string.len(newEntry) > obj.helperEntryLengthInChar then
         newEntry = string.sub(newEntry, 1, obj.helperEntryLengthInChar - 2)..'..'
      elseif string.len(newEntry) < obj.helperEntryLengthInChar then
         newEntry = newEntry..string.rep(' ', obj.helperEntryLengthInChar - string.len(newEntry))
      end
      -- create new line for every helperEntryEachLine entries
      if count % (obj.helperEntryEachLine + 1) == 0 then
         separator = '\n '
      elseif count == 1 then
         separator = ' '
      else
         separator = '  '
      end
      helper = helper..separator..newEntry
   end
   helper = string.match(helper, '[^\n].+$')
   previousHelperID = hs.alert.show(helper, obj.helperFormat, true)
end

local function killHelper()
   hs.alert.closeSpecific(previousHelperID)
   if gridWebview then
      gridWebview:delete()
      gridWebview = nil
   end
end

-- create webview grid display
local function showWebviewGrid(keymap)
   -- Close existing webview if present
   if gridWebview then
      gridWebview:delete()
   end
   
   local MAX_COLS = obj.maxColumns or 7
   local items = {}
   
   -- Collect and sort items
   for key, binding in pairs(keymap) do
      local keyChar = key[2] or "?"
      -- Check if this is an uppercase key (shift modifier with single lowercase letter)
      if #key[1] == 1 and key[1][1] == 'shift' and string.len(keyChar) == 1 then
         keyChar = string.upper(keyChar)
      end
      local label = key[3] or keyChar
      local icon = nil
      local sortKey = keyChar  -- default to the display key
      
      if type(binding) == "table" then
        if binding.icon then
          icon = binding.icon
        end
        if binding.sortKey then
          sortKey = binding.sortKey  -- use explicit sort key if provided
        end
      end
      
      table.insert(items, {
        key = keyChar, 
        label = label, 
        icon = icon,
        sortKey = sortKey  -- add sort key to item
      })
   end
   
   -- Sort by sortKey instead of key
   table.sort(items, function(a, b) return a.sortKey < b.sortKey end)
   
   if #items == 0 then return end
   
   -- Find the longest label and check for icons to calculate dynamic width
   local maxLabelLength = 0
   local hasIcons = false
   for _, item in ipairs(items) do
      local fullText = item.key .. " : " .. item.label
      maxLabelLength = math.max(maxLabelLength, string.len(fullText))
      if item.icon then
         hasIcons = true
      end
   end
   
   -- Calculate grid dimensions
   local numCols = math.min(#items, MAX_COLS)
   local numRows = math.ceil(#items / numCols)
   
   -- Generate HTML
   local html = [[
   <!DOCTYPE html>
   <html>
   <head>
       <style>
           html, body {
               background: transparent !important;
               background-color: transparent !important;
           }
           body {
               font-family: 'Menlo', monospace;
               font-size: 48px;
               margin: 0;
               padding: 20px;
               color: white;
               overflow: hidden;
           }
           .grid-container {
               display: grid;
               grid-template-columns: repeat(]] .. numCols .. [[, 1fr);
               gap: 30px 60px;
               justify-items: start;
               align-items: center;
               background-color: rgba(0, 0, 0, 0.6);
               border-radius: 12px;
               padding: 20px;
               border: 5px solid #00ff00;
               box-sizing: border-box;
               position: relative;
               overflow: hidden;
           }
           .grid-container::before {
               content: '';
               position: absolute;
               top: 0;
               left: 0;
               right: 0;
               bottom: 0;
               background-image: url('BACKGROUND_IMAGE_URL');
               background-position: BACKGROUND_POSITION;
               background-size: BACKGROUND_SIZE;
               background-repeat: no-repeat;
               opacity: BACKGROUND_OPACITY;
               z-index: -1;
               border-radius: 12px;
           }
           .grid-cell {
               display: flex;
               align-items: center;
               white-space: nowrap;
               cursor: pointer;
               padding: 8px 12px;
               border-radius: 8px;
               transition: all 0.2s ease;
               background: transparent;
           }
           .icon {
               width: 48px;
               height: 48px;
               margin-right: 12px;
               object-fit: contain;
           }
           .grid-cell:hover {
               background: rgba(255, 255, 255, 0.1);
               transform: scale(1.05);
           }
           .key {
               color: #00ff00;
               font-weight: bold;
               text-shadow: 0 0 10px #00ff00;
           }
           .separator {
               color: #888;
               margin: 0 8px;
           }
           .label {
               color: #ffffff;
           }
       </style>
   </head>
   <body>
       <div class="grid-container">
   ]]
   
   -- Load background image using config settings
   local backgroundImageData = "none"
   local backgroundOpacity = obj.backgroundOpacity or 0.6
   local backgroundPosition = obj.backgroundPosition or "center center"
   local backgroundSize = obj.backgroundSize or "cover"
   
   if obj.backgroundImage then
      -- Use configured image filename
      local home = os.getenv("HOME")
      local backgroundPath = home .. "/projects/dotfiles.v2/hammerspoon/Hammerflow/images/" .. obj.backgroundImage
      local bgFile = io.open(backgroundPath, "rb")
      if bgFile then
         local imageData = bgFile:read("*all")
         bgFile:close()
         local base64 = hs.base64.encode(imageData)
         
         -- Get proper MIME type
         local extension = obj.backgroundImage:match("%.(%w+)$"):lower()
         local mimeType = "image/jpeg" -- default
         if extension == "png" then
            mimeType = "image/png"
         elseif extension == "gif" then
            mimeType = "image/gif"
         elseif extension == "webp" then
            mimeType = "image/webp"
         end
         
         backgroundImageData = "data:" .. mimeType .. ";base64," .. base64
      end
   else
      -- Fallback: try default filenames (for backward compatibility)
      local home = os.getenv("HOME")
      local backgroundFormats = {"background.gif", "background.png", "background.jpg", "background.jpeg", "background.webp"}
      
      for _, filename in ipairs(backgroundFormats) do
         local backgroundPath = home .. "/projects/dotfiles.v2/hammerspoon/Hammerflow/images/" .. filename
         local bgFile = io.open(backgroundPath, "rb")
         if bgFile then
            local imageData = bgFile:read("*all")
            bgFile:close()
            local base64 = hs.base64.encode(imageData)
            
            -- Get proper MIME type
            local extension = filename:match("%.(%w+)$"):lower()
            local mimeType = "image/jpeg" -- default
            if extension == "png" then
               mimeType = "image/png"
            elseif extension == "gif" then
               mimeType = "image/gif"
            elseif extension == "webp" then
               mimeType = "image/webp"
            end
            
            backgroundImageData = "data:" .. mimeType .. ";base64," .. base64
            break -- Use the first one found
         end
      end
   end
   
   -- Replace placeholders with actual background settings
   html = html:gsub("BACKGROUND_IMAGE_URL", backgroundImageData)
   html = html:gsub("BACKGROUND_POSITION", backgroundPosition)
   html = html:gsub("BACKGROUND_SIZE", backgroundSize)
   html = html:gsub("BACKGROUND_OPACITY", tostring(backgroundOpacity))
   
   -- Add grid items
   for i, item in ipairs(items) do
      local iconHtml = ""
      if item.icon then
         local home = os.getenv("HOME")
         local iconFilePath = home .. "/projects/dotfiles.v2/hammerspoon/Hammerflow/images/" .. item.icon
         
         -- Try to read and encode image as base64
         local file = io.open(iconFilePath, "rb")
         if file then
            local imageData = file:read("*all")
            file:close()
            local base64 = hs.base64.encode(imageData)
            local extension = item.icon:match("%.(%w+)$"):lower()
            local mimeType = "image/jpeg" -- default
            if extension == "png" then
              mimeType = "image/png"
            elseif extension == "gif" then
              mimeType = "image/gif"
            elseif extension == "webp" then
              mimeType = "image/webp"
            elseif extension == "svg" then
              mimeType = "image/svg+xml"
            end
            iconHtml = string.format('<img src="data:%s;base64,%s" class="icon">', mimeType, base64)
         else
            print("Could not read image file: " .. iconFilePath)
         end
      end
      html = html .. string.format([[
           <div class="grid-cell" onclick="executeAction('%s')">
               %s<span class="key">%s</span>
               <span class="separator">:</span>
               <span class="label">%s</span>
           </div>
      ]], item.key, iconHtml, item.key, item.label)
   end
   
   html = html .. [[
       </div>
       <script>
           function executeAction(key) {
               window.location.href = 'hammerflow://key/' + key;
           }
           
           // Close on escape key
           document.addEventListener('keydown', function(e) {
               if (e.key === 'Escape') {
                   window.close();
               } else {
                   executeAction(e.key);
               }
           });
           
           // Auto-focus for keyboard events
           window.focus();
       </script>
   </body>
   </html>
   ]]
   
   -- Create webview
   local screen = hs.screen.mainScreen()
   local screenFrame = screen:frame()
   
   -- Calculate size based on content - ensure it fits everything
   local baseCharWidth = 18  -- Increased character width for Menlo 48px font
   local iconWidth = hasIcons and 60 or 0  -- 48px icon + 12px margin if icons present
   local cellWidth = math.max(300, maxLabelLength * baseCharWidth + 100 + iconWidth)  -- Dynamic width with icon consideration
   local cellHeight = 100  -- Height per cell
   local padding = 60     -- Padding around content
   local gapWidth = 80    -- Gap between columns
   local gapHeight = 40   -- Gap between rows
   
   local webviewWidth = (numCols * cellWidth) + ((numCols - 1) * gapWidth) + (padding * 2)
   local webviewHeight = (numRows * cellHeight) + ((numRows - 1) * gapHeight) + (padding * 2)
   
   
   -- Ensure it doesn't exceed screen bounds, but prioritize showing all content
   webviewWidth = math.min(webviewWidth, screenFrame.w * 0.95)
   webviewHeight = math.min(webviewHeight, screenFrame.h * 0.9)
   
   local webviewFrame = {
      x = screenFrame.x + (screenFrame.w - webviewWidth) / 2,
      y = screenFrame.y + (screenFrame.h - webviewHeight) / 2,
      w = webviewWidth,
      h = webviewHeight
   }
   
   gridWebview = hs.webview.new(webviewFrame)
      :windowStyle({"borderless"})
      :allowTextEntry(true)
      :level(hs.drawing.windowLevels.overlay)
      :transparent(true)
      :html(html)
      :show()
      :bringToFront(true)
   
   -- Set up keyboard event handler using windowCallback
   gridWebview:windowCallback(function(action, webview, ...)
      if action == "closing" then
         modalActive = false
      end
   end)
   
   -- Set up navigation to handle key presses via URL changes
   gridWebview:navigationCallback(function(action, webview, navID, url)
      if action == "didReceiveServerRedirect" or action == "didCommit" then
         local keyPressed = url:match("hammerflow://key/(.)")
         if keyPressed then
            gridWebview:delete()
            gridWebview = nil
            modalActive = false
            
            -- Find and execute the corresponding action
            for key, binding in pairs(keymap) do
               if key[2] == keyPressed then
                  local modal = hs.hotkey.modal.new()
                  local actionBinding = binding
                  if type(binding) == "table" and binding.action then
                     actionBinding = binding.action
                  end
                  local func = obj.recursiveBind(actionBinding, {modal})
                  func()
                  break
               end
            end
            return false  -- Don't actually navigate
         end
      end
      return true
   end)
end

--- RecursiveBinder.recursiveBind(keymap)
--- Method
--- Bind sequential keys by a nested keymap.
---
--- Parameters:
---  * keymap - A table that specifies the mapping.
---
--- Returns:
---  * A function to start. Bind it to a initial key binding.
---
--- Note:
--- Spec of keymap:
--- Every key is of format {{modifers}, key, (optional) description}
--- The first two element is what you usually pass into a hs.hotkey.bind() function.
--- 
--- Each value of key can be in two form:
--- 1. A function. Then pressing the key invokes the function
--- 2. A table. Then pressing the key bring to another layer of keybindings.
---    And the table have the same format of top table: keys to keys, value to table or function

-- the actual binding function
function obj.recursiveBind(keymap, modals)
   if not modals then modals = {} end
   if type(keymap) == 'function' then
      -- in this case "keymap" is actuall a function
      return keymap
   end
   local modal = hs.hotkey.modal.new()
   table.insert(modals, modal)
   local keyFuncNameTable = {}
   local keyFuncSortTable = {}  -- For sorting in text mode
   for key, map in pairs(keymap) do
      print("[debug] RecursiveBinder processing key:", key[2] or "unknown", "map type:", type(map))
      local actualMap = map
      local sortKey = nil
      if type(map) == "table" then
         print("[debug] Map is table, checking for action or keyMap")
         if map.action then
            print("[debug] Found action, type:", type(map.action))
            actualMap = map.action
         elseif map.keyMap then
            print("[debug] Found keyMap (group)")
            actualMap = map.keyMap
         else
            print("[debug] Table has no action or keyMap - keys:", table.concat(hs.fnutils.keys(map), ", "))
         end
         if map.sortKey then
            sortKey = map.sortKey
         end
      end
      local func = obj.recursiveBind(actualMap, modals)
      -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f' 
      modal:bind(key[1], key[2], function() modal:exit() killHelper() modalActive = false func() end)
      modal:bind(obj.escapeKey[1], obj.escapeKey[2], function() modal:exit() killHelper() modalActive = false end)
      if #key >= 3 then
         local keyName = createKeyName(key)
         keyFuncNameTable[keyName] = key[3]
         keyFuncSortTable[keyName] = sortKey or keyName  -- Use sortKey if available, otherwise keyName
      end
   end
   return function()
      -- Toggle behavior: if modal is active, close it; if inactive, open it
      if modalActive then
         -- Close the modal
         modal:exit()
         killHelper()
         modalActive = false
      else
         -- Open the modal
         -- exit all modals, accounts for pressing the leader key while in a modal
         for _, m in ipairs(modals) do
            m:exit()
         end
         modal:enter()
         modalActive = true
         killHelper()
         if obj.showBindHelper then
            if obj.displayMode == "text" then
               showHelper(keyFuncNameTable, keyFuncSortTable)
            else
               showWebviewGrid(keymap)
            end
         end
      end
   end
end


-- function testrecursiveModal(keymap)
--    print(keymap)
--    if type(keymap) == 'number' then
--       return keymap
--    end
--    print('make new modal')
--    for key, map in pairs(keymap) do
--       print('key', key, 'map', testrecursiveModal(map))
--    end
--    return 0
-- end

-- mymap = {f = { r = 1, m = 2}, s = {r = 3, m = 4}, m = 5}
-- testrecursiveModal(mymap)


return obj
