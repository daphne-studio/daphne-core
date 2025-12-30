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

---Get player metadata
---@param source number Player server ID
---@param key string? Metadata key (optional, returns all metadata if nil)
---@return any|nil metadata Metadata value or all metadata if key is nil
function Player:GetMetadata(source, key)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return nil end
    
    local metadata = player.PlayerData.metadata or {}
    
    if key then
        return metadata[key]
    end
    
    return metadata
end

---Set player metadata
---@param source number Player server ID
---@param key string Metadata key
---@param value any Metadata value
---@return boolean success True if successful
function Player:SetMetadata(source, key, value)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    if not player.PlayerData.metadata then
        player.PlayerData.metadata = {}
    end
    
    player.PlayerData.metadata[key] = value
    
    -- Sync to state bag
    if StateBag then
        StateBag.SetStateBag('player', source, 'data', {
            citizenid = player.PlayerData.citizenid,
            name = player.PlayerData.charinfo and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or '',
            money = player.PlayerData.money or {},
            job = player.PlayerData.job or {},
            gang = player.PlayerData.gang or {},
            metadata = player.PlayerData.metadata or {}
        })
    end
    
    return true
end

return Player

