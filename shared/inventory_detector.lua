---Inventory System Detector
---Detects which inventory system is being used (ox_inventory, qb-inventory, esx_inventory)
InventoryDetector = InventoryDetector or {}
local InventoryDetector = InventoryDetector

---Detect which inventory system is being used
---@param framework string? Framework name ('qbox', 'esx', etc.) - optional, auto-detects if nil
---@return string|nil inventorySystem Inventory system name or nil if none detected
function InventoryDetector.Detect(framework)
    -- Check for ox_inventory first (works with both QBCore and ESX)
    local success, _ = pcall(function()
        return exports.ox_inventory
    end)
    if success then
        return 'ox_inventory'
    end
    
    -- Framework-specific detection
    if not framework then
        -- Try to auto-detect framework
        if GetResourceState('qbx_core') == 'started' or GetResourceState('qb-core') == 'started' then
            framework = 'qbox'
        elseif GetResourceState('es_extended') == 'started' then
            framework = 'esx'
        end
    end
    
    if framework == 'qbox' or framework == 'qbcore' then
        -- Check for qb-inventory
        if GetResourceState('qb-inventory') == 'started' then
            return 'qb-inventory'
        end
    elseif framework == 'esx' then
        -- Check for esx_inventory
        if GetResourceState('esx_inventory') == 'started' then
            return 'esx_inventory'
        end
    end
    
    return nil
end

---Check if using ox_inventory
---@return boolean isOxInventory True if ox_inventory is detected
function InventoryDetector.IsOxInventory()
    return InventoryDetector.Detect() == 'ox_inventory'
end

---Check if using framework-specific inventory
---@param framework string Framework name
---@return boolean isFrameworkInventory True if framework inventory is detected
function InventoryDetector.IsFrameworkInventory(framework)
    local system = InventoryDetector.Detect(framework)
    return system ~= nil and system ~= 'ox_inventory'
end

-- Export InventoryDetector as global for use in other scripts
InventoryDetector = InventoryDetector

return InventoryDetector

