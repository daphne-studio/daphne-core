---Qbox Inventory Module Adapter
---Inventory-related functions specific to Qbox

-- QboxAdapter is loaded via shared_scripts, so it's available as global
if not QboxAdapter then
    error('[Qbox Inventory] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

local Inventory = {}
Inventory.__index = Inventory

---Detect which inventory system is being used
---@return string|nil inventorySystem 'ox_inventory', 'qb-inventory', or nil
local function DetectInventorySystem()
    -- Check for ox_inventory
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        return 'ox_inventory'
    end
    
    -- Check for qb-inventory
    if GetResourceState('qb-inventory') == 'started' then
        return 'qb-inventory'
    end
    
    return nil
end

---Get item from player inventory
---@param source number Player server ID
---@param item string Item name
---@return table|nil itemData Item data or nil
function Inventory:GetItem(source, item)
    local inventorySystem = DetectInventorySystem()
    
    if inventorySystem == 'ox_inventory' then
        -- ox_inventory uses different API
        local success, itemData = pcall(function()
            return exports.ox_inventory:GetItem(source, item)
        end)
        if success and itemData then
            return itemData
        end
    elseif inventorySystem == 'qb-inventory' or not inventorySystem then
        -- QBCore standard inventory or fallback
        local player = QboxAdapter:GetPlayer(source)
        if not player then return nil end
        
        return player.Functions.GetItemByName(item)
    end
    
    return nil
end

---Add item to player inventory
---@param source number Player server ID
---@param item string Item name
---@param amount number Amount to add
---@param slot number? Slot number (optional)
---@param info table? Item info/metadata (optional)
---@return boolean success True if successful
function Inventory:AddItem(source, item, amount, slot, info)
    local inventorySystem = DetectInventorySystem()
    
    if inventorySystem == 'ox_inventory' then
        local success, result = pcall(function()
            return exports.ox_inventory:AddItem(source, item, amount, info)
        end)
        return success and result ~= false
    elseif inventorySystem == 'qb-inventory' or not inventorySystem then
        local player = QboxAdapter:GetPlayer(source)
        if not player then return false end
        
        return player.Functions.AddItem(item, amount, slot, info)
    end
    
    return false
end

---Remove item from player inventory
---@param source number Player server ID
---@param item string Item name
---@param amount number Amount to remove
---@param slot number? Slot number (optional)
---@return boolean success True if successful
function Inventory:RemoveItem(source, item, amount, slot)
    local inventorySystem = DetectInventorySystem()
    
    if inventorySystem == 'ox_inventory' then
        local success, result = pcall(function()
            return exports.ox_inventory:RemoveItem(source, item, amount)
        end)
        return success and result ~= false
    elseif inventorySystem == 'qb-inventory' or not inventorySystem then
        local player = QboxAdapter:GetPlayer(source)
        if not player then return false end
        
        return player.Functions.RemoveItem(item, amount, slot)
    end
    
    return false
end

---Check if player has item
---@param source number Player server ID
---@param item string Item name
---@param amount number? Amount to check (optional, defaults to 1)
---@return boolean hasItem True if player has item
function Inventory:HasItem(source, item, amount)
    amount = amount or 1
    local inventorySystem = DetectInventorySystem()
    
    if inventorySystem == 'ox_inventory' then
        local success, itemData = pcall(function()
            return exports.ox_inventory:GetItem(source, item)
        end)
        if success and itemData then
            local itemAmount = itemData.count or itemData.amount or 0
            return itemAmount >= amount
        end
        return false
    else
        local itemData = self:GetItem(source, item)
        
        if not itemData then return false end
        
        local itemAmount = itemData.amount or itemData.count or 0
        return itemAmount >= amount
    end
end

-- Export Inventory as global for use in other scripts
QboxInventory = Inventory

return Inventory

