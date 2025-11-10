-- Server-side reward management
local RewardCache = {}

-- Track rewards for anti-spam
function CanRewardPlayer(source, cooldown)
    cooldown = cooldown or Config.CageSettings.catchCooldown
    
    if not RewardCache[source] then
        RewardCache[source] = 0
    end
    
    local lastCatch = RewardCache[source]
    local timeSinceLastCatch = GetGameTimer() - lastCatch
    
    if timeSinceLastCatch < cooldown then
        return false
    end
    
    RewardCache[source] = GetGameTimer()
    return true
end

-- Validate reward data
function ValidateRewardData(cageId, depth, fishName)
    -- Ensure depth is valid
    if not Config.DepthRanges[depth] then
        return false
    end
    
    -- Ensure fish exists at depth
    local validFish = FishData.GetFishByDepth(depth)
    for _, fish in ipairs(validFish) do
        if fish.name == fishName then
            return true
        end
    end
    
    return false
end

-- Apply reward multipliers
function CalculateReward(fish, depth, minigameSuccess)
    local baseReward = fish.sellPrice
    local depthMultiplier = Config.RewardMultipliers[depth] or 1.0
    local minigameBonus = minigameSuccess and 1.25 or 1.0
    
    return math.floor(baseReward * depthMultiplier * minigameBonus)
end

-- Track player fishing stats
local FishingStats = {}

function IncrementFishingStats(source, depth, fishName, amount)
    if not FishingStats[source] then
        FishingStats[source] = {
            totalFish = 0,
            fishCaught = {},
            totalValue = 0,
            depthRecord = {},
        }
    end
    
    local stats = FishingStats[source]
    stats.totalFish = stats.totalFish + amount
    stats.fishCaught[fishName] = (stats.fishCaught[fishName] or 0) + amount
    stats.depthRecord[depth] = (stats.depthRecord[depth] or 0) + amount
end

function GetFishingStats(source)
    return FishingStats[source]
end

-- Cleanup
AddEventHandler('playerDropped', function()
    local source = source
    RewardCache[source] = nil
end)
