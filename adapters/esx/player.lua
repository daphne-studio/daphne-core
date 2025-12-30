---ESX Player Module Adapter
---Additional player-related functions specific to ESX

-- ESXAdapter is loaded via shared_scripts, so it's available as global
if not ESXAdapter then
    error('[ESX Player] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
end

local Player = {}
Player.__index = Player

---Get player by identifier
---@param identifier string Player identifier
---@return table|nil player Player object or nil
function Player:GetPlayerByIdentifier(identifier)
    local esx = ESXAdapter:GetESX()
    if not esx then return nil end
    
    return esx.GetPlayerFromIdentifier(identifier)
end

---Get all players
---@return table players Table of all online players
function Player:GetPlayers()
    local esx = ESXAdapter:GetESX()
    if not esx then return {} end
    
    return esx.GetPlayers()
end

---Get player count
---@return number count Number of online players
function Player:GetPlayerCount()
    local players = self:GetPlayers()
    return #players
end

return Player

