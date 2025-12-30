---@class PlayerData
---@field source number
---@field citizenid string
---@field name string
---@field money table<string, number>
---@field job table
---@field gang table
---@field metadata table
---@field inventory table

---@class JobData
---@field name string
---@field label string
---@field grade table
---@field onduty boolean
---@field payment number

---@class VehicleData
---@field plate string
---@field model string
---@field props table
---@field metadata table

---@class BridgeAdapter
---@field name string
---@field initialized boolean
---@field GetPlayer fun(source: number): table|nil
---@field GetPlayerData fun(source: number): PlayerData|nil
---@field GetMoney fun(source: number, type: string): number|nil
---@field AddMoney fun(source: number, type: string, amount: number): boolean
---@field RemoveMoney fun(source: number, type: string, amount: number): boolean
---@field GetInventory fun(source: number): table|nil
---@field GetJob fun(source: number): JobData|nil
---@field GetVehicle fun(vehicle: number): VehicleData|nil
---@field Initialize fun(): boolean

