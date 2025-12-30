---API Mapper
---Maps framework API calls to daphne-core normalized API
APIMapper = APIMapper or {}
local APIMapper = APIMapper

---QBCore API → Daphne-Core API mappings
APIMapper.QBCoreMappings = {
    ['Functions.GetPlayer'] = 'GetPlayer',
    ['Functions.GetPlayers'] = 'GetPlayers',
    ['Functions.GetPlayerByCitizenId'] = 'GetPlayerByCitizenId',
    ['Functions.GetPlayerByPhone'] = 'GetPlayerByPhone',
    ['Player.Functions.AddMoney'] = 'AddMoney',
    ['Player.Functions.RemoveMoney'] = 'RemoveMoney',
    ['Player.Functions.GetMoney'] = 'GetMoney',
    ['Player.Functions.AddItem'] = 'AddItem',
    ['Player.Functions.RemoveItem'] = 'RemoveItem',
    ['Player.Functions.HasItem'] = 'HasItem',
    ['Player.Functions.GetItem'] = 'GetItem',
    ['Player.Functions.SetJob'] = 'SetJob',
    ['Player.Functions.SetGang'] = 'SetGang',
    ['Player.Functions.GetMetadata'] = 'GetMetadata',
    ['Player.Functions.SetMetadata'] = 'SetMetadata',
}

---ESX API → Daphne-Core API mappings
APIMapper.ESXMappings = {
    ['GetPlayerFromId'] = 'GetPlayer',
    ['GetPlayers'] = 'GetPlayers',
    ['GetPlayerFromIdentifier'] = 'GetPlayerFromIdentifier',
    ['xPlayer.addMoney'] = 'AddMoney',
    ['xPlayer.removeMoney'] = 'RemoveMoney',
    ['xPlayer.getMoney'] = 'GetMoney',
    ['xPlayer.addAccountMoney'] = 'AddAccountMoney',
    ['xPlayer.removeAccountMoney'] = 'RemoveAccountMoney',
    ['xPlayer.getAccount'] = 'GetAccount',
    ['xPlayer.addItem'] = 'AddItem',
    ['xPlayer.removeItem'] = 'RemoveItem',
    ['xPlayer.hasItem'] = 'HasItem',
    ['xPlayer.getInventory'] = 'GetInventory',
    ['xPlayer.setJob'] = 'SetJob',
    ['xPlayer.getMetadata'] = 'GetMetadata',
    ['xPlayer.setMetadata'] = 'SetMetadata',
}

---ND_Core API → Daphne-Core API mappings
APIMapper.NDCoreMappings = {
    ['getPlayer'] = 'GetPlayer',
    ['player.addMoney'] = 'AddMoney',
    ['player.removeMoney'] = 'RemoveMoney',
    ['player.deductMoney'] = 'RemoveMoney',
    ['player.getMoney'] = 'GetMoney',
    ['player.cash'] = 'GetMoney',
    ['player.bank'] = 'GetMoney',
    ['player.getJob'] = 'GetJob',
    ['player.addItem'] = 'AddItem',
    ['player.removeItem'] = 'RemoveItem',
    ['player.hasItem'] = 'HasItem',
    ['player.getMetadata'] = 'GetMetadata',
    ['player.setMetadata'] = 'SetMetadata',
    ['player.getData'] = 'GetMetadata',
}

---OX Core API → Daphne-Core API mappings (placeholder for future)
APIMapper.OXMappings = {
    -- Will be added when OX Core adapter is implemented
}

---Map QBCore API call to Daphne-Core API
---@param method string QBCore API method name
---@param args table Arguments for the API call
---@return string? daphneMethod Mapped Daphne-Core method name
---@return table? mappedArgs Mapped arguments
function APIMapper.MapQBCoreToDaphne(method, args)
    local mapping = APIMapper.QBCoreMappings[method]
    if not mapping then
        return nil, nil
    end
    
    -- Handle specific method mappings
    if method == 'Player.Functions.AddMoney' or method == 'Player.Functions.RemoveMoney' then
        -- QBCore: Player.Functions.AddMoney(type, amount)
        -- Daphne: AddMoney(source, type, amount)
        -- args should be {source, type, amount}
        return mapping, args
    elseif method == 'Player.Functions.GetMoney' then
        -- QBCore: Player.Functions.GetMoney(type)
        -- Daphne: GetMoney(source, type)
        -- args should be {source, type}
        return mapping, args
    elseif method == 'Player.Functions.AddItem' or method == 'Player.Functions.RemoveItem' then
        -- QBCore: Player.Functions.AddItem(item, amount, slot, info)
        -- Daphne: AddItem(source, item, amount, slot, info)
        return mapping, args
    elseif method == 'Functions.GetPlayer' then
        -- QBCore: QBCore.Functions.GetPlayer(source)
        -- Daphne: GetPlayer(source)
        return mapping, args
    end
    
    return mapping, args
