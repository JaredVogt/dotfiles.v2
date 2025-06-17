-- Example of a true click-through overlay using hs.drawing
-- This is limited compared to webview but allows click-through

local function showClickThroughText(message, duration)
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    
    -- Create a text drawing
    local text = hs.drawing.text(
        {x = frame.w - 300, y = 50, w = 250, h = 100},
        message
    )
    
    -- Style the text
    text:setTextColor({red=1, green=1, blue=1, alpha=0.9})
    text:setTextSize(24)
    text:setTextStyle({
        alignment = "center",
        lineBreak = "wordWrap"
    })
    
    -- This is the key: drawing objects don't capture mouse events
    text:setLevel(hs.drawing.windowLevels.overlay)
    text:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    text:show()
    
    -- Auto-dismiss
    if duration then
        hs.timer.doAfter(duration, function()
            text:delete()
        end)
    end
    
    return text
end

-- Usage
-- showClickThroughText("This text is click-through!", 5)