local QBCore = exports['qb-core']:GetCoreObject()
local PlayerCages = {}
local CurrentMenu = nil
local IsFishing = false

local Notifications = require 'shared.notifications'
local TextUI = require 'client.textui'
local Leaderboards = require 'shared.leaderboards'

-- Player challenge tracking
local PlayerChallenges = {}

-- Wait for QBCore
Wait(100)

-- Main fishing menu
local function OpenFishingMenu(cageId)
    local cage = PlayerCages[cageId]
    if not cage then return end
    
    CurrentMenu = {
        {
            title = 'Fish Cage',
            description = 'Depth: ' .. cage.depth .. ' | Catches: ' .. cage.catches,
            icon = 'fa-solid fa-water',
            disabled = false,
        },
        {
            title = 'Cast Fishing Line',
            description = 'Attempt to catch fish at this depth',
            icon = 'fa-solid fa-hook',
            onSelect = function()
                CastFishingLine(cageId)
            end,
        },
        {
            title = 'View Fish Info',
            description = 'See what fish are available at this depth',
            icon = 'fa-solid fa-book',
            onSelect = function()
                ViewFishInfo(cage.depth)
            end,
        },
         {
             title = 'Retrieve Cage',
             description = 'Remove the cage and collect any remaining fish',
             icon = 'fa-solid fa-box',
             onSelect = function()
                 RetrieveCage(cageId)
             end,
         },
         {
             title = '🏆 Leaderboards',
             description = 'View top players and records',
             icon = 'fa-solid fa-trophy',
             onSelect = function()
                 LeaderboardsUI.DisplayLeaderboardMenu()
             end,
         },
     }
    
    lib.registerContext({
        id = 'fishing_menu_' .. cageId,
        title = 'Fishing Menu',
        options = CurrentMenu,
    })
    
    lib.showContext('fishing_menu_' .. cageId)
end

-- Cast fishing line with minigame
function CastFishingLine(cageId)
    local cage = PlayerCages[cageId]
    if not cage then return end
    
    if IsFishing then
        Notifications.Error('Fishing', 'You are already fishing!')
        return
    end
    
    IsFishing = true
    
    Notifications.Info('Fishing', 'Casting line...')
    
    -- Trigger server minigame
    TriggerServerEvent('fishing:startMinigame', cageId, cage.depth)
end

-- View available fish at depth
function ViewFishInfo(depth)
    local fishList = FishData.GetFishByDepth(depth)
    
    local options = {
        {
            title = 'Available Fish - ' .. Config.DepthRanges[depth].label,
            description = 'Fish available at this depth',
            icon = 'fa-solid fa-list',
            disabled = true,
        },
    }
    
    for _, fish in ipairs(fishList) do
        table.insert(options, {
            title = fish.label,
            description = 'Rarity: ' .. fish.rarity:upper() .. ' | $' .. fish.sellPrice .. ' | Catch: ' .. fish.minCatch .. '-' .. fish.maxCatch,
            icon = 'fa-solid fa-fish',
        })
    end
    
    table.insert(options, {
        title = 'Back',
        onSelect = function()
            lib.hideContext()
        end,
        icon = 'fa-solid fa-arrow-left',
    })
    
    lib.registerContext({
        id = 'fish_info_' .. depth,
        title = 'Fish Information',
        options = options,
    })
    
    lib.showContext('fish_info_' .. depth)
end

-- Retrieve cage
function RetrieveCage(cageId)
    lib.alertDialog({
        header = 'Retrieve Cage?',
        content = 'Are you sure you want to retrieve this cage? It will be removed.',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Yes',
            cancel = 'No',
        },
    })
    
    if not lib.alertDialog() then
        return
    end
    
    TriggerServerEvent('fishing:removeCage', cageId)
end

-- Event handlers
RegisterNetEvent('fishing:cagePlaced', function(cage)\n    PlayerCages[cage.id] = cage\n    \n    TextUI.Show('[E] - Fish Cage | Depth: ' .. cage.depth:upper(), 'fa-solid fa-water')
    
    -- Create zone for interaction\n    local point = lib.points.new({\n        coords = cage.coords,\n        distance = Config.CageSettings.interactionDistance,\n        onEnter = function()\n            TextUI.Show('[E] - Interact with Cage | Press E', 'fa-solid fa-hook')\n        end,\n        onExit = function()\n            TextUI.Hide()\n        end,
        nearby = function()
            if IsControlJustReleased(0, 38) then -- E key
                OpenFishingMenu(cage.id)
            end
        end,
    })
    
    cage.zone = point
end)

RegisterNetEvent('fishing:cageRemoved', function(cageId)\n    if PlayerCages[cageId] then\n        if PlayerCages[cageId].zone then\n            PlayerCages[cageId].zone:remove()\n        end\n        PlayerCages[cageId] = nil\n    end\n    TextUI.Hide()\nend)

