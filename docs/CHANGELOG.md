# Changelog

Version history, breaking changes, migration guides, and deprecation notices.

## Version 1.1.0

**Release Date:** ND Core Adapter Release

### Features

- ND Core adapter support
- Character-based system support (multi-character)
- Groups system integration (jobs as groups)
- License system support
- Vehicle keys and ownership system
- ND Core event handlers (ND:moneyChange, ND:characterLoaded, ND:characterUnloaded, ND:updateCharacter)

### Supported Frameworks

- QBCore
- Qbox
- ESX Legacy
- **ND Core** (NEW)

### Breaking Changes

None

### Migration Guide

N/A

### Deprecation Notices

None

## Version 1.0.0

**Release Date:** Initial Release

### Features

- Adapter Pattern implementation
- QBCore/Qbox adapter support
- ESX Legacy adapter support
- State Bag system with batching and throttling
- Cache system for performance optimization
- Framework detection system
- Complete API exports (server and client)
- Inventory system detection (ox_inventory, qb-inventory, esx_inventory)
- Error handling system
- Performance optimizations (0.00ms policy)

### Supported Frameworks

- QBCore
- Qbox
- ESX Legacy

### Supported Inventory Systems

- ox_inventory
- qb-inventory
- esx_inventory

### API Exports

**Server Exports:**
- GetPlayer
- GetPlayerData
- GetMoney
- AddMoney
- RemoveMoney
- GetInventory
- GetItem
- AddItem
- RemoveItem
- HasItem
- GetJob
- GetGang (QBCore only)
- GetVehicle
- GetMetadata
- SetMetadata

**Client Exports:**
- GetPlayer
- GetPlayerData
- GetMoney
- GetPlayerStateBag
- WatchPlayerStateBag

### Breaking Changes

None (initial release)

### Migration Guide

N/A (initial release)

### Deprecation Notices

None

## Future Versions

### Planned Features

- OX Core adapter support
- Additional framework adapters
- Enhanced error handling
- Performance improvements
- Additional API exports

### Known Issues

None currently

## Related Documentation

- [API Reference](API_REFERENCE.md) - Export function documentation
- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns
- [Quick Start](QUICK_START.md) - Getting started guide

