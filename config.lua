Config = {}

-- Fishing locations
Config.FishingLocations = {
    {name = 'Sandy Shores', coords = vector3(477.8, 3866.2, -37.0), radius = 200.0},
    {name = 'Paleto Bay', coords = vector3(-265.2, 6347.5, 31.49), radius = 250.0},
    {name = 'Pillbox', coords = vector3(448.56, -982.55, 29.44), radius = 150.0},
    {name = 'Del Perro', coords = vector3(-1600.0, -1100.0, 13.0), radius = 200.0},
}

-- Depth ranges (in GTA units)
Config.DepthRanges = {
    shallow = {min = 0, max = 10, label = 'Shallow Water (0-10m)'},
    medium = {min = 10, max = 25, label = 'Medium Depth (10-25m)'},
    deep = {min = 25, max = 50, label = 'Deep Water (25-50m)'},
    verydeep = {min = 50, max = 100, label = 'Very Deep Water (50-100m)'},
}

-- Cage model
Config.CageModel = 'prop_fish_cage_01'

-- Cage settings
Config.CageSettings = {
    maxCagesPerPlayer = 3,
    catchCooldown = 5000, -- milliseconds
    cageLifetime = 3600000, -- 1 hour in milliseconds
    placementDistance = 50.0, -- distance from player to place cage
    interactionDistance = 5.0,
}

-- Minigame settings
Config.Minigames = {
    enabled = true,
    types = {'skillcheck', 'none'}, -- supported minigame types
    difficulty = {
        easy = 'easy',
        medium = 'medium',
        hard = 'hard',
    },
}

-- Reward multipliers
Config.RewardMultipliers = {
    shallow = 1.0,
    medium = 1.5,
    deep = 2.0,
    verydeep = 3.0,
}

-- Notification System
Config.Notifications = {
    enabled = true,
    type = 'ox_lib', -- 'ox_lib' or 'qbcore'
    position = 'top-right', -- top-left, top-center, top-right, bottom-left, bottom-center, bottom-right
    duration = 5000, -- milliseconds
}

-- Text UI Settings
Config.TextUI = {
    enabled = true,
    type = 'ox_lib', -- 'ox_lib' or 'simple'
    position = 'top-center', -- top-left, top-center, top-right, bottom-left, bottom-center, bottom-right, left-center, center, right-center
    style = {
        borderRadius = 0,
        backgroundColor = '#48BB78',
        color = 'white',
    },
}

-- Menu Settings
Config.Menus = {
    style = 'ox_lib', -- 'ox_lib' or 'qbcore'
    position = 'top-left', -- menu positioning
    width = 400,
    maxItems = 6,
}

-- Daily Challenges
Config.DailyChallenges = {
	enabled = true,
	resetTime = '00:00', -- Reset time in 24hr format (server time)
	challenges = {
		{
			id = 'catch_ten',
			name = 'Deep Sea Collector',
			description = 'Catch 10 fish',
			goal = 10,
			reward = 500, -- bonus cash
			multiplier = 1.25, -- 25% bonus to all catches
			type = 'catch_count',
		},
		{
			id = 'earn_thousand',
			name = 'Profit Master',
			description = 'Earn $1,000 from fishing',
			goal = 1000,
			reward = 200, -- bonus cash
			multiplier = 1.15, -- 15% bonus to all catches
			type = 'earn_money',
		},
		{
			id = 'lobster_hunt',
			name = 'Lobster Specialist',
			description = 'Catch 3 Lobsters',
			goal = 3,
			reward = 300,
			multiplier = 1.20,
			type = 'catch_species',
			species = 'lobster',
		},
		{
			id = 'shrimp_hunt',
			name = 'Shrimp Connoisseur',
			description = 'Catch 5 Shrimp',
			goal = 5,
			reward = 250,
			multiplier = 1.15,
			type = 'catch_species',
			species = 'shrimp',
		},
		{
			id = 'clam_hunt',
			name = 'Clam Explorer',
			description = 'Catch 4 Clams',
			goal = 4,
			reward = 225,
			multiplier = 1.15,
			type = 'catch_species',
			species = 'clam',
		},
		{
			id = 'variety_pack',
			name = 'Species Master',
			description = 'Catch 5 different fish species',
			goal = 5,
			reward = 400,
			multiplier = 1.30,
			type = 'catch_variety',
		},
	},
}

-- Debug mode
Config.Debug = true