RegisterNetEvent('fishing:fishCaught', function(fish, amount, reward)\n    IsFishing = false\n    \n    Notifications.Success('Catch Successful!', 'You caught ' .. amount .. 'x ' .. fish.label .. ' worth $' .. reward)\nend)

RegisterNetEvent('fishing:clientMinigame', function(cageId, depth)
    StartFishingMinigame(cageId, depth)
end)

-- Item usage for fishing cage
RegisterNetEvent('farming:interact', function(itemName)
    if itemName == 'fishing_cage' then
        OpenCageDepthMenu()
    end
end)

function OpenCageDepthMenu()
    local options = {}
    
    for depth, info in pairs(Config.DepthRanges) do
        table.insert(options, {
            title = info.label:upper(),
            description = info.description .. ' | Reward Multiplier: ' .. (Config.RewardMultipliers[depth] or 1.0) .. 'x',
            icon = 'fa-solid fa-water',
            onSelect = function()
                PlaceFishingCage(depth)
            end,
        })
    end
    
    table.insert(options, {
        title = 'Cancel',
        icon = 'fa-solid fa-times',
        onSelect = function()
            lib.hideContext()
        end,
    })
    
    lib.registerContext({
        id = 'cage_depth_menu',
        title = 'Select Cage Depth',
        options = options,
    })
    
    lib.showContext('cage_depth_menu')
end

-- Check if player is in a boat
function IsPlayerInBoat()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle == 0 then
        return false
    end
    
    local vehicleType = GetVehicleType(vehicle)
    -- Vehicle type 6 is for boats/jets
    return vehicleType == 6
end

-- Export functions
function PlaceFishingCage(depthType)
    if not IsPlayerInBoat() then
        Notifications.Error('Fishing', 'You must be in a boat to place a cage!')
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local isNearWater, waterZ = GetWaterHeight(playerCoords.x, playerCoords.y)
    
    if not isNearWater then
        Notifications.Error('Fishing', 'You must be near water to place a cage!')
        return
    end
    
    local cageCoords = vector3(playerCoords.x + 5, playerCoords.y + 5, waterZ - 5)
    
    TriggerServerEvent('fishing:placeCage', cageCoords, depthType)
end



-- ===== CHALLENGES UI =====
-- Display challenges menu
function ShowChallengesMenu()
    if not Config.DailyChallenges.enabled then
        Notifications.Info('Challenges', 'Daily challenges are disabled')
        return
    end

    TriggerServerEvent('fishing:getChallenges')
    Wait(100)
    
    if not PlayerChallenges or next(PlayerChallenges) == nil then
        Notifications.Error('Challenges', 'Failed to load challenges')
        return
    end

    local options = {}
    
    table.insert(options, {
        title = '📊 Daily Fishing Challenges',
        description = 'Complete daily objectives for bonus rewards',
        icon = 'fa-solid fa-list-check',
        disabled = true,
    })
    
    for _, challenge in pairs(PlayerChallenges) do
        local status = ''
        if challenge.claimed then
            status = ' ✓ CLAIMED'
        elseif challenge.completed then
            status = ' ✓ COMPLETED'
        else
            status = ' ⏳ ' .. challenge.progress .. '/' .. challenge.goal
        end
        
        table.insert(options, {
            title = challenge.name,
            description = challenge.description .. status,
            icon = 'fa-solid fa-check',
            onSelect = function()
                ShowChallengeDetails(challenge)
            end,
        })
    end
    
    table.insert(options, {
        title = 'Close',
        icon = 'fa-solid fa-times',
        onSelect = function()
            lib.hideContext()
        end,
    })
    
    lib.registerContext({
        id = 'challenges_menu',
        title = 'Daily Challenges',
        options = options,
    })
    
    lib.showContext('challenges_menu')
end

-- Show challenge details
function ShowChallengeDetails(challenge)
    local progressBar = ''
    local filledBars = math.floor((challenge.progress / challenge.goal) * 10)
    for i = 1, 10 do
        progressBar = progressBar .. (i <= filledBars and '█' or '░')
    end

    local content = string.format(
        '**Objective:** %s\n\n' ..
        '**Progress:** %d/%d\n' ..
        '%s\n\n' ..
        '**Reward:** $%d\n' ..
        '**Bonus Multiplier:** %.0f%%',
        challenge.description,
        challenge.progress,
        challenge.goal,
        progressBar,
        challenge.reward,
        (challenge.multiplier - 1) * 100
    )

    lib.alertDialog({
        header = challenge.name,
        content = content,
        centered = true,
        cancel = true,
        labels = {
            confirm = challenge.completed and not challenge.claimed and 'Claim Reward' or 'Ok',
            cancel = 'Close',
        }
    })

    if challenge.completed and not challenge.claimed then
        TriggerServerEvent('fishing:claimChallengeReward', challenge.id)
    end
