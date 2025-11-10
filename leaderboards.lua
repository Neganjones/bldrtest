local Leaderboards = {}

-- Database structure for leaderboards
Leaderboards.Data = {
    totalEarnings = {},      -- {citizenId, name, total_earnings}
    totalCatches = {},       -- {citizenId, name, total_catches}
    heaviestFish = {},       -- {citizenId, name, fish_type, weight}
    rarityRecords = {},      -- {citizenId, name, legendary_catches}
}

-- Get top earners
function Leaderboards.GetTopEarners(limit)
    limit = limit or 10
    return table.slice(Leaderboards.Data.totalEarnings, 1, limit)
end

-- Get top catchers
function Leaderboards.GetTopCatchers(limit)
    limit = limit or 10
    return table.slice(Leaderboards.Data.totalCatches, 1, limit)
end

-- Get heaviest fish records
function Leaderboards.GetHeaviestFish(limit)
    limit = limit or 10
    return table.slice(Leaderboards.Data.heaviestFish, 1, limit)
end

-- Get rarity records
function Leaderboards.GetRarityRecords(limit)
    limit = limit or 10
    return table.slice(Leaderboards.Data.rarityRecords, 1, limit)
end

-- Update earnings record
function Leaderboards.UpdateEarnings(citizenId, name, amount)
    for i, entry in ipairs(Leaderboards.Data.totalEarnings) do
        if entry.citizenId == citizenId then
            entry.total_earnings = entry.total_earnings + amount
            table.sort(Leaderboards.Data.totalEarnings, function(a, b)
                return a.total_earnings > b.total_earnings
            end)
            return
        end
    end
    table.insert(Leaderboards.Data.totalEarnings, {
        citizenId = citizenId,
        name = name,
        total_earnings = amount
    })
    table.sort(Leaderboards.Data.totalEarnings, function(a, b)
        return a.total_earnings > b.total_earnings
    end)
end

-- Update catch count
function Leaderboards.UpdateCatches(citizenId, name, count)
    for i, entry in ipairs(Leaderboards.Data.totalCatches) do
        if entry.citizenId == citizenId then
            entry.total_catches = entry.total_catches + count
            table.sort(Leaderboards.Data.totalCatches, function(a, b)
                return a.total_catches > b.total_catches
            end)
            return
        end
    end
    table.insert(Leaderboards.Data.totalCatches, {
        citizenId = citizenId,
        name = name,
        total_catches = count
    })
    table.sort(Leaderboards.Data.totalCatches, function(a, b)
        return a.total_catches > b.total_catches
    end)
end

-- Update heaviest fish record
function Leaderboards.UpdateHeaviestFish(citizenId, name, fishType, weight)
    for i, entry in ipairs(Leaderboards.Data.heaviestFish) do
        if entry.citizenId == citizenId then
            if weight > entry.weight then
                entry.fish_type = fishType
                entry.weight = weight
            end
            table.sort(Leaderboards.Data.heaviestFish, function(a, b)
                return a.weight > b.weight
            end)
            return
        end
    end
    table.insert(Leaderboards.Data.heaviestFish, {
        citizenId = citizenId,
        name = name,
        fish_type = fishType,
        weight = weight
    })
    table.sort(Leaderboards.Data.heaviestFish, function(a, b)
        return a.weight > b.weight
    end)
end

-- Update rarity records (legendary catches)
function Leaderboards.UpdateRarityRecords(citizenId, name, rarity)
    if rarity ~= 'legendary' then return end
    
    for i, entry in ipairs(Leaderboards.Data.rarityRecords) do
        if entry.citizenId == citizenId then
            entry.legendary_catches = entry.legendary_catches + 1
            table.sort(Leaderboards.Data.rarityRecords, function(a, b)
                return a.legendary_catches > b.legendary_catches
            end)
            return
        end
    end
    table.insert(Leaderboards.Data.rarityRecords, {
        citizenId = citizenId,
        name = name,
        legendary_catches = 1
    })
    table.sort(Leaderboards.Data.rarityRecords, function(a, b)
        return a.legendary_catches > b.legendary_catches
    end)
end

-- Format leaderboard entry for display
function Leaderboards.FormatEntry(rank, entry, type)
    if type == 'earnings' then
        return ("^2#%d^7 | %s - $%s"):format(rank, entry.name, string.format("%,d", entry.total_earnings))
    elseif type == 'catches' then
        return ("^2#%d^7 | %s - %d catches"):format(rank, entry.name, entry.total_catches)
    elseif type == 'heaviest' then
        return ("^2#%d^7 | %s - %s (%.1f kg)"):format(rank, entry.name, entry.fish_type, entry.weight)
    elseif type == 'rarity' then
        return ("^2#%d^7 | %s - %d legendary"):format(rank, entry.name, entry.legendary_catches)
    end
end

return Leaderboards
