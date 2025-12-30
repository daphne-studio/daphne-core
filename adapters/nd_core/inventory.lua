---ND Core Inventory Module Adapter
---Inventory-related functions specific to ND Core

-- These modules are loaded via shared_scripts, so they're available as globals
if not NDCoreAdapter then
    error('[ND Core Inventory] NDCoreAdapter not found! Make sure adapters/nd_core/adapter.lua is loaded.')
end

local Inventory = {}
Inventory.__index = Inventory

---Get item from player inventory
---@param source number Player server ID
---@param item string Item name
---@return table|nil itemData Item data or nil
function Inventory:GetItem(source, item)
    -- Check if using ox_inventory
    local usingOxInventory = false
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        usingOxInventory = true
    end
    
    if usingOxInventory then
        -- Use ox_inventory export
        local success, itemData = pcall(function()
            return exports.ox_inventory:GetItem(source, item)
        end)
        if success and itemData then
            return itemData
        end
    else
        -- Try to get from player inventory
        local player = NDCoreAdapter:GetPlayer(source)
        if player and player.inventory then
            for _, invItem in pairs(player.inventory) do
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
    -- Check if using ox_inventory
    local usingOxInventory = false
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        usingOxInventory = true
    end
    
    if usingOxInventory then
        -- Use ox_inventory export
        local success, result = pcall(function()
            return exports.ox_inventory:AddItem(source, item, amount, info)
        end)
        if success and result then
            Cache.InvalidatePlayer(source)
            return true
        end
    else
        -- ND Core doesn't have direct inventory management
        -- This would need to be handled by the inventory system
        print('[ND Core Inventory] Direct inventory management not available. Use ox_inventory or ND Core inventory system.')
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
    -- Check if using ox_inventory
    local usingOxInventory = false
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        usingOxInventory = true
    end
    
    if usingOxInventory then
        -- Use ox_inventory export
        local success, result = pcall(function()
            return exports.ox_inventory:RemoveItem(source, item, amount)
        end)
        if success and result then
            Cache.InvalidatePlayer(source)
            return true
        end
    else
        -- ND Core doesn't have direct inventory management
        -- This would need to be handled by the inventory system
        print('[ND Core Inventory] Direct inventory management not available. Use ox_inventory or ND Core inventory system.')
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
    
    -- Check if using ox_inventory
    local usingOxInventory = false
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        usingOxInventory = true
    end
    
    if usingOxInventory then
        -- Use ox_inventory export
        local success, itemData = pcall(function()
            return exports.ox_inventory:GetItem(source, item)
        end)
        if success and itemData and itemData.count then
            return itemData.count >= amount
        end
    else
        -- Try to check from player inventory
        local player = NDCoreAdapter:GetPlayer(source)
        if player and player.inventory then
            for _, invItem in pairs(player.inventory) do
                if invItem.name == item and (invItem.count or invItem.amount or 0) >= amount then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Export Inventory as global for use in bridge
NDCoreInventory = Inventory

return Inventory

