-- Notification Manager
local Notifications = {}

--- Send a notification to player
---@param title string - Notification title
---@param message string - Notification message
---@param notificationType string - Type: 'success', 'error', 'info', 'warning'
---@param duration number - Duration in milliseconds (optional)
function Notifications.Send(title, message, notificationType, duration)
    local config = Config.Notifications
    duration = duration or config.duration
    notificationType = notificationType or 'info'
    
    if not config.enabled then
        return
    end
    
    if config.type == 'ox_lib' then
        lib.notify({
            title = title,
            description = message,
            type = notificationType,
            position = config.position,
            duration = duration,
        })
    elseif config.type == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.Notify(message, notificationType, duration)
    end
end

--- Send success notification
function Notifications.Success(title, message, duration)
    Notifications.Send(title, message, 'success', duration)
end

--- Send error notification
function Notifications.Error(title, message, duration)
    Notifications.Send(title, message, 'error', duration)
end

--- Send info notification
function Notifications.Info(title, message, duration)
    Notifications.Send(title, message, 'info', duration)
end

--- Send warning notification
function Notifications.Warning(title, message, duration)
    Notifications.Send(title, message, 'warning', duration)
end

return Notifications
