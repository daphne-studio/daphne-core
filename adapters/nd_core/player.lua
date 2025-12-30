---ND Core Player Module Adapter
---Additional player-related functions specific to ND Core

-- NDCoreAdapter is loaded via shared_scripts, so it's available as global
if not NDCoreAdapter then
    error('[ND Core Player] NDCoreAdapter not found! Make sure adapters/nd_core/adapter.lua is loaded.')
end

local Player = {}
Player.__index = Player

---Get player by citizenid (character ID)
---@param citizenid string|number Character ID
---@param source number? Player server ID (optional, for ownership check)
---@return table|nil player Player object or nil
function Player:GetPlayerByCitizenId(citizenid, source)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return nil end
    
    local success, player = pcall(function()
        if ndCore.fetchCharacter then
            return ndCore.fetchCharacter(tostring(citizenid), source)
        end
        return nil
    end)
    
    if success and player then
        return player
    end
    
    return nil
end

---Get all players
---@param key string? Filter key (optional)
---@param value any? Filter value (optional)
---@param returnArray boolean? Return as array (optional, default: false)
---@return table players Table of all online players
function Player:GetPlayers(key, value, returnArray)
    local ndCore = NDCoreAdapter:GetNDCore()
    if not ndCore then return returnArray and {} or {} end
    
    local success, players = pcall(function()
        if ndCore.getPlayers then
            return ndCore.getPlayers(key, value, returnArray)
        end
        return returnArray and {} or {}
    end)
    
    if success and players then
        return players
    end
    
    return returnArray and {} or {}
end

---Get player count
---@return number count Number of online players
function Player:GetPlayerCount()
    local players = self:GetPlayers(nil, nil, true)
    return #players
end

return Player

