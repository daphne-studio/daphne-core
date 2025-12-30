# Daphne Core - Usage Examples

This directory contains practical examples demonstrating how to use Daphne Core bridge in your FiveM resources.

## Files

### `server_basic.lua`
Basic server-side usage examples including:
- Getting player data
- Money operations (add/remove/check)
- Job checking and permissions
- Vehicle information
- Command examples

**Usage**: Copy relevant examples to your server-side script.

### `client_basic.lua`
Basic client-side usage examples including:
- Getting local player data
- Displaying money in HUD
- Watching state bag changes
- Money validation functions

**Usage**: Copy relevant examples to your client-side script.

### `statebag_advanced.lua`
Advanced state bag usage patterns including:
- Debounced watchers
- Multiple key watchers
- State bag caching with TTL
- Change aggregation
- State bag validation

**Usage**: Copy utility functions to your scripts for advanced state bag management.

### `resource_integration.lua`
Complete resource integration examples showing:
- Shop system implementation
- Job-based access control
- Money transfer system
- HUD integration
- Real-world usage patterns

**Usage**: Use as a reference for integrating Daphne Core into your own resources.

### `esx_integration.lua`
ESX-specific integration examples including:
- ESX job-based access control
- Money transfer between players
- Shop system with inventory checks
- Job salary system
- Custom account management (dirty money)
- Inventory item requirements
- State bag watchers for HUD updates
- ESX-specific patterns and best practices

**Usage**: Copy ESX-specific examples to your ESX-based resources.

### `qbcore_integration.lua`
QBCore/Qbox-specific integration examples including:
- QBCore job-based access control
- QBCore gang-based access control (QBCore exclusive)
- Money transfer between players
- Shop system with inventory checks
- Job salary system
- Metadata management (hunger/thirst system)
- Inventory item requirements
- Vehicle ownership checks
- Gang territory system
- ox_inventory specific usage
- State bag watchers for HUD updates
- QBCore-specific patterns and best practices

**Usage**: Copy QBCore-specific examples to your QBCore/Qbox-based resources.

## Quick Start

1. **Basic Server Usage**:
   ```lua
   local playerData = exports['daphne_core']:GetPlayerData(source)
   local money = exports['daphne_core']:GetMoney(source, 'cash')
   ```

2. **Basic Client Usage**:
   ```lua
   local playerData = exports['daphne_core']:GetPlayerData()
   local cash = exports['daphne_core']:GetMoney('cash')
   ```

3. **Watch State Bag Changes**:
   ```lua
   exports['daphne_core']:WatchPlayerStateBag('money', function(value, oldValue)
       print('Money changed!')
   end)
   ```

## Framework-Specific Examples

- **Qbox/QBCore**: See `qbcore_integration.lua` for QBCore-specific patterns and examples
- **ESX Legacy**: See `esx_integration.lua` for ESX-specific patterns and examples
- **General**: See `server_basic.lua` and `client_basic.lua` for framework-agnostic examples

## Notes

- All examples are ready to use but may require modification for your specific use case
- Replace placeholder inventory/HUD systems with your actual implementations
- Examples use standard FiveM natives and events
- State bag watchers persist until resource restart

## Contributing

Feel free to add more examples or improve existing ones!

