-- Client-side cage management
local CageEntities = {}
local CageNetIds = {}

-- Place cage prop in world
function SpawnCageProp(cage)
    local modelHash = GetHashKey(Config.CageModel)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    local cageEntity = CreateObject(modelHash, cage.coords.x, cage.coords.y, cage.coords.z, false, false, false)
    SetEntityAsMissionEntity(cageEntity, true, true)
    PlaceObjectOnGroundProperly(cageEntity)
    
    CageEntities[cage.id] = cageEntity
    CageNetIds[cage.id] = NetworkGetNetworkIdFromEntity(cageEntity)
    
    -- Sync with server
    TriggerServerEvent('fishing:cageNetworkSync', CageNetIds[cage.id], cage.id, cage.coords)
    
    return cageEntity
end

-- Remove cage prop
function RemoveCageProp(cageId)
    if CageEntities[cageId] then
        DeleteEntity(CageEntities[cageId])
        CageEntities[cageId] = nil
        CageNetIds[cageId] = nil
    end
end

-- Get cage depth based on distance from surface
function GetCageDepth(cageCoords)
    local isNearWater, waterZ = GetWaterHeight(cageCoords.x, cageCoords.y)
    
    if not isNearWater then
        return 'shallow'
    end
    
    local depthDifference = math.abs(cageCoords.z - waterZ)
    
    if depthDifference <= Config.DepthRanges.shallow.max then
        return 'shallow'
    elseif depthDifference <= Config.DepthRanges.medium.max then
        return 'medium'
    elseif depthDifference <= Config.DepthRanges.deep.max then
        return 'deep'
    else
        return 'verydeep'
    end
end

-- Validate cage placement
function IsValidCagePlacement(coords)
    local isNearWater, waterZ = GetWaterHeight(coords.x, coords.y)
    
    if not isNearWater then
        lib.notify({
            type = 'error',
            title = 'Fishing',
            description = 'Cage must be placed in water!',
            duration = 3000,
        })
        return false
    end
    
    -- Check if too shallow
    if math.abs(coords.z - waterZ) < 2 then
        lib.notify({
            type = 'error',
            title = 'Fishing',
            description = 'Water too shallow for cage!',
            duration = 3000,
        })
        return false
    end
    
    return true
end

-- Get all nearby cages
function GetNearbyCages(coords, radius)
    local nearbyCages = {}
    
    for id, entity in pairs(CageEntities) do
        local distance = #(GetEntityCoords(entity) - coords)
        if distance <= radius then
            table.insert(nearbyCages, {
                id = id,
                distance = distance,
                entity = entity,
            })
        end
    end
    
    table.sort(nearbyCages, function(a, b) return a.distance < b.distance end)
    return nearbyCages
end

-- Draw cage marker
function DrawCageMarker(coords, depth)
    local depthColor = {
        shallow = {r = 100, g = 200, b = 255, a = 100},
        medium = {r = 70, g = 130, b = 200, a = 100},
        deep = {r = 50, g = 70, b = 150, a = 100},
        verydeep = {r = 25, g = 35, b = 100, a = 100},
    }
    
    local color = depthColor[depth] or depthColor.shallow
    
    local marker = lib.marker.new({
        type = 6,
        coords = coords,
        color = color,
        width = 2.0,
        height = 2.0,
    })
    
    marker:draw()
end

-- Get cage information string
function GetCageInfo(cage)
    return 'Depth: ' .. cage.depth .. ' | Owner: ' .. cage.playerName .. ' | Catches: ' .. cage.catches
end

-- Export functions
function GetNearestCage()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearbyCages = GetNearbyCages(playerCoords, 200.0)
    
    if #nearbyCages > 0 then
        return nearbyCages[1]
    end
    
    return nil
end

if Config.Debug then
    print('^2[Fishing Cage] Client loaded^7')
end
