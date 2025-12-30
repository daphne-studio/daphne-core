---Qbox Player Module Adapter
---Additional player-related functions specific to Qbox

-- QboxAdapter is loaded via shared_scripts, so it's available as global
if not QboxAdapter then
    error('[Qbox Player] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

local Player = {}
Player.__index = Player

---Get player by citizenid
---@param citizenid string Citizen ID
---@return table|nil player Player object or nil
function Player:GetPlayerByCitizenId(citizenid)
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return nil end
    
    return qbCore:GetPlayerByCitizenId(citizenid)
end

---Get player by license
---@param license string License identifier
---@return table|nil player Player object or nil
function Player:GetPlayerByLicense(license)
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return nil end
    
    return qbCore:GetPlayerByLicense(license)
end

---Get all players
---@return table players Table of all online players
function Player:GetPlayers()
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return {} end
    
    return qbCore:GetPlayers()
end

---Get player count
---@return number count Number of online players
function Player:GetPlayerCount()
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return 0 end
    
    return qbCore:GetQBPlayers() and #qbCore:GetQBPlayers() or 0
end

return Player

