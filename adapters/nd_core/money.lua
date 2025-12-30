---ND Core Money Module Adapter
---Money-related functions specific to ND Core

-- These modules are loaded via shared_scripts, so they're available as globals
if not NDCoreAdapter then
    error('[ND Core Money] NDCoreAdapter not found! Make sure adapters/nd_core/adapter.lua is loaded.')
end

if not StateBag then
    error('[ND Core Money] StateBag not found! Make sure core/statebag.lua is loaded.')
end

if not Cache then
    error('[ND Core Money] Cache not found! Make sure core/cache.lua is loaded.')
end

local Money = {}
Money.__index = Money

---Get all money types for player
---@param source number Player server ID
---@return table|nil moneyTable All money types or nil
function Money:GetAllMoney(source)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return nil end
    
    local moneyTable = {
        cash = player.cash or player.getData('cash') or 0,
        bank = player.bank or player.getData('bank') or 0
    }
    
    return moneyTable
end

---Set money for player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to set
---@return boolean success True if successful
function Money:SetMoney(source, type, amount)
    local currentAmount = NDCoreAdapter:GetMoney(source, type)
    if currentAmount == nil then return false end
    
    local difference = amount - currentAmount
    
    if difference > 0 then
        -- Add money
        return NDCoreAdapter:AddMoney(source, type, difference)
    elseif difference < 0 then
        -- Remove money
        return NDCoreAdapter:RemoveMoney(source, type, math.abs(difference))
    else
        -- Already correct amount
        return true
    end
end

---Check if player has enough money
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to check
---@return boolean hasMoney True if player has enough
function Money:HasMoney(source, type, amount)
    local money = NDCoreAdapter:GetMoney(source, type)
    if not money then return false end
    
    return money >= amount
end

---Deposit money (move from cash to bank)
---@param source number Player server ID
---@param amount number Amount to deposit
---@return boolean success True if successful
function Money:DepositMoney(source, amount)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return false end
    
    local success, result = pcall(function()
        if player.depositMoney then
            return player.depositMoney(amount)
        end
        return false
    end)
    
    if success and result then
        Cache.InvalidatePlayer(source)
        local playerData = NDCoreAdapter:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
        end
        return true
    end
    
    return false
end

---Withdraw money (move from bank to cash)
---@param source number Player server ID
---@param amount number Amount to withdraw
---@return boolean success True if successful
function Money:WithdrawMoney(source, amount)
    local player = NDCoreAdapter:GetPlayer(source)
    if not player then return false end
    
    local success, result = pcall(function()
        if player.withdrawMoney then
            return player.withdrawMoney(amount)
        end
        return false
    end)
    
    if success and result then
        Cache.InvalidatePlayer(source)
        local playerData = NDCoreAdapter:GetPlayerData(source)
        if playerData and playerData.money then
            StateBag.SetStateBag('player', source, 'money', playerData.money, false)
        end
        return true
    end
    
    return false
end

return Money

