local QBCore = exports['qb-core']:GetCoreObject()
local Challenges = require 'server.challenges'
local Leaderboards = require 'shared.leaderboards'

-- Active player cages
local PlayerCages = {}

-- Check if player is in a boat (server-side validation)
local function IsPlayerInBoat(source)
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then return false end
    
    local vehicleType = GetVehicleType(vehicle)
    -- Vehicle type 6 is for boats/jets
    return vehicleType == 6
end

-- Register net events
RegisterNetEvent('fishing:placeCage', function(coords, depth)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    if not player then return end
    
    -- Check if player is in a boat
    if not IsPlayerInBoat(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Fishing',
            description = 'You must be in a boat to place a cage!',
            duration = 5000,
        })
        return
    end
    
    -- Check if player has fishing cage item
    if not player.Functions.HasItem('fishing_cage', 1) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Fishing',
            description = 'You don\'t have a fishing cage!',
            duration = 5000,
        })
        return
    end
    
    -- Validate cage placement
    if not PlayerCages[source] then
        PlayerCages[source] = {}
    end
    
    if #PlayerCages[source] >= Config.CageSettings.maxCagesPerPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Fishing',
            description = 'You have reached the maximum number of cages!',
            duration = 5000,
        })
        return
    end
    
    -- Remove fishing cage item from inventory
    player.Functions.RemoveItem('fishing_cage', 1)
    
    -- Create cage data
    local cage = {
        id = #PlayerCages[source] + 1,
        playerId = source,
        playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        coords = coords,
        depth = depth,
        created = os.time(),
        catches = 0,
    }
    
    table.insert(PlayerCages[source], cage)
    
    -- Notify client
    TriggerClientEvent('fishing:cagePlaced', source, cage)
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Fishing',
        description = 'Cage placed at ' .. depth .. ' depth!',
        duration = 5000,
    })
    
    if Config.Debug then
        print('^2[Fishing] Cage placed by ' .. player.PlayerData.charinfo.firstname .. ' at depth: ' .. depth .. '^7')
    end
end)

RegisterNetEvent('fishing:removeCage', function(cageId)
    local source = source
    
    if PlayerCages[source] then
        for i, cage in ipairs(PlayerCages[source]) do
            if cage.id == cageId then
                table.remove(PlayerCages[source], i)
                TriggerClientEvent('fishing:cageRemoved', source, cageId)
                TriggerClientEvent('ox_lib:notify', source, {
                    type = 'success',
                    title = 'Fishing',
                    description = 'Cage removed!',
                    duration = 3000,
                })
                break
            end
        end
    end
end)

RegisterNetEvent('fishing:catchFish', function(cageId, depth)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    if not player then return end
    
    -- Get random fish
    local fish = FishData.GetRandomFish(depth)
    if not fish then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            title = 'Fishing',
            description = 'No fish available at this depth!',
            duration = 5000,
        })
        return
    end
    
    -- Apply depth multiplier
    local multiplier = Config.RewardMultipliers[depth] or 1.0
    
    -- Apply challenge bonus multiplier
    if Config.DailyChallenges.enabled then
        local challengeMultiplier = Challenges.GetMultiplier(source)
        multiplier = multiplier * challengeMultiplier
    end
    
    local catchAmount = math.ceil(math.random(fish.minCatch, fish.maxCatch) * multiplier)
    local reward = fish.sellPrice * catchAmount
    
    -- Add items to inventory
    for _ = 1, catchAmount do
        player.Functions.AddItem(fish.name, 1)
    end
    
    -- Update money
    player.Functions.AddMoney('cash', reward)
    
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        title = 'Fishing Success!',
        description = 'You caught ' .. catchAmount .. 'x ' .. fish.label .. ' ($' .. reward .. ')',
        duration = 5000,
    })
    
    -- Update cage catches
    if PlayerCages[source] then
        for _, cage in ipairs(PlayerCages[source]) do
            if cage.id == cageId then
                cage.catches = cage.catches + 1
                break
            end
        end
    end
    
     -- Update daily challenges
     if Config.DailyChallenges.enabled then
         Challenges.UpdateProgress(source, 'catch_count', {})
         Challenges.UpdateProgress(source, 'catch_species', {species = fish.name})
         Challenges.UpdateProgress(source, 'catch_variety', {species = fish.name})
         Challenges.UpdateProgress(source, 'earn_money', {amount = reward})
     end
     
     -- Update leaderboards
     local weight = math.random(1, 15)
     TriggerEvent('deepseafishing:server:updateLeaderboards', fish.label, fish.rarity, weight, reward)
     
     TriggerClientEvent('fishing:fishCaught', source, fish, catchAmount, reward)
    
    if Config.Debug then
        print('^2[Fishing] ' .. player.PlayerData.charinfo.firstname .. ' caught ' .. catchAmount .. 'x ' .. fish.label .. '^7')
    end
end)