end

---Map ESX API call to Daphne-Core API
---@param method string ESX API method name
---@param args table Arguments for the API call
---@return string? daphneMethod Mapped Daphne-Core method name
---@return table? mappedArgs Mapped arguments
function APIMapper.MapESXToDaphne(method, args)
    local mapping = APIMapper.ESXMappings[method]
    if not mapping then
        return nil, nil
    end
    
    -- Handle specific method mappings
    if method == 'xPlayer.addMoney' then
        -- ESX: xPlayer.addMoney(amount)
        -- Daphne: AddMoney(source, 'cash', amount)
        return mapping, {args[1], 'cash', args[2]}
    elseif method == 'xPlayer.removeMoney' then
        -- ESX: xPlayer.removeMoney(amount)
        -- Daphne: RemoveMoney(source, 'cash', amount)
        return mapping, {args[1], 'cash', args[2]}
    elseif method == 'xPlayer.addAccountMoney' then
        -- ESX: xPlayer.addAccountMoney(account, amount)
        -- Daphne: AddMoney(source, account, amount)
        return mapping, {args[1], args[2], args[3]}
    elseif method == 'xPlayer.addItem' then
        -- ESX: xPlayer.addItem(item, count, metadata)
        -- Daphne: AddItem(source, item, count, nil, metadata)
        return mapping, {args[1], args[2], args[3], nil, args[4]}
    elseif method == 'GetPlayerFromId' then
        -- ESX: ESX.GetPlayerFromId(source)
        -- Daphne: GetPlayer(source)
        return mapping, args
    end
    
    return mapping, args
end

---Map ND_Core API call to Daphne-Core API
---@param method string ND_Core API method name
---@param args table Arguments for the API call
---@return string? daphneMethod Mapped Daphne-Core method name
---@return table? mappedArgs Mapped arguments
function APIMapper.MapNDCoreToDaphne(method, args)
    local mapping = APIMapper.NDCoreMappings[method]
    if not mapping then
        return nil, nil
    end
    
    -- Handle specific method mappings
    if method == 'player.addMoney' then
        -- ND_Core: player.addMoney(type, amount, reason)
        -- Daphne: AddMoney(source, type, amount)
        -- Reason parameter is ignored
        return mapping, {args[1], args[2], args[3]}
    elseif method == 'player.removeMoney' or method == 'player.deductMoney' then
        -- ND_Core: player.removeMoney(type, amount, reason)
        -- Daphne: RemoveMoney(source, type, amount)
        -- Reason parameter is ignored
        return mapping, {args[1], args[2], args[3]}
    elseif method == 'getPlayer' then
        -- ND_Core: exports['ND_Core']:getPlayer(source)
        -- Daphne: GetPlayer(source)
        return mapping, args
    elseif method == 'player.getJob' then
        -- ND_Core: player.getJob()
        -- Daphne: GetJob(source)
        return mapping, {args[1]}
    end
    
    return mapping, args
end

---Map OX Core API call to Daphne-Core API (placeholder)
---@param method string OX Core API method name
---@param args table Arguments for the API call
---@return string? daphneMethod Mapped Daphne-Core method name
---@return table? mappedArgs Mapped arguments
function APIMapper.MapOXToDaphne(method, args)
    local mapping = APIMapper.OXMappings[method]
    if not mapping then
        return nil, nil
    end
    
    -- Will be implemented when OX Core adapter is added
    return mapping, args
end

---Convert Daphne-Core data to QBCore format
---@param data table Daphne-Core normalized data
---@return table qbcoreData QBCore format data
function APIMapper.ConvertDaphneToQBCore(data)
    -- This is handled by DataConverter, but kept for API consistency
    return data
end

---Convert Daphne-Core data to ESX format
---@param data table Daphne-Core normalized data
---@return table esxData ESX format data
function APIMapper.ConvertDaphneToESX(data)
    -- This is handled by DataConverter, but kept for API consistency
    return data
end

---Convert Daphne-Core data to ND_Core format
---@param data table Daphne-Core normalized data
---@return table ndCoreData ND_Core format data
function APIMapper.ConvertDaphneToNDCore(data)
    -- This is handled by DataConverter, but kept for API consistency
    return data
end

---Convert Daphne-Core data to OX Core format (placeholder)
---@param data table Daphne-Core normalized data
---@return table oxData OX Core format data
function APIMapper.ConvertDaphneToOX(data)
    -- Will be implemented when OX Core adapter is added
    return data
end

-- Export APIMapper as global
APIMapper = APIMapper

return APIMapper


