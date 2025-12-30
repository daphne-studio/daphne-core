---Qbox Money Module Adapter
---Money-related functions specific to Qbox

-- These modules are loaded via shared_scripts, so they're available as globals
if not QboxAdapter then
    error('[Qbox Money] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

if not StateBag then
    error('[Qbox Money] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Money = {}
Money.__index = Money

---Get all money types for player
---@param source number Player server ID
---@return table|nil moneyTable All money types or nil
function Money:GetAllMoney(source)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return nil end
    
    return player.PlayerData.money or {}
end

---Set money for player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to set
---@return boolean success True if successful
function Money:SetMoney(source, type, amount)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    local success = player.Functions.SetMoney(type, amount)
    
    if success then
        -- Sync to state bag
        StateBag.SetStateBag('player', source, 'money', player.PlayerData.money)
    end
    
    return success
end

---Check if player has enough money
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to check
---@return boolean hasMoney True if player has enough
function Money:HasMoney(source, type, amount)
    local money = QboxAdapter:GetMoney(source, type)
    if not money then return false end
    
    return money >= amount
end

return Money

