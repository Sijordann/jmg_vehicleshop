local ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}
local currentShop = nil
local inShopMenu = false
local showroomVehicles = {}
local testDriveVehicle = nil
local isTestDriving = false

-- Initialize
CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Create Blips
CreateThread(function()
    for shopName, shopData in pairs(Config.Shops) do
        local blip = AddBlipForCoord(shopData.Pos.x, shopData.Pos.y, shopData.Pos.z)
        SetBlipSprite(blip, 326)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Vehicle Shop')
        EndTextCommandSetBlipName(blip)
    end
end)

-- Create Markers and Handle Interactions
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for shopName, shopData in pairs(Config.Shops) do
            local distance = #(playerCoords - vector3(shopData.Pos.x, shopData.Pos.y, shopData.Pos.z))
            
            if distance < Config.DrawDistance then
                sleep = 0
                DrawMarker(Config.MarkerType, shopData.Pos.x, shopData.Pos.y, shopData.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
                
                if distance < 3.0 then
                    ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to open Vehicle Shop')
                    
                    if IsControlJustReleased(0, 38) then -- E key
                        currentShop = shopName
                        OpenShopMenu()
                    end
                end
            end
            
            -- Boss Menu Marker
            if shopData.BossMenu then
                local bossDistance = #(playerCoords - vector3(shopData.BossMenu.x, shopData.BossMenu.y, shopData.BossMenu.z))
                
                if bossDistance < Config.DrawDistance then
                    sleep = 0
                    DrawMarker(Config.MarkerType, shopData.BossMenu.x, shopData.BossMenu.y, shopData.BossMenu.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, 255, 0, 0, 100, false, true, 2, false, false, false, false)
                    
                    if bossDistance < 3.0 then
                        ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to open Boss Menu')
                        
                        if IsControlJustReleased(0, 38) then -- E key
                            ESX.TriggerServerCallback('vehicleshop:isEmployeeOrOwner', function(hasAccess, shopName)
                                if hasAccess then
                                    OpenBossMenu()
                                else
                                    ESX.ShowNotification('You are not authorized to access this menu!')
                                end
                            end)
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- Spawn Showroom Vehicles
CreateThread(function()
    for shopName, shopData in pairs(Config.Shops) do
        if shopData.ShowroomVehicles then
            for i, vehicleData in pairs(shopData.ShowroomVehicles) do
                local hash = GetHashKey(vehicleData.vehicle)
                RequestModel(hash)
                
                while not HasModelLoaded(hash) do
                    Wait(10)
                end
                
                local vehicle = CreateVehicle(hash, vehicleData.coords.x, vehicleData.coords.y, vehicleData.coords.z, vehicleData.coords.h, false, false)
                SetEntityInvincible(vehicle, true)
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleNumberPlateText(vehicle, 'SHOP')
                FreezeEntityPosition(vehicle, true)
                SetModelAsNoLongerNeeded(hash)
                
                table.insert(showroomVehicles, vehicle)
            end
        end
    end
end)

-- Functions
function OpenShopMenu()
    if inShopMenu then return end
    inShopMenu = true
    
    ESX.TriggerServerCallback('vehicleshop:getVehicles', function(vehicles)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openShop',
            vehicles = vehicles,
            categories = Config.Categories,
            playerMoney = ESX.GetPlayerData().money
        })
    end)
end

function OpenBossMenu()
    ESX.TriggerServerCallback('vehicleshop:getShopData', function(shopData)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openBoss',
            shopData = shopData
        })
    end)
end

function CloseMenu()
    inShopMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'closeMenu'
    })
end

function StartTestDrive(vehicle)
    if isTestDriving then
        ESX.ShowNotification('You are already test driving a vehicle!')
        return
    end
    
    local playerPed = PlayerPedId()
    local shopData = Config.Shops[currentShop]
    local hash = GetHashKey(vehicle)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
    
    testDriveVehicle = CreateVehicle(hash, shopData.SpawnPoint.x, shopData.SpawnPoint.y, shopData.SpawnPoint.z, shopData.SpawnPoint.h, true, false)
    SetVehicleNumberPlateText(testDriveVehicle, 'TEST')
    TaskWarpPedIntoVehicle(playerPed, testDriveVehicle, -1)
    
    isTestDriving = true
    local durationMinutes = math.floor(Config.TestDrive.Duration / 60000)
    ESX.ShowNotification('Test drive started! You have ' .. durationMinutes .. ' minutes.')
    
    -- Test drive timer
    SetTimeout(Config.TestDrive.Duration, function()
        if isTestDriving then
            EndTestDrive()
        end
    end)
    
    -- Monitor if player exits vehicle (only if enabled in config)
    if Config.TestDrive.AutoEndOnExit then
        CreateThread(function()
            while isTestDriving and testDriveVehicle and DoesEntityExist(testDriveVehicle) do
                local playerPed = PlayerPedId()
                local currentVehicle = GetVehiclePedIsIn(playerPed, false)
                
                -- Check if player is no longer in the test drive vehicle
                if currentVehicle ~= testDriveVehicle then
                    Wait(Config.TestDrive.ExitConfirmTime) -- Wait to confirm player really exited
                    
                    -- Double check if player is still not in the vehicle
                    currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if currentVehicle ~= testDriveVehicle and isTestDriving then
                        ESX.ShowNotification('Test drive ended - You exited the vehicle!')
                        EndTestDrive()
                        break
                    end
                end
                
                Wait(1000) -- Check every second
            end
        end)
    end
