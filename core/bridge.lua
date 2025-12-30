---@class Bridge
---Abstract bridge interface that all adapters must implement
Bridge = Bridge or {}
local Bridge = Bridge
Bridge.__index = Bridge

---Initialize the bridge adapter
---@return boolean success
function Bridge:Initialize()
    error("Bridge:Initialize() must be implemented by adapter")
end

---Get player object from source
---@param source number Player server ID
---@return table|nil player Player object or nil if not found
function Bridge:GetPlayer(source)
    error("Bridge:GetPlayer() must be implemented by adapter")
end

---Get player data from source
---@param source number Player server ID
---@return PlayerData|nil data Player data or nil if not found
function Bridge:GetPlayerData(source)
    error("Bridge:GetPlayerData() must be implemented by adapter")
end

---Get player money
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@return number|nil amount Money amount or nil if not found
function Bridge:GetMoney(source, type)
    error("Bridge:GetMoney() must be implemented by adapter")
end

---Add money to player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to add
---@return boolean success True if successful
function Bridge:AddMoney(source, type, amount)
    error("Bridge:AddMoney() must be implemented by adapter")
end

---Remove money from player
---@param source number Player server ID
---@param type string Money type (cash, bank, crypto, etc.)
---@param amount number Amount to remove
---@return boolean success True if successful
function Bridge:RemoveMoney(source, type, amount)
    error("Bridge:RemoveMoney() must be implemented by adapter")
end

---Get player inventory
---@param source number Player server ID
---@return table|nil inventory Inventory data or nil if not found
function Bridge:GetInventory(source)
    error("Bridge:GetInventory() must be implemented by adapter")
end

---Get player job
---@param source number Player server ID
---@return JobData|nil job Job data or nil if not found
function Bridge:GetJob(source)
    error("Bridge:GetJob() must be implemented by adapter")
end

---Get vehicle data
---@param vehicle number Vehicle entity
---@return VehicleData|nil data Vehicle data or nil if not found
function Bridge:GetVehicle(vehicle)
    error("Bridge:GetVehicle() must be implemented by adapter")
end

-- Export Bridge as global for use in other scripts
Bridge = Bridge

return Bridge

