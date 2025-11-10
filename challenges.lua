-- ===== DAILY CHALLENGES SYSTEM =====
-- Manages daily fishing challenges with rewards and multipliers

local QBCore = exports['qb-core']:GetCoreObject()
local challenges = {}

-- Create challenges for a player
function InitializePlayerChallenges(source)
    if not challenges[source] then
        challenges[source] = {}
        
        for _, challenge in ipairs(Config.DailyChallenges.challenges) do
            challenges[source][challenge.id] = {
                id = challenge.id,
                name = challenge.name,
                description = challenge.description,
                goal = challenge.goal,
                progress = 0,
                completed = false,
                reward = challenge.reward,
                multiplier = challenge.multiplier,
                type = challenge.type,
                species = challenge.species,
                claimed = false,
            }
        end
    end
end

-- Update challenge progress
function UpdateChallengeProgress(source, challengeType, data)
    if not challenges[source] then
        InitializePlayerChallenges(source)
    end

    for _, challenge in ipairs(Config.DailyChallenges.challenges) do
        if challenges[source][challenge.id] and not challenges[source][challenge.id].completed then
            if challenge.type == 'catch_count' and challengeType == 'catch_count' then
                challenges[source][challenge.id].progress = challenges[source][challenge.id].progress + 1
                
            elseif challenge.type == 'earn_money' and challengeType == 'earn_money' then
                challenges[source][challenge.id].progress = challenges[source][challenge.id].progress + (data.amount or 0)
                
            elseif challenge.type == 'catch_species' and challengeType == 'catch_species' then
                if data.species == challenge.species then
                    challenges[source][challenge.id].progress = challenges[source][challenge.id].progress + 1
                end
                
            elseif challenge.type == 'catch_variety' and challengeType == 'catch_variety' then
                -- Check if species is already tracked
                if not challenges[source][challenge.id].species_list then
                    challenges[source][challenge.id].species_list = {}
                end
                
                if not challenges[source][challenge.id].species_list[data.species] then
                    challenges[source][challenge.id].species_list[data.species] = true
                    challenges[source][challenge.id].progress = challenges[source][challenge.id].progress + 1
                end
            end

            -- Check if challenge is completed
            if challenges[source][challenge.id].progress >= challenge.goal then
                challenges[source][challenge.id].completed = true
                TriggerClientEvent('fishing:challengeCompleted', source, challenge.id, challenge.name)
            end
        end
    end
end

-- Get player challenges
function GetPlayerChallenges(source)
    if not challenges[source] then
        InitializePlayerChallenges(source)
    end
    
    return challenges[source]
end

-- Claim challenge reward
function ClaimChallengeReward(source, challengeId)
    if not challenges[source] or not challenges[source][challengeId] then
        return false
    end

    local challenge = challenges[source][challengeId]
    
    if not challenge.completed or challenge.claimed then
        return false
    end

    local player = QBCore.Functions.GetPlayer(source)
    if not player then
        return false
    end

    -- Add reward money
    player.Functions.AddMoney('bank', challenge.reward)
    challenge.claimed = true

    TriggerClientEvent('QBCore:Notify', source, 'Claimed ' .. challenge.name .. ' reward! +$' .. challenge.reward, 'success')
    TriggerClientEvent('fishing:challengeClaimed', source, challengeId)

    return true
end

-- Get challenge multiplier
function GetChallengeMultiplier(source)
    if not challenges[source] then
        return 1.0
    end

    local multiplier = 1.0
    
    for _, challenge in pairs(challenges[source]) do
        if challenge.completed and not challenge.claimed then
            multiplier = multiplier * challenge.multiplier
        end
    end
    
    return multiplier
end

-- Reset challenges for all players (called daily)
function ResetAllChallenges()
    for source, _ in pairs(challenges) do
        challenges[source] = {}
        -- Reinitialize for next day
        for _, challenge in ipairs(Config.DailyChallenges.challenges) do
            challenges[source][challenge.id] = {
                id = challenge.id,
                name = challenge.name,
                description = challenge.description,
                goal = challenge.goal,
                progress = 0,
                completed = false,
                reward = challenge.reward,
                multiplier = challenge.multiplier,
                type = challenge.type,
                species = challenge.species,
                claimed = false,
            }
        end
        TriggerClientEvent('fishing:challengesReset', source)
    end
end

-- Cleanup on player drop
function CleanupPlayerChallenges(source)
    challenges[source] = nil
end

-- Export functions
return {
    Initialize = InitializePlayerChallenges,
    UpdateProgress = UpdateChallengeProgress,
    GetChallenges = GetPlayerChallenges,
    ClaimReward = ClaimChallengeReward,
    GetMultiplier = GetChallengeMultiplier,
    ResetAll = ResetAllChallenges,
    Cleanup = CleanupPlayerChallenges,
}
