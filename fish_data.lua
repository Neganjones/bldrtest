FishData = {}

-- Fish species with their properties
FishData.Species = {
    -- Shallow water fish
    {
        name = 'fish',
        label = 'Fish',
        depth = 'shallow',
        rarity = 'common',
        minCatch = 1,
        maxCatch = 3,
        sellPrice = 50,
        weight = math.random(500, 800),
    },
    {
        name = 'shrimp',
        label = 'Shrimp',
        depth = 'shallow',
        rarity = 'common',
        minCatch = 2,
        maxCatch = 5,
        sellPrice = 35,
        weight = math.random(100, 300),
    },
    {
        name = 'clam',
        label = 'Clam',
        depth = 'shallow',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 3,
        sellPrice = 60,
        weight = math.random(200, 400),
    },
    {
        name = 'mussel',
        label = 'Mussel',
        depth = 'shallow',
        rarity = 'common',
        minCatch = 2,
        maxCatch = 4,
        sellPrice = 40,
        weight = math.random(150, 350),
    },
    
    -- Medium depth fish
    {
        name = 'crab',
        label = 'Crab',
        depth = 'medium',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 2,
        sellPrice = 85,
        weight = math.random(800, 1200),
    },
    {
        name = 'oyster',
        label = 'Oyster',
        depth = 'medium',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 2,
        sellPrice = 75,
        weight = math.random(300, 600),
    },
    {
        name = 'grouper',
        label = 'Grouper',
        depth = 'medium',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 3,
        sellPrice = 90,
        weight = math.random(1000, 1500),
    },
    {
        name = 'snapper',
        label = 'Snapper',
        depth = 'medium',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 2,
        sellPrice = 80,
        weight = math.random(900, 1300),
    },
    
    -- Deep water fish
    {
        name = 'lobster',
        label = 'Lobster',
        depth = 'deep',
        rarity = 'rare',
        minCatch = 1,
        maxCatch = 2,
        sellPrice = 150,
        weight = math.random(1500, 2500),
    },
    {
        name = 'bass',
        label = 'Bass',
        depth = 'deep',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 2,
        sellPrice = 95,
        weight = math.random(1200, 1800),
    },
    {
        name = 'pike',
        label = 'Pike',
        depth = 'deep',
        rarity = 'rare',
        minCatch = 1,
        maxCatch = 1,
        sellPrice = 140,
        weight = math.random(2000, 2500),
    },
    {
        name = 'perch',
        label = 'Perch',
        depth = 'deep',
        rarity = 'uncommon',
        minCatch = 1,
        maxCatch = 3,
        sellPrice = 100,
        weight = math.random(1000, 1500),
    },
    
    -- Very deep water (rare legendaries)
    {
        name = 'swordfish',
        label = 'Swordfish',
        depth = 'verydeep',
        rarity = 'legendary',
        minCatch = 1,
        maxCatch = 1,
        sellPrice = 500,
        weight = math.random(3000, 5000),
    },
    {
        name = 'anglerfish',
        label = 'Anglerfish',
        depth = 'verydeep',
        rarity = 'legendary',
        minCatch = 1,
        maxCatch = 1,
        sellPrice = 450,
        weight = math.random(2500, 4000),
    },
    {
        name = 'jellyfish',
        label = 'Jellyfish',
        depth = 'verydeep',
        rarity = 'rare',
        minCatch = 2,
        maxCatch = 5,
        sellPrice = 120,
        weight = math.random(200, 500),
    },
    {
        name = 'squid',
        label = 'Squid',
        depth = 'verydeep',
        rarity = 'rare',
        minCatch = 1,
        maxCatch = 2,
        sellPrice = 180,
        weight = math.random(1500, 2500),
    },
}

-- Rarity spawn chances
FishData.RarityWeights = {
    common = 40,
    uncommon = 35,
    rare = 20,
    legendary = 5,
}

-- Get fish by depth
function FishData.GetFishByDepth(depth)
    local validFish = {}
    for _, fish in ipairs(FishData.Species) do
        if fish.depth == depth then
            table.insert(validFish, fish)
        end
    end
    return validFish
end

-- Get random fish from depth
function FishData.GetRandomFish(depth)
    local validFish = FishData.GetFishByDepth(depth)
    if #validFish == 0 then
        return FishData.Species[1] -- fallback
    end
    
    -- Apply rarity weighting
    local weightedFish = {}
    for _, fish in ipairs(validFish) do
        local weight = FishData.RarityWeights[fish.rarity] or 10
        for _ = 1, weight do
            table.insert(weightedFish, fish)
        end
    end
    
    return weightedFish[math.random(#weightedFish)]
end

-- Get depth category from water level
function FishData.GetDepthCategory(playerZ, waterZ)
    local depth = math.abs(playerZ - waterZ)
    
    if depth <= Config.DepthRanges.shallow.max then
        return 'shallow'
    elseif depth <= Config.DepthRanges.medium.max then
        return 'medium'
    elseif depth <= Config.DepthRanges.deep.max then
        return 'deep'
    else
        return 'verydeep'
    end
end
