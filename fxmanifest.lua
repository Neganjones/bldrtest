fx_version 'cerulean'
game 'gta5'

author 'BLDR Team'
description 'Comprehensive Deep Sea Fishing System with Cage Mechanics'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/fish_data.lua',
    'shared/notifications.lua',
    'shared/leaderboards.lua',
}

client_scripts {
    'client/textui.lua',
    'client/client.lua',
    'client/cage.lua',
    'client/minigames.lua',
}

server_scripts {
    'server/server.lua',
    'server/cage.lua',
    'server/rewards.lua',
    'server/challenges.lua',
}

dependencies {
    'ox_lib',
    'qb-core',
}

exports {
    'GetNearestCage',
    'GetCageDepth',
    'PlaceCage',
    'RemoveCage',
    'GetLeaderboardData',
    'AddLeaderboardsToMenu',
}
