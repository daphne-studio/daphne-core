# Documentation Index

Complete navigation structure for daphne-core documentation.

## Quick Start

- [Quick Start Guide](QUICK_START.md) - Get started in 5 minutes

## Core Documentation

### API Reference
- [API Reference](API_REFERENCE.md) - Complete export function documentation

### Architecture
- [Architecture](ARCHITECTURE.md) - System architecture and design
- [Adapter Pattern Guide](ADAPTER_PATTERN.md) - Adapter implementation details

### Data Structures
- [Data Structures](DATA_STRUCTURES.md) - Complete data structure reference

### Systems
- [State Bag System](STATE_BAG_SYSTEM.md) - State bag usage guide
- [Performance Guide](PERFORMANCE.md) - Performance optimizations
- [Error Handling](ERROR_HANDLING.md) - Error handling guide

### Proxy System
- [Proxy System](PROXY_SYSTEM.md) - Complete proxy system documentation
- [Cross-Framework Proxy Guide](CROSS_FRAMEWORK_PROXY.md) - Cross-framework usage guide
- [Proxy Limitations](PROXY_LIMITATIONS.md) - Limitations and workarounds guide
- [Proxy Mapping Reference](PROXY_MAPPING.md) - Complete API mapping reference
- [ND_Core Proxy Guide](PROXY_ND_CORE.md) - ND_Core-specific proxy documentation

## Integration

- [Integration Guide](INTEGRATION_GUIDE.md) - Integration patterns and migration
- [Examples Collection](EXAMPLES_COLLECTION.md) - Code examples and walkthroughs

## Reference

- [FAQ](FAQ.md) - Frequently asked questions
- [Changelog](CHANGELOG.md) - Version history and changes

## Documentation by Topic

### Getting Started
1. [Quick Start Guide](QUICK_START.md)
2. [API Reference](API_REFERENCE.md)
3. [Integration Guide](INTEGRATION_GUIDE.md)

### Understanding the System
1. [Architecture](ARCHITECTURE.md)
2. [Adapter Pattern Guide](ADAPTER_PATTERN.md)
3. [Data Structures](DATA_STRUCTURES.md)

### Using daphne-core
1. [API Reference](API_REFERENCE.md)
2. [State Bag System](STATE_BAG_SYSTEM.md)
3. [Proxy System](PROXY_SYSTEM.md) - Cross-framework proxy
4. [Examples Collection](EXAMPLES_COLLECTION.md)

### Advanced Topics
1. [Performance Guide](PERFORMANCE.md)
2. [Error Handling](ERROR_HANDLING.md)
3. [Adapter Pattern Guide](ADAPTER_PATTERN.md)
4. [Cross-Framework Proxy Guide](CROSS_FRAMEWORK_PROXY.md) - Cross-framework compatibility
5. [Proxy Limitations](PROXY_LIMITATIONS.md) - Understanding limitations

### Troubleshooting
1. [FAQ](FAQ.md)
2. [Error Handling](ERROR_HANDLING.md)
3. [Integration Guide](INTEGRATION_GUIDE.md)

## Documentation by Audience

### Beginners
- [Quick Start Guide](QUICK_START.md)
- [API Reference](API_REFERENCE.md) - Basic usage
- [Examples Collection](EXAMPLES_COLLECTION.md) - Simple examples

### Intermediate Developers
- [Integration Guide](INTEGRATION_GUIDE.md)
- [State Bag System](STATE_BAG_SYSTEM.md)
- [Proxy System](PROXY_SYSTEM.md) - Cross-framework proxy
- [Examples Collection](EXAMPLES_COLLECTION.md) - Advanced examples

### Advanced Developers
- [Architecture](ARCHITECTURE.md)
- [Adapter Pattern Guide](ADAPTER_PATTERN.md)
- [Performance Guide](PERFORMANCE.md)

### Framework Maintainers
- [Architecture](ARCHITECTURE.md)
- [Adapter Pattern Guide](ADAPTER_PATTERN.md)
- [Data Structures](DATA_STRUCTURES.md)

## Quick Reference

### Server Exports
- `GetPlayer(source)` - Get player object
- `GetPlayerData(source)` - Get player data
- `GetMoney(source, type)` - Get money
- `AddMoney(source, type, amount)` - Add money
- `RemoveMoney(source, type, amount)` - Remove money
- `GetInventory(source)` - Get inventory
- `GetItem(source, item)` - Get item
- `AddItem(source, item, amount, slot, info)` - Add item
- `RemoveItem(source, item, amount, slot)` - Remove item
- `HasItem(source, item, amount)` - Check item
- `GetJob(source)` - Get job
- `GetGang(source)` - Get gang (QBCore only)
- `GetVehicle(vehicle)` - Get vehicle
- `GetMetadata(source, key)` - Get metadata
- `SetMetadata(source, key, value)` - Set metadata

### Client Exports
- `GetPlayer()` - Get local player
- `GetPlayerData()` - Get local player data
- `GetMoney(type)` - Get local money
- `GetPlayerStateBag(key)` - Get state bag value
- `WatchPlayerStateBag(key, callback)` - Watch state bag changes

### State Bag Keys
- `money` - Player money data
- `job` - Player job data
- `gang` - Player gang data (QBCore only)
- `data` - Complete player data snapshot

## Related Resources

- [Main README](../README.md) - Project overview
- [Examples Directory](../examples/) - Example files
- [Framework Documentation](QBCore.md) - QBCore-specific docs
- [Framework Documentation](ESX.md) - ESX-specific docs
- [Framework Documentation](ND_Core.md) - ND Core-specific docs
- [Proxy System Documentation](PROXY_SYSTEM.md) - Cross-framework proxy system

