---ESX Inventory Module Adapter
---Inventory-related functions specific to ESX

-- ESXAdapter is loaded via shared_scripts, so it's available as global
if not ESXAdapter then
    error('[ESX Inventory] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
end

local Inventory = {}
Inventory.__index = Inventory

---Detect which inventory system is being used
---@return string|nil inventorySystem 'ox_inventory', 'esx_inventory', or nil
local function DetectInventorySystem()
    -- Check for ox_inventory
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        return 'ox_inventory'
    end
    
    -- Check for esx_inventory
    if GetResourceState('esx_inventory') == 'started' then
        return 'esx_inventory'
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
    elseif inventorySystem == 'esx_inventory' then
        -- ESX standard inventory
        local xPlayer = ESXAdapter:GetPlayer(source)
        if not xPlayer then return nil end
        
        local inventory = xPlayer.getInventory()
        if inventory then
            for _, invItem in pairs(inventory) do
                if invItem.name == item then
                    return invItem
                end
            end
        end
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
    elseif inventorySystem == 'esx_inventory' then
        local xPlayer = ESXAdapter:GetPlayer(source)
        if not xPlayer then return false end
        
        xPlayer.addInventoryItem(item, amount)
        return true
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
    elseif inventorySystem == 'esx_inventory' then
        local xPlayer = ESXAdapter:GetPlayer(source)
        if not xPlayer then return false end
        
        xPlayer.removeInventoryItem(item, amount)
        return true
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
    local itemData = self:GetItem(source, item)
    
    if not itemData then return false end
    
    local itemAmount = itemData.count or itemData.amount or 0
    return itemAmount >= amount
end

return Inventory

