fx_version 'cerulean'
game 'gta5'

author 'Daphne Studio <daphne.tebex.io>'
description 'Daphne Core - Framework Bridge with Adapter Pattern'
version '1.0.0'

lua54 'yes'

-- Shared scripts (load order matters - dependencies first)
shared_scripts {
    'shared/types.lua',
    'shared/config.lua',
    'core/bridge.lua',
    'core/statebag.lua',
    'adapters/qbox/adapter.lua',
    'adapters/qbox/player.lua',
    'adapters/qbox/money.lua',
    'adapters/qbox/inventory.lua',
    'adapters/qbox/job.lua',
    'adapters/qbox/vehicle.lua'
}

-- Server scripts
server_scripts {
    'server/server.lua',
    'server/bridge.lua',
    'server/statebag.lua',
    'server/events.lua'
}

-- Client scripts (load order matters - dependencies first)
client_scripts {
    'client/statebag.lua',
    'client/client.lua'
}
