# Architecture

Complete architecture documentation for daphne-core. This document covers system design, component interactions, and architectural patterns.

## Table of Contents

- [System Overview](#system-overview)
- [Adapter Pattern](#adapter-pattern)
- [Component Architecture](#component-architecture)
- [Data Flow](#data-flow)
- [Initialization Sequence](#initialization-sequence)
- [Module Dependencies](#module-dependencies)
- [State Bag Architecture](#state-bag-architecture)
- [Cache Architecture](#cache-architecture)

## System Overview

daphne-core is a framework bridge system that provides a unified API for multiple FiveM frameworks using the Adapter Design Pattern.

### High-Level Architecture

```mermaid
graph TB
    subgraph "Your Scripts"
        Script1[Script 1]
        Script2[Script 2]
        Script3[Script 3]
    end
    
    subgraph "daphne-core"
        Bridge[Bridge Interface]
        Adapter1[Qbox Adapter]
        Adapter2[ESX Adapter]
        StateBag[State Bag Manager]
        Cache[Cache Manager]
    end
    
    subgraph "Frameworks"
        QBCore[QBCore/Qbox]
        ESX[ESX Legacy]
    end
    
    Script1 --> Bridge
    Script2 --> Bridge
    Script3 --> Bridge
    
    Bridge --> Adapter1
    Bridge --> Adapter2
    
    Adapter1 --> QBCore
    Adapter2 --> ESX
    
    Bridge --> StateBag
    Bridge --> Cache
    
    StateBag --> Script1
    StateBag --> Script2
    StateBag --> Script3
```

## Adapter Pattern

daphne-core uses the Adapter Design Pattern to provide a unified interface across different frameworks.

### Pattern Structure

```mermaid
classDiagram
    class Bridge {
        <<abstract>>
        +Initialize() boolean
        +GetPlayer(source) table
        +GetPlayerData(source) table
        +GetMoney(source, type) number
        +AddMoney(source, type, amount) boolean
        +RemoveMoney(source, type, amount) boolean
        +GetInventory(source) table
        +GetJob(source) table
        +GetVehicle(vehicle) table
    }
    
    class QboxAdapter {
        +Initialize() boolean
        +GetPlayer(source) table
        +GetPlayerData(source) table
        +GetMoney(source, type) number
        +AddMoney(source, type, amount) boolean
        +RemoveMoney(source, type, amount) boolean
        +GetInventory(source) table
        +GetJob(source) table
        +GetGang(source) table
        +GetVehicle(vehicle) table
    }
    
    class ESXAdapter {
        +Initialize() boolean
        +GetPlayer(source) table
        +GetPlayerData(source) table
        +GetMoney(source, type) number
        +AddMoney(source, type, amount) boolean
        +RemoveMoney(source, type, amount) boolean
        +GetInventory(source) table
        +GetJob(source) table
        +GetVehicle(vehicle) table
    }
    
    Bridge <|-- QboxAdapter
    Bridge <|-- ESXAdapter
```

### Framework Detection Flow

```mermaid
flowchart TD
    Start[Resource Start] --> Detect[Detect Framework]
    Detect --> CheckQbox{Check qbx_core}
    CheckQbox -->|Found| InitQbox[Initialize Qbox Adapter]
    CheckQbox -->|Not Found| CheckQBCore{Check qb-core}
    CheckQBCore -->|Found| InitQBCore[Initialize QBCore Adapter]
    CheckQBCore -->|Not Found| CheckESX{Check es_extended}
    CheckESX -->|Found| InitESX[Initialize ESX Adapter]
    CheckESX -->|Not Found| Error[No Framework Detected]
    InitQbox --> Success[Adapter Ready]
    InitQBCore --> Success
    InitESX --> Success
    Success --> Ready[Bridge Ready]
```

## Component Architecture

### Core Components

```mermaid
graph LR
    subgraph "Core Layer"
        Bridge[Bridge Interface]
        StateBag[State Bag Manager]
        Cache[Cache Manager]
        ErrorHandler[Error Handler]
    end
    
    subgraph "Adapter Layer"
        QboxAdapter[Qbox Adapter]
        ESXAdapter[ESX Adapter]
        QboxInventory[Qbox Inventory]
        ESXInventory[ESX Inventory]
    end
    
    subgraph "Shared Layer"
        Config[Config]
        Types[Types]
        InventoryDetector[Inventory Detector]
    end
    
    Bridge --> QboxAdapter
    Bridge --> ESXAdapter
    QboxAdapter --> QboxInventory
    ESXAdapter --> ESXInventory
    Bridge --> StateBag
    Bridge --> Cache
    QboxAdapter --> Config
    ESXAdapter --> Config
    QboxAdapter --> InventoryDetector
    ESXAdapter --> InventoryDetector
```

### Server Components

```mermaid
graph TB
    subgraph "Server Layer"
        ServerBridge[Server Bridge]
        ServerStateBag[Server State Bag]
        ServerEvents[Server Events]
    end
    
    subgraph "Core Layer"
        Bridge[Bridge Interface]
        StateBag[State Bag Manager]
    end
    
    ServerBridge --> Bridge
    ServerStateBag --> StateBag
    ServerEvents --> Bridge
    ServerEvents --> StateBag
```

### Client Components

```mermaid
graph TB
    subgraph "Client Layer"
        ClientBridge[Client Bridge]
        ClientStateBag[Client State Bag]
    end
    
    subgraph "Core Layer"
        Bridge[Bridge Interface]
        StateBag[State Bag Manager]
    end
    
    ClientBridge --> Bridge
    ClientStateBag --> StateBag
```

## Data Flow

### Read Operation Flow

```mermaid
sequenceDiagram
    participant Script
    participant Bridge
    participant Adapter
    participant Cache
    participant Framework
    
    Script->>Bridge: GetPlayerData(source)
    Bridge->>Adapter: GetPlayerData(source)
    Adapter->>Cache: GetPlayer(source)
    Cache-->>Adapter: Cached Player (if available)
    alt Cache Hit
        Adapter-->>Bridge: Use Cached Player
    else Cache Miss
        Adapter->>Framework: GetPlayer(source)
        Framework-->>Adapter: Player Object
        Adapter->>Cache: SetPlayer(source, player)
        Adapter->>Adapter: Map to PlayerData
    end
    Adapter-->>Bridge: PlayerData
    Bridge-->>Script: PlayerData
```

### Write Operation Flow

```mermaid
sequenceDiagram
    participant Script
    participant Bridge
    participant Adapter
    participant Cache
    participant StateBag
    participant Framework
    
    Script->>Bridge: AddMoney(source, 'cash', 1000)
    Bridge->>Adapter: AddMoney(source, 'cash', 1000)
    Adapter->>Framework: AddMoney(source, 'cash', 1000)
    Framework-->>Adapter: Success
    Adapter->>Cache: InvalidatePlayer(source)
    Adapter->>Adapter: GetPlayerData(source)
    Adapter->>StateBag: SetStateBag('player', source, 'money', data)
    StateBag->>StateBag: Queue Update
    StateBag->>StateBag: Process Batch (50ms)
    StateBag-->>Clients: Sync State Bag
    Adapter-->>Bridge: true
    Bridge-->>Script: true
```

### State Bag Update Flow

```mermaid
sequenceDiagram
    participant Server
    participant StateBag
    participant Queue
    participant BatchProcessor
    participant Clients
    
    Server->>StateBag: SetStateBag(entity, id, key, value)
    StateBag->>StateBag: Check Change Detection
    alt Value Changed
        StateBag->>Queue: Add to Queue
        Queue->>BatchProcessor: Check Batch Timer
        alt Batch Ready (50ms)
            BatchProcessor->>BatchProcessor: Process Batch
            BatchProcessor->>BatchProcessor: Apply Throttling
            BatchProcessor->>Clients: Send Updates
        end
    else Value Unchanged
        StateBag-->>Server: Skip Update
    end
```

## Initialization Sequence

### Server Initialization

```mermaid
sequenceDiagram
    participant Server
    participant Config
    participant Bridge
    participant Adapter
    participant Framework
    
    Server->>Config: Initialize()
    Config->>Config: DetectFramework()
    Config-->>Server: Framework Name
    
    Server->>Bridge: InitializeBridge()
    Bridge->>Adapter: Initialize()
    
    alt QBCore/Qbox
        Adapter->>Framework: Check Exports
        Framework-->>Adapter: Exports Available
        Adapter->>Adapter: Set Initialized
    else ESX
        Adapter->>Framework: getSharedObject()
        Framework-->>Adapter: ESX Object
        Adapter->>Adapter: Set Initialized
    end
    
    Adapter-->>Bridge: Success
    Bridge-->>Server: Ready
```

### Client Initialization

```mermaid
sequenceDiagram
    participant Client
    participant Config
    participant Bridge
    participant Adapter
    
    Client->>Config: Initialize()
    Config->>Config: DetectFramework()
    Config-->>Client: Framework Name
    
    Client->>Bridge: InitializeBridge()
    Bridge->>Adapter: Initialize()
    Adapter->>Adapter: Set Initialized
    Adapter-->>Bridge: Success
    Bridge-->>Client: Ready
```

## Module Dependencies

### Dependency Graph

```mermaid
graph TD
    Types[types.lua]
    Config[config.lua]
    InventoryDetector[inventory_detector.lua]
    ErrorHandler[error_handler.lua]
    Bridge[bridge.lua]
    Cache[cache.lua]
    StateBag[statebag.lua]
    
    QboxAdapter[qbox/adapter.lua]
    QboxPlayer[qbox/player.lua]
    QboxMoney[qbox/money.lua]
    QboxInventory[qbox/inventory.lua]
    QboxJob[qbox/job.lua]
    QboxVehicle[qbox/vehicle.lua]
    
    ESXAdapter[esx/adapter.lua]
    ESXPlayer[esx/player.lua]
    ESXMoney[esx/money.lua]
    ESXInventory[esx/inventory.lua]
    ESXJob[esx/job.lua]
    ESXVehicle[esx/vehicle.lua]
    
    ServerBridge[server/bridge.lua]
    ServerStateBag[server/statebag.lua]
    ServerEvents[server/events.lua]
    
    ClientBridge[client/client.lua]
    ClientStateBag[client/statebag.lua]
    
    Types --> Config
    Types --> Bridge
    Config --> Bridge
    Config --> QboxAdapter
    Config --> ESXAdapter
    InventoryDetector --> QboxInventory
    InventoryDetector --> ESXInventory
    ErrorHandler --> Bridge
    
    Bridge --> QboxAdapter
    Bridge --> ESXAdapter
    Cache --> QboxAdapter
    Cache --> ESXAdapter
    StateBag --> QboxAdapter
    StateBag --> ESXAdapter
    
    QboxAdapter --> QboxPlayer
    QboxAdapter --> QboxMoney
    QboxAdapter --> QboxInventory
    QboxAdapter --> QboxJob
    QboxAdapter --> QboxVehicle
    
    ESXAdapter --> ESXPlayer
    ESXAdapter --> ESXMoney
    ESXAdapter --> ESXInventory
    ESXAdapter --> ESXJob
    ESXAdapter --> ESXVehicle
    
    Bridge --> ServerBridge
    Bridge --> ClientBridge
    StateBag --> ServerStateBag
    StateBag --> ClientStateBag
    
    ServerBridge --> ServerEvents
    ServerStateBag --> ServerEvents
```

### Load Order

The load order in `fxmanifest.lua` ensures dependencies are loaded before dependents:

1. **Shared Scripts** (loaded first):
   - `shared/types.lua`
   - `shared/config.lua`
   - `shared/inventory_detector.lua`
   - `core/error_handler.lua`
   - `core/bridge.lua`
   - `core/cache.lua`
   - `core/statebag.lua`
   - Adapters and their modules

2. **Server Scripts**:
   - `server/server.lua`
   - `server/bridge.lua`
   - `server/statebag.lua`
   - `server/events.lua`

3. **Client Scripts**:
   - `client/statebag.lua`
   - `client/client.lua`

## State Bag Architecture

### State Bag Manager Structure

```mermaid
graph TB
    subgraph "State Bag Manager"
        Queue[Update Queue]
        Cache[State Bag Cache]
        BatchProcessor[Batch Processor]
        Throttle[Throttle Manager]
        ChangeDetector[Change Detector]
    end
    
    subgraph "FiveM State Bags"
        PlayerStateBag[Player State Bags]
        VehicleStateBag[Vehicle State Bags]
    end
    
    Queue --> BatchProcessor
    BatchProcessor --> Throttle
    Throttle --> ChangeDetector
    ChangeDetector --> Cache
    ChangeDetector --> PlayerStateBag
    ChangeDetector --> VehicleStateBag
```

### Batch Processing Flow

```mermaid
flowchart TD
    Start[Update Request] --> CheckChange{Value Changed?}
    CheckChange -->|No| Skip[Skip Update]
    CheckChange -->|Yes| UpdateCache[Update Cache]
    UpdateCache --> AddQueue[Add to Queue]
    AddQueue --> CheckTimer{Timer Running?}
    CheckTimer -->|No| StartTimer[Start Batch Timer]
    CheckTimer -->|Yes| Wait[Wait for Timer]
    StartTimer --> Wait
    Wait --> ProcessBatch[Process Batch]
    ProcessBatch --> CheckThrottle{Throttled?}
    CheckThrottle -->|Yes| Delay[Delay to Next Batch]
    CheckThrottle -->|No| SendUpdate[Send Update]
    Delay --> ProcessBatch
    SendUpdate --> CheckMore{More Updates?}
    CheckMore -->|Yes| ProcessBatch
    CheckMore -->|No| Done[Done]
```

## Cache Architecture

### Cache Manager Structure

```mermaid
graph TB
    subgraph "Cache Manager"
        PlayerCache[Player Cache]
        TTLManager[TTL Manager]
        CleanupTimer[Cleanup Timer]
    end
    
    subgraph "Cache Entry"
        PlayerObject[Player Object]
        Timestamp[Timestamp]
        TTL[TTL Value]
    end
    
    PlayerCache --> PlayerObject
    PlayerCache --> Timestamp
    PlayerCache --> TTL
    TTLManager --> CleanupTimer
    CleanupTimer --> PlayerCache
```

### Cache Flow

```mermaid
sequenceDiagram
    participant Request
    participant Cache
    participant TTL
    participant Framework
    
    Request->>Cache: GetPlayer(source)
    Cache->>Cache: Check Cache
    alt Cache Hit
        Cache->>TTL: Check TTL
        alt TTL Valid
            Cache-->>Request: Return Cached Player
        else TTL Expired
            Cache->>Cache: Remove Entry
            Cache->>Framework: GetPlayer(source)
            Framework-->>Cache: Player Object
            Cache->>Cache: Store in Cache
            Cache-->>Request: Return Player
        end
    else Cache Miss
        Cache->>Framework: GetPlayer(source)
        Framework-->>Cache: Player Object
        Cache->>Cache: Store in Cache
        Cache-->>Request: Return Player
    end
```

## Related Documentation

- [Adapter Pattern Guide](ADAPTER_PATTERN.md) - Adapter implementation details
- [State Bag System](STATE_BAG_SYSTEM.md) - State bag usage guide
- [Performance Guide](PERFORMANCE.md) - Performance optimizations
- [API Reference](API_REFERENCE.md) - Export function documentation

