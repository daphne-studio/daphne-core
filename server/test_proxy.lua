---Proxy Test Suite
---Tests cross-framework proxy functionality

-- Only run tests if explicitly enabled
if not Config or not Config.Proxy or not Config.Proxy.Enabled then
    return
end

---Test QBCore proxy
local function TestQBCoreProxy()
    print('[Proxy Test] Testing QBCore Proxy...')
    
    -- Test QBCore global variable (should be proxied)
    if not QBCore then
        print('[Proxy Test] ✗ QBCore global variable not found')
        return
    end
    
    print('[Proxy Test] ✓ QBCore global variable exists')
    
    -- Test QBCore.Functions.GetPlayer
    local success, player = pcall(function()
        if QBCore and QBCore.Functions then
            return QBCore.Functions.GetPlayer(1) -- Assuming player 1 exists
        end
        return nil
    end)
    
    if success and player then
        print('[Proxy Test] ✓ QBCore.Functions.GetPlayer works')
        
        -- Test Player.Functions.AddMoney
        if player.Functions then
            local addSuccess = player.Functions.AddMoney('cash', 100)
            if addSuccess then
                print('[Proxy Test] ✓ Player.Functions.AddMoney works')
            else
                print('[Proxy Test] ✗ Player.Functions.AddMoney failed')
            end
        end
    else
        print('[Proxy Test] ✗ QBCore.Functions.GetPlayer failed (player 1 may not exist)')
        print('[Proxy Test] Note: This is expected if no players are online')
    end
end

---Test ESX proxy
local function TestESXProxy()
    print('[Proxy Test] Testing ESX Proxy...')
    
    -- Test ESX global variable (should be proxied)
    if not ESX then
        print('[Proxy Test] ✗ ESX global variable not found')
        return
    end
    
    print('[Proxy Test] ✓ ESX global variable exists')
    
    -- Test ESX.GetPlayerFromId
    local success, xPlayer = pcall(function()
        if ESX and ESX.GetPlayerFromId then
            return ESX.GetPlayerFromId(1) -- Assuming player 1 exists
        end
        return nil
    end)
    
    if success and xPlayer then
        print('[Proxy Test] ✓ ESX.GetPlayerFromId works')
        
        -- Test xPlayer.addMoney
        if xPlayer.addMoney then
            local addSuccess = xPlayer.addMoney(100)
            if addSuccess then
                print('[Proxy Test] ✓ xPlayer.addMoney works')
            else
                print('[Proxy Test] ✗ xPlayer.addMoney failed')
            end
        end
    else
        print('[Proxy Test] ✗ ESX.GetPlayerFromId failed (player 1 may not exist)')
        print('[Proxy Test] Note: This is expected if no players are online')
    end
end

---Test ND_Core proxy
local function TestNDCoreProxy()
    print('[Proxy Test] Testing ND_Core Proxy...')
    
    -- Test NDCore global variable (should be proxied if exists)
    if NDCore then
        print('[Proxy Test] ✓ NDCore global variable exists')
    else
        print('[Proxy Test] Note: NDCore global variable not found (may not be set by ND_Core)')
    end
    
    -- Test exports['ND_Core']:getPlayer
    -- Note: We can't override exports, so this will use original ND_Core if available
    local success, player = pcall(function()
        if exports['ND_Core'] and exports['ND_Core'].getPlayer then
            return exports['ND_Core']:getPlayer(1) -- Assuming player 1 exists
        end
        return nil
    end)
    
    if success and player then
        print('[Proxy Test] ✓ exports["ND_Core"]:getPlayer works')
        
        -- Test player.addMoney
        if player.addMoney then
            local addSuccess = player.addMoney('cash', 100, 'Test')
            if addSuccess then
                print('[Proxy Test] ✓ player.addMoney works')
            else
                print('[Proxy Test] ✗ player.addMoney failed')
            end
        end
    else
        print('[Proxy Test] ✗ exports["ND_Core"]:getPlayer failed (player 1 may not exist or ND_Core not available)')
        print('[Proxy Test] Note: Export override is not possible in FiveM, so original ND_Core export is used')
    end
end

---Test cross-framework proxy
local function TestCrossFrameworkProxy()
    print('[Proxy Test] Testing Cross-Framework Proxy...')
    
    local activeFramework = Config.GetFramework()
    print(string.format('[Proxy Test] Active adapter: %s', activeFramework or 'none'))
    
    -- Test QBCore script on different adapter
    if activeFramework ~= Config.Frameworks.QBOX and activeFramework ~= Config.Frameworks.QBCORE then
        print('[Proxy Test] Testing QBCore script on ' .. activeFramework .. ' adapter...')
        TestQBCoreProxy()
    end
    
    -- Test ESX script on different adapter
    if activeFramework ~= Config.Frameworks.ESX then
        print('[Proxy Test] Testing ESX script on ' .. activeFramework .. ' adapter...')
        TestESXProxy()
    end
    
    -- Test ND_Core script on different adapter
    if activeFramework ~= Config.Frameworks.ND_CORE then
        print('[Proxy Test] Testing ND_Core script on ' .. activeFramework .. ' adapter...')
        TestNDCoreProxy()
    end
end

---Run all tests
local function RunTests()
    if not Config.Proxy.CrossFrameworkEnabled then
        print('[Proxy Test] Cross-framework mode is disabled, skipping tests')
        return
    end
    
    print('[Proxy Test] Starting proxy tests...')
    print('[Proxy Test] ========================================')
    
    TestCrossFrameworkProxy()
    
    print('[Proxy Test] ========================================')
    print('[Proxy Test] Proxy tests complete')
end

---Run tests after a delay (to ensure everything is initialized)
CreateThread(function()
    Wait(5000) -- Wait 5 seconds for everything to initialize
    RunTests()
end)

