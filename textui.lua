-- Text UI Manager
local TextUI = {}

--- Show text UI
---@param text string - Text to display
---@param icon string - Font Awesome icon (optional)
function TextUI.Show(text, icon)
    local config = Config.TextUI
    
    if not config.enabled then
        return
    end
    
    if config.type == 'ox_lib' then
        local options = {
            position = config.position,
            style = config.style,
        }
        
        if icon then
            options.icon = icon
        end
        
        lib.showTextUI(text, options)
    end
end

--- Hide text UI
function TextUI.Hide()
    local config = Config.TextUI
    
    if not config.enabled then
        return
    end
    
    if config.type == 'ox_lib' then
        lib.hideTextUI()
    end
end

--- Check if text UI is open
---@return boolean - True if text UI is open
function TextUI.IsOpen()
    local config = Config.TextUI
    
    if not config.enabled then
        return false
    end
    
    if config.type == 'ox_lib' then
        local isOpen = lib.isTextUIOpen()
        return isOpen
    end
    
    return false
end

return TextUI