RegisterNetEvent('fishing:startMinigame', function(cageId, depth)
    local source = source
    
    -- Validate minigame
    if not Config.Minigames.enabled then
        TriggerEvent('fishing:catchFish', cageId, depth)
        return
    end
    
    TriggerClientEvent('fishing:clientMinigame', source, cageId, depth)
end)

-- Export functions
function GetNearestCage(source)
    if not PlayerCages[source] then return nil end
    return PlayerCages[source][1]
end

function GetCageDepth(source, cageId)
    if PlayerCages[source] then
        for _, cage in ipairs(PlayerCages[source]) do
            if cage.id == cageId then
                return cage.depth
            end
        end
    end
    return nil
end

function PlaceCage(source, coords, depth)
    TriggerEvent('fishing:placeCage', coords, depth)
end

function RemoveCage(source, cageId)
    TriggerEvent('fishing:removeCage', cageId)
end

-- Player joined event
AddEventHandler('playerJoining', function()
    local source = source
    if Config.DailyChallenges.enabled then
        Challenges.Initialize(source)
    end
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local source = source
    PlayerCages[source] = nil
    if Config.DailyChallenges.enabled then
        Challenges.Cleanup(source)
    end
end)

-- Challenge events
RegisterNetEvent('fishing:getChallenges', function()
    local source = source
    if Config.DailyChallenges.enabled then
        local playerChallenges = Challenges.GetChallenges(source)
        TriggerClientEvent('fishing:receiveChallenges', source, playerChallenges)
    end
end)

RegisterNetEvent('fishing:claimChallengeReward', function(challengeId)
    local source = source
    if Config.DailyChallenges.enabled then
        Challenges.ClaimReward(source, challengeId)
    end
end)

-- Leaderboard events
RegisterNetEvent('deepseafishing:server:updateLeaderboards', function(fishType, rarity, weight, earnings)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    
    local citizenId = player.PlayerData.citizenid
    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    
    -- Update all leaderboard categories
    Leaderboards.UpdateEarnings(citizenId, playerName, earnings)
    Leaderboards.UpdateCatches(citizenId, playerName, 1)
    Leaderboards.UpdateHeaviestFish(citizenId, playerName, fishType, weight)
    Leaderboards.UpdateRarityRecords(citizenId, playerName, rarity)
end)

-- Sync leaderboards to client
RegisterNetEvent('deepseafishing:server:getLeaderboards', function(category, limit)
    local src = source
    limit = limit or 10
    
    local leaderboard = {}
    if category == 'earnings' then
        leaderboard = Leaderboards.GetTopEarners(limit)
    elseif category == 'catches' then
        leaderboard = Leaderboards.GetTopCatchers(limit)
    elseif category == 'heaviest' then
        leaderboard = Leaderboards.GetHeaviestFish(limit)
    elseif category == 'rarity' then
        leaderboard = Leaderboards.GetRarityRecords(limit)
    end
    
    TriggerClientEvent('deepseafishing:client:receiveLeaderboards', src, category, leaderboard)
end)

-- Get player ranking
RegisterNetEvent('deepseafishing:server:getPlayerRanking', function(category)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    
    local citizenId = player.PlayerData.citizenid
    local ranking = 0
    local value = 0
    
    if category == 'earnings' then
        for i, entry in ipairs(Leaderboards.GetTopEarners(100)) do
            if entry.citizenId == citizenId then
                ranking = i
                value = entry.total_earnings
                break
            end
        end
    elseif category == 'catches' then
        for i, entry in ipairs(Leaderboards.GetTopCatchers(100)) do
            if entry.citizenId == citizenId then
                ranking = i
                value = entry.total_catches
                break
            end
        end
    elseif category == 'heaviest' then
        for i, entry in ipairs(Leaderboards.GetHeaviestFish(100)) do
            if entry.citizenId == citizenId then
                ranking = i
                value = entry.weight
                break
            end
        end
    elseif category == 'rarity' then
        for i, entry in ipairs(Leaderboards.GetRarityRecords(100)) do
            if entry.citizenId == citizenId then
                ranking = i
                value = entry.legendary_catches
                break
            end
        end
    end
    
    TriggerClientEvent('deepseafishing:client:receivePlayerRanking', src, category, ranking, value)
end)

-- Export for admin commands
function GetLeaderboardData(category, limit)
    limit = limit or 10
    if category == 'earnings' then
        return Leaderboards.GetTopEarners(limit)
    elseif category == 'catches' then
        return Leaderboards.GetTopCatchers(limit)
    elseif category == 'heaviest' then
        return Leaderboards.GetHeaviestFish(limit)
    elseif category == 'rarity' then
        return Leaderboards.GetRarityRecords(limit)
    end
end

exports('GetLeaderboardData', GetLeaderboardData)

-- Debug command
if Config.Debug then
    RegisterCommand('fishtest', function(source, args, rawCommand)
        TriggerEvent('fishing:catchFish', 1, args[1] or 'shallow')
    end, false)
end
