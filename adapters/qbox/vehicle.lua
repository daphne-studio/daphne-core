---Qbox Vehicle Module Adapter
---Vehicle-related functions specific to Qbox

-- These modules are loaded via shared_scripts, so they're available as globals
if not QboxAdapter then
    error('[Qbox Vehicle] QboxAdapter not found! Make sure adapters/qbox/adapter.lua is loaded.')
end

if not StateBag then
    error('[Qbox Vehicle] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Vehicle = {}
Vehicle.__index = Vehicle

---Get vehicle by plate
---@param plate string Vehicle plate
---@return table|nil vehicleData Vehicle data or nil
function Vehicle:GetVehicleByPlate(plate)
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return nil end
    
    -- Try to get vehicle from database via QBCore
    local success, vehicleData = pcall(function()
        -- Try QBX export first
        if exports['qbx_core'] and exports['qbx_core'].GetVehicleByPlate then
            return exports['qbx_core']:GetVehicleByPlate(plate)
        end
        -- Try QBCore export
        if exports['qb-core'] and exports['qb-core'].GetVehicleByPlate then
            return exports['qb-core']:GetVehicleByPlate(plate)
        end
        return nil
    end)
    
    if success and vehicleData then
        return vehicleData
    end
    
    return nil
end

---Get vehicle by citizenid
---@param citizenid string Citizen ID
---@return table vehicles Table of vehicles owned by player
function Vehicle:GetVehiclesByCitizenId(citizenid)
    local qbCore = QboxAdapter:GetQBCore()
    if not qbCore then return {} end
    
    -- Try to get vehicles from database via QBCore
    local success, vehicles = pcall(function()
        -- Try QBX export first
        if exports['qbx_core'] and exports['qbx_core'].GetVehiclesByCitizenId then
            return exports['qbx_core']:GetVehiclesByCitizenId(citizenid)
        end
        -- Try QBCore export
        if exports['qb-core'] and exports['qb-core'].GetVehiclesByCitizenId then
            return exports['qb-core']:GetVehiclesByCitizenId(citizenid)
        end
        return nil
    end)
    
    if success and vehicles then
        return vehicles
    end
    
    return {}
end

---Set vehicle metadata
---@param vehicle number Vehicle entity
---@param metadata table Metadata to set
---@return boolean success True if successful
function Vehicle:SetVehicleMetadata(vehicle, metadata)
    if not DoesEntityExist(vehicle) then
        return false
    end
    
    local vehicleData = QboxAdapter:GetVehicle(vehicle)
    if not vehicleData then return false end
    
    -- Update metadata
    vehicleData.metadata = metadata
    
    -- Sync to state bag
    StateBag.SetStateBag('vehicle', vehicle, 'data', vehicleData)
    
    return true
end

---Get vehicle metadata
---@param vehicle number Vehicle entity
---@return table|nil metadata Vehicle metadata or nil
function Vehicle:GetVehicleMetadata(vehicle)
    local vehicleData = QboxAdapter:GetVehicle(vehicle)
    if not vehicleData then return nil end
    
    return vehicleData.metadata or {}
end

return Vehicle