end

-- Challenge event handlers
RegisterNetEvent('fishing:receiveChallenges', function(challenges)
    PlayerChallenges = challenges
end)

RegisterNetEvent('fishing:challengeCompleted', function(challengeId, challengeName)
    Notifications.Success('🎉 Challenge Complete!', challengeName .. ' completed!')
end)

RegisterNetEvent('fishing:challengeClaimed', function(challengeId)
    if PlayerChallenges[challengeId] then
        PlayerChallenges[challengeId].claimed = true
    end
end)

RegisterNetEvent('fishing:challengesReset', function()
    PlayerChallenges = {}
    Notifications.Info('🔄 Daily Reset', 'Daily challenges have been reset!')
end)

-- Daily challenges command
lib.addCommand('challenges', {
    help = 'View your daily fishing challenges',
    restricted = false,
}, function(source, args, raw)
    ShowChallengesMenu()
end)

-- ===== LEADERBOARDS UI =====
-- Request leaderboard from server
function RequestLeaderboard(category, limit)
    limit = limit or 10
    TriggerServerEvent('deepseafishing:server:getLeaderboards', category, limit)
end

-- Receive leaderboard data
RegisterNetEvent('deepseafishing:client:receiveLeaderboards', function(category, leaderboard)
    DisplayLeaderboard(category)
end)

-- Request player ranking
function RequestPlayerRanking(category)
    TriggerServerEvent('deepseafishing:server:getPlayerRanking', category)
end

-- Receive player ranking
RegisterNetEvent('deepseafishing:client:receivePlayerRanking', function(category, ranking, value)
    -- Ranking received, will be displayed with leaderboard
end)

-- Display leaderboard in chat
function DisplayLeaderboard(category)
    TriggerServerEvent('deepseafishing:server:getLeaderboards', category, 10)
    Wait(200)
    
    local title = ''
    local typeLabel = ''
    
    if category == 'earnings' then
        title = '💰 TOP EARNERS LEADERBOARD'
        typeLabel = 'earnings'
    elseif category == 'catches' then
        title = '🎣 TOP CATCHERS LEADERBOARD'
        typeLabel = 'catches'
    elseif category == 'heaviest' then
        title = '⚖️ HEAVIEST FISH LEADERBOARD'
        typeLabel = 'heaviest'
    elseif category == 'rarity' then
        title = '👑 LEGENDARY CATCHES LEADERBOARD'
        typeLabel = 'rarity'
    end
    
    TriggerEvent('chat:addMessage', {
        args = { title },
        color = { 0, 255, 100 }
    })
    
    Notifications.Info('Leaderboard', 'Fetching ' .. title .. '...')
end

-- Display leaderboard menu
function DisplayLeaderboardMenu()
    local menu = {
        {
            label = '💰 Top Earners',
            description = 'View players with highest total earnings',
            onSelect = function()
                RequestLeaderboard('earnings', 10)
                RequestPlayerRanking('earnings')
                Notifications.Info('Leaderboard', 'Loading top earners...')
            end
        },
        {
            label = '🎣 Top Catchers',
            description = 'View players with most fish caught',
            onSelect = function()
                RequestLeaderboard('catches', 10)
                RequestPlayerRanking('catches')
                Notifications.Info('Leaderboard', 'Loading top catchers...')
            end
        },
        {
            label = '⚖️ Heaviest Fish',
            description = 'View largest fish caught by players',
            onSelect = function()
                RequestLeaderboard('heaviest', 10)
                RequestPlayerRanking('heaviest')
                Notifications.Info('Leaderboard', 'Loading heaviest fish records...')
            end
        },
        {
            label = '👑 Legendary Catches',
            description = 'View most legendary fish caught',
            onSelect = function()
                RequestLeaderboard('rarity', 10)
                RequestPlayerRanking('rarity')
                Notifications.Info('Leaderboard', 'Loading legendary records...')
            end
        }
    }
    
    if Config.Menus.style == 'ox_lib' then
        lib.registerContext({
            id = 'leaderboards_menu',
            title = '🏆 LEADERBOARDS',
            options = menu
        })
        lib.showContext('leaderboards_menu')
    else
        -- QBCore menu fallback
        TriggerEvent('qb-menu:client:openMenu', menu)
    end
end

-- Command to view leaderboards
lib.addCommand('leaderboards', {
    help = 'View fishing leaderboards',
    restricted = false,
}, function(source, args, raw)
    DisplayLeaderboardMenu()
end)

-- Debug command
if Config.Debug then
    print('^2[Fishing] Client loaded^7')
end
