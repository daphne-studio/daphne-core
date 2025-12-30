---ESX Money Module Adapter
---Money-related functions specific to ESX

-- These modules are loaded via shared_scripts, so they're available as globals
if not ESXAdapter then
    error('[ESX Money] ESXAdapter not found! Make sure adapters/esx/adapter.lua is loaded.')
end

if not StateBag then
    error('[ESX Money] StateBag not found! Make sure core/statebag.lua is loaded.')
end

local Money = {}
Money.__index = Money

---Get all money types for player
---@param source number Player server ID
---@return table|nil moneyTable All money types or nil
function Money:GetAllMoney(source)
    local xPlayer = ESXAdapter:GetPlayer(source)
    if not xPlayer then return nil end
    
    local moneyTable = {
        cash = xPlayer.getMoney(),
        bank = xPlayer.getAccount('bank').money
    }
    
    -- Add other accounts if they exist
    local accounts = xPlayer.getAccounts()
    if accounts then
        for _, account in pairs(accounts) do
            if account.name ~= 'bank' and account.name ~= 'money' then
                moneyTable[account.name] = account.money
            end
        end
    end
    
    return moneyTable
end

---Set money for player
---@param source number Player server ID
---@param type string Money type
---@param amount number Amount to set
---@return boolean success True if successful
function Money:SetMoney(source, type, amount)
    local xPlayer = ESXAdapter:GetPlayer(source)
    if not xPlayer then return false end
    
    local currentAmount = ESXAdapter:GetMoney(source, type)
    if currentAmount == nil then return false end
    
    local difference = amount - currentAmount
    
    if difference > 0 then
        -- Add money
        return ESXAdapter:AddMoney(source, type, difference)
    elseif difference < 0 then
        -- Remove money
        return ESXAdapter:RemoveMoney(source, type, math.abs(difference))
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
    local money = ESXAdapter:GetMoney(source, type)
    if not money then return false end
    
    return money >= amount
end

return Money