end

function EndTestDrive()
    if not isTestDriving then return end
    
    local playerPed = PlayerPedId()
    
    if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
        TaskLeaveVehicle(playerPed, testDriveVehicle, 0)
        Wait(2000)
        DeleteEntity(testDriveVehicle)
    end
    
    testDriveVehicle = nil
    isTestDriving = false
    ESX.ShowNotification('Test drive ended!')
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('buyVehicle', function(data, cb)
    ESX.TriggerServerCallback('vehicleshop:buyVehicle', function(success)
        if success then
            ESX.ShowNotification('Vehicle purchased successfully!')
            CloseMenu()
        else
            ESX.ShowNotification('Purchase failed!')
        end
    end, data.vehicle, data.plate)
    cb('ok')
end)

RegisterNUICallback('testDrive', function(data, cb)
    StartTestDrive(data.vehicle)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('addStock', function(data, cb)
    TriggerServerEvent('vehicleshop:addStock', data.vehicle, data.amount)
    cb('ok')
end)

RegisterNUICallback('removeStock', function(data, cb)
    TriggerServerEvent('vehicleshop:removeStock', data.vehicle, data.amount)
    cb('ok')
end)

RegisterNUICallback('setPrice', function(data, cb)
    TriggerServerEvent('vehicleshop:setPrice', data.vehicle, data.price)
    cb('ok')
end)

RegisterNUICallback('transferOwnership', function(data, cb)
    TriggerServerEvent('vehicleshop:transferOwnership', data.playerId)
    cb('ok')
end)

RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('vehicleshop:depositMoney', data.amount)
    cb('ok')
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('vehicleshop:withdrawMoney', data.amount)
    cb('ok')
end)

RegisterNUICallback('getSocietyMoney', function(data, cb)
    ESX.TriggerServerCallback('vehicleshop:getSocietyMoney', function(money)
        cb(money)
    end)
end)

RegisterNUICallback('getTransactions', function(data, cb)
    ESX.TriggerServerCallback('vehicleshop:getTransactions', function(transactions)
        cb(transactions)
    end)
end)

-- Events
RegisterNUICallback('recruitEmployee', function(data, cb)
    ESX.TriggerServerCallback('vehicleshop:recruitEmployee', function(result)
        cb(result)
    end, data)
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    ESX.TriggerServerCallback('vehicleshop:fireEmployee', function(result)
        cb(result)
    end, data)
end)

RegisterNUICallback('getEmployees', function(data, cb)
    ESX.TriggerServerCallback('vehicleshop:getEmployees', function(result)
        cb(result)
    end)
end)

RegisterNetEvent('vehicleshop:spawnVehicle')
AddEventHandler('vehicleshop:spawnVehicle', function(vehicleData)
    local playerPed = PlayerPedId()
    local hash = GetHashKey(vehicleData.model)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
    
    local vehicle = CreateVehicle(hash, shopData.SpawnPoint.x, shopData.SpawnPoint.y, shopData.SpawnPoint.z, shopData.SpawnPoint.h, true, false)
    SetVehicleNumberPlateText(vehicle, vehicleData.plate)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    
    -- Set vehicle properties if any
    if vehicleData.props then
        ESX.Game.SetVehicleProperties(vehicle, vehicleData.props)
    end
end)

RegisterNetEvent('vehicleshop:updateShopData')
AddEventHandler('vehicleshop:updateShopData', function()
    ESX.ShowNotification('Shop data updated!')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for i, vehicle in pairs(showroomVehicles) do
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end
        
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            DeleteEntity(testDriveVehicle)
        end
    end
end)