-- Minigame system with multiple difficulty options
local MinigameActive = false
local MinigameResult = nil

-- Start fishing minigame
function StartFishingMinigame(cageId, depth)
    MinigameActive = true
    MinigameResult = nil
    
    -- Get difficulty based on depth
    local difficulty = GetDifficultyFromDepth(depth)
    
    lib.notify({
        type = 'info',
        title = 'Fishing',
        description = 'Minigame starting - Difficulty: ' .. difficulty:upper(),
        duration = 2000,
    })
    
    -- Run appropriate minigame
    local success = RunSkillCheck(difficulty)
    
    MinigameActive = false
    MinigameResult = success
    
    if success then
        TriggerServerEvent('fishing:catchFish', cageId, depth)
    else
        lib.notify({
            type = 'error',
            title = 'Fishing Failed',
            description = 'You missed the fish!',
            duration = 3000,
        })
    end
end

-- Get difficulty from depth
function GetDifficultyFromDepth(depth)
    local difficulties = {
        shallow = 'easy',
        medium = 'medium',
        deep = 'hard',
        verydeep = 'hard',
    }
    
    return difficulties[depth] or 'medium'
end

-- Run skill check minigame
function RunSkillCheck(difficulty)
    if not Config.Minigames.enabled then
        -- Bypass minigame - direct success
        return true
    end
    
    local difficulties = {
        easy = {'easy', {areaSize = 100, speedMultiplier = 0.8}},
        medium = {'medium', {areaSize = 60, speedMultiplier = 1.0}},
        hard = {'hard', {areaSize = 40, speedMultiplier = 1.3}},
    }
    
    local skillDiff = difficulties[difficulty] or difficulties.medium
    
    -- Run the minigame
    local success = lib.skillCheck(skillDiff, {'w', 'a', 's', 'd'})
    
    return success
end

-- Alternative minigame: Button Mash (compatibility with other systems)
function RunButtonMash(difficulty, duration)
    duration = duration or 3000
    
    lib.notify({
        type = 'info',
        title = 'Fishing',
        description = 'Mash E to catch fish!',
        duration = 1000,
    })
    
    local startTime = GetGameTimer()
    local presses = 0
    local requiredPresses = {
        easy = 5,
        medium = 10,
        hard = 20,
    }
    
    local required = requiredPresses[difficulty] or 10
    
    while (GetGameTimer() - startTime) < duration do
        if IsControlJustReleased(0, 38) then -- E key
            presses = presses + 1
        end
        
        lib.showTextUI('[E] Presses: ' .. presses .. '/' .. required)
        Wait(10)
    end
    
    lib.hideTextUI()
    
    return presses >= required
end

-- Prompt-based minigame
function RunPromptMinigame(depth)
    local prompts = {
        'Quick! Press E!',
        'Reel it in!',
        'Hold on tight!',
        'Don\'t let go!',
        'Keep tension on the line!',
    }
    
    local prompt = prompts[math.random(#prompts)]
    lib.showTextUI(prompt)
    
    local timeout = GetGameTimer() + 2000
    while GetGameTimer() < timeout do
        if IsControlJustReleased(0, 38) then -- E key
            lib.hideTextUI()
            return true
        end
        Wait(0)
    end
    
    lib.hideTextUI()
    return false
end

-- Reaction time minigame
function RunReactionMinigame()
    Wait(math.random(500, 2000)) -- Random delay
    
    lib.showTextUI('~r~NOW!')
    
    local startTime = GetGameTimer()
    local timeout = startTime + 1500
    
    while GetGameTimer() < timeout do
        if IsControlJustReleased(0, 38) then -- E key
            local reactionTime = GetGameTimer() - startTime
            lib.hideTextUI()
            
            -- Success if under 800ms
            return reactionTime < 800
        end
        Wait(0)
    end
    
    lib.hideTextUI()
    return false
end

-- Get minigame result
function GetMinigameResult()
    return MinigameResult
end

-- Is minigame active
function IsMinigameActive()
    return MinigameActive
end

-- Register custom minigame (for extensibility)
function RegisterCustomMinigame(name, callback)
    if Config.Minigames[name] then
        return false
    end
    
    Config.Minigames[name] = callback
    return true
end

if Config.Debug then
    print('^2[Fishing Minigames] Client loaded^7')
end
