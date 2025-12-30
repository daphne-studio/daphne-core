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
    'shared/inventory_detector.lua',
    'core/error_handler.lua',
    'core/bridge.lua',
    'core/cache.lua',
    'core/statebag.lua',
    'adapters/qbox/adapter.lua',
    'adapters/qbox/player.lua',
    'adapters/qbox/money.lua',
    'adapters/qbox/inventory.lua',
    'adapters/qbox/job.lua',
    'adapters/qbox/vehicle.lua',
    'adapters/esx/adapter.lua',
    'adapters/esx/player.lua',
    'adapters/esx/money.lua',
    'adapters/esx/inventory.lua',
    'adapters/esx/job.lua',
    'adapters/esx/vehicle.lua',
    'adapters/nd_core/adapter.lua',
    'adapters/nd_core/player.lua',
    'adapters/nd_core/money.lua',
    'adapters/nd_core/inventory.lua',
    'adapters/nd_core/job.lua',
    'adapters/nd_core/vehicle.lua',
    -- API Mapper and Data Converter (needed by proxies)
    'core/api_mapper.lua',
    'core/data_converter.lua',
    -- Proxy core modules
    'core/proxy.lua',
    'core/proxy_manager.lua',
    -- Base proxy class
    'proxies/base_proxy.lua',
    -- Player object proxies (must load before framework proxies)
    'proxies/qbcore_player_proxy.lua',
    'proxies/esx_player_proxy.lua',
    'proxies/nd_core_player_proxy.lua',
    -- Framework proxies
    'proxies/qbcore_proxy.lua',
    'proxies/esx_proxy.lua',
    'proxies/nd_core_proxy.lua'
}

-- Server scripts
server_scripts {
    'server/server.lua',
    'server/bridge.lua',
    'server/statebag.lua',
    'server/events.lua',
    'server/test_adapter.lua',
    'server/proxy.lua',
    'server/test_proxy.lua'
}

-- Client scripts (load order matters - dependencies first)
client_scripts {
    'client/statebag.lua',
    'client/client.lua',
    'client/proxy.lua'
}
