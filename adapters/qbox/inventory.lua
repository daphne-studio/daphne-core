---Qbox Inventory Module Adapter
---Inventory-related functions specific to Qbox

-- QboxAdapter is loaded via shared_scripts, so it's available as global
if not QboxAdapter then
    error('[Qbox Inventory] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

local Inventory = {}
Inventory.__index = Inventory

---Get item from player inventory
---@param source number Player server ID
---@param item string Item name
---@return table|nil itemData Item data or nil
function Inventory:GetItem(source, item)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return nil end
    
    return player.Functions.GetItemByName(item)
end

---Add item to player inventory
---@param source number Player server ID
---@param item string Item name
---@param amount number Amount to add
---@param slot number? Slot number (optional)
---@param info table? Item info/metadata (optional)
---@return boolean success True if successful
function Inventory:AddItem(source, item, amount, slot, info)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    return player.Functions.AddItem(item, amount, slot, info)
end

---Remove item from player inventory
---@param source number Player server ID
---@param item string Item name
---@param amount number Amount to remove
---@param slot number? Slot number (optional)
---@return boolean success True if successful
function Inventory:RemoveItem(source, item, amount, slot)
    local player = QboxAdapter:GetPlayer(source)
    if not player then return false end
    
    return player.Functions.RemoveItem(item, amount, slot)
end

---Check if player has item
---@param source number Player server ID
---@param item string Item name
---@param amount number? Amount to check (optional, defaults to 1)
---@return boolean hasItem True if player has item
function Inventory:HasItem(source, item, amount)
    amount = amount or 1
    local itemData = self:GetItem(source, item)
    
    if not itemData then return false end
    
    return itemData.amount >= amount
end

return Inventory

