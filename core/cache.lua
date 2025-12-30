---Player Object Cache Manager
---Provides TTL-based caching for player objects to reduce framework calls
Cache = Cache or {}
local Cache = Cache
Cache.__index = Cache

---Cache configuration
Cache.Config = {
    -- Default TTL for player objects (ms)
    PlayerTTL = 5000,
    
    -- Cleanup interval (ms)
    CleanupInterval = 60000,
    
    -- Maximum cache size (0 = unlimited)
    MaxCacheSize = 0
}

---Player object cache
---Structure: { [source] = { object = playerObject, timestamp = GetGameTimer(), ttl = TTL } }
Cache._playerCache = {}

---Cleanup timer
Cache._cleanupTimer = nil

---Get cached player object
---@param source number Player server ID
---@return table|nil player Player object or nil if not cached or expired
function Cache.GetPlayer(source)
    local cached = Cache._playerCache[source]
    if not cached then
        return nil
    end
    
    local now = GetGameTimer()
    local age = now - cached.timestamp
    local ttl = cached.ttl or Cache.Config.PlayerTTL
    
    -- Check if cache is expired
    if age >= ttl then
        Cache._playerCache[source] = nil
        return nil
    end
    
    return cached.object
end

---Set cached player object
---@param source number Player server ID
---@param player table Player object
---@param ttl number? Custom TTL in ms (optional)
function Cache.SetPlayer(source, player, ttl)
    if not source or not player then
        return
    end
    
    Cache._playerCache[source] = {
        object = player,
        timestamp = GetGameTimer(),
        ttl = ttl or Cache.Config.PlayerTTL
    }
    
    -- Start cleanup timer if not running
    if not Cache._cleanupTimer then
        Cache.StartCleanupTimer()
    end
end

---Invalidate player cache
---@param source number Player server ID
function Cache.InvalidatePlayer(source)
    if Cache._playerCache[source] then
        Cache._playerCache[source] = nil
    end
end

---Invalidate all player caches
function Cache.InvalidateAll()
    Cache._playerCache = {}
end

---Cleanup expired cache entries
function Cache.Cleanup()
    local now = GetGameTimer()
    local expired = {}
    
    for source, cached in pairs(Cache._playerCache) do
        local age = now - cached.timestamp
        local ttl = cached.ttl or Cache.Config.PlayerTTL
        
        if age >= ttl then
            table.insert(expired, source)
        end
    end
    
    -- Remove expired entries
    for _, source in ipairs(expired) do
        Cache._playerCache[source] = nil
    end
    
    -- Stop cleanup timer if cache is empty
    if not next(Cache._playerCache) then
        if Cache._cleanupTimer then
            ClearTimeout(Cache._cleanupTimer)
            Cache._cleanupTimer = nil
        end
    end
end

---Start periodic cleanup timer
function Cache.StartCleanupTimer()
    if Cache._cleanupTimer then
        return -- Already running
    end
    
    Cache._cleanupTimer = SetTimeout(Cache.Config.CleanupInterval, function()
        Cache.Cleanup()
        
        -- Schedule next cleanup if cache is not empty
        if next(Cache._playerCache) then
            Cache.StartCleanupTimer()
        else
            Cache._cleanupTimer = nil
        end
    end)
end

---Get cache statistics
---@return table stats Cache statistics
function Cache.GetStats()
    local count = 0
    local expired = 0
    local now = GetGameTimer()
    
    for _, cached in pairs(Cache._playerCache) do
        count = count + 1
        local age = now - cached.timestamp
        local ttl = cached.ttl or Cache.Config.PlayerTTL
        if age >= ttl then
            expired = expired + 1
        end
    end
    
    return {
        total = count,
        expired = expired,
        active = count - expired
    }
end

-- Export Cache as global for use in other scripts
Cache = Cache

return Cache

