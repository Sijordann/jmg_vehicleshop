local ESX = exports['es_extended']:getSharedObject()
local withdrawCooldowns = {} -- Track withdrawal cooldowns for players

-- Database Tables Creation
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicleshop_owners` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `shop_name` varchar(50) NOT NULL,
            `owner_identifier` varchar(60) NOT NULL,
            `owner_name` varchar(100) NOT NULL,
            `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `shop_name` (`shop_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicleshop_stock` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `shop_name` varchar(50) NOT NULL,
            `vehicle_model` varchar(50) NOT NULL,
            `stock_amount` int(11) DEFAULT 0,
            `custom_price` int(11) DEFAULT NULL,
            `last_updated` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `shop_vehicle` (`shop_name`, `vehicle_model`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicleshop_sales` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `shop_name` varchar(50) NOT NULL,
            `buyer_identifier` varchar(60) NOT NULL,
            `buyer_name` varchar(100) NOT NULL,
            `vehicle_model` varchar(50) NOT NULL,
            `vehicle_plate` varchar(20) NOT NULL,
            `sale_price` int(11) NOT NULL,
            `sale_date` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicleshop_society` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `shop_name` varchar(50) NOT NULL,
            `money` int(11) DEFAULT 0,
            `last_updated` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `shop_name` (`shop_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicleshop_transactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `shop_name` varchar(50) NOT NULL,
            `player_identifier` varchar(60) NOT NULL,
            `player_name` varchar(100) NOT NULL,
            `transaction_type` enum('deposit','withdraw','commission','sale') NOT NULL,
            `amount` int(11) NOT NULL,
            `description` text,
            `transaction_date` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicleshop_employees` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `shop_name` varchar(50) NOT NULL,
            `player_id` int(11) NOT NULL,
            `player_identifier` varchar(60) NOT NULL,
            `name` varchar(100) NOT NULL,
            `recruited_by` varchar(60) NOT NULL,
            `recruited_at` timestamp DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `shop_employee` (`shop_name`, `player_identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    -- Initialize society money for PDM shop
    MySQL.query('INSERT IGNORE INTO vehicleshop_society (shop_name, money) VALUES (?, ?)', {
        'PDM', 0
    })
    
    -- Initialize default stock for PDM shop
    for vehicle, data in pairs(Config.Vehicles) do
        MySQL.insert('INSERT IGNORE INTO vehicleshop_stock (shop_name, vehicle_model, stock_amount) VALUES (?, ?, ?)', {
            'PDM', vehicle, math.random(1, 5)
        })
    end
    
    print('^2[VehicleShop]^7 Database tables created successfully!')
end)

-- ESX Callbacks
ESX.RegisterServerCallback('vehicleshop:isOwner', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end
    
    MySQL.scalar('SELECT COUNT(*) FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(count)
        cb(count > 0)
    end)
end)

ESX.RegisterServerCallback('vehicleshop:getVehicles', function(source, cb)
    local vehicles = {}
    
    MySQL.query('SELECT * FROM vehicleshop_stock WHERE shop_name = ?', {
        'PDM'
    }, function(result)
        for i = 1, #result do
            local vehicleData = result[i]
            local configData = Config.Vehicles[vehicleData.vehicle_model]
            
            if configData then
                table.insert(vehicles, {
                    model = vehicleData.vehicle_model,
                    name = configData.name,
                    price = vehicleData.custom_price or configData.price,
                    category = configData.category,
                    stock = vehicleData.stock_amount
                })
            end
        end
        
        cb(vehicles)
    end)
end)

ESX.RegisterServerCallback('vehicleshop:getShopData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end
    
    -- Check if player is owner first
    MySQL.query('SELECT * FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(ownerResult)
        if #ownerResult > 0 then
            -- Player is owner
            local shopName = ownerResult[1].shop_name
            getShopDataForPlayer(shopName, ownerResult[1].owner_name, cb)
        else
            -- Check if player is employee
            MySQL.query('SELECT * FROM vehicleshop_employees WHERE player_identifier = ?', {
                xPlayer.identifier
            }, function(employeeResult)
                if #employeeResult > 0 then
                    -- Player is employee
                    local shopName = employeeResult[1].shop_name
                    -- Get owner name for the shop
                    MySQL.query('SELECT owner_name FROM vehicleshop_owners WHERE shop_name = ?', {
                        shopName
                    }, function(ownerNameResult)
                        local ownerName = ownerNameResult[1] and ownerNameResult[1].owner_name or 'Unknown'
                        getShopDataForPlayer(shopName, ownerName, cb)
                    end)
                else
                    -- Player is neither owner nor employee
                    return cb(nil)
                end
            end)
        end
    end)
end)

-- Helper function to get shop data
function getShopDataForPlayer(shopName, ownerName, cb)
    -- Get stock data
    MySQL.query('SELECT * FROM vehicleshop_stock WHERE shop_name = ?', {
        shopName
    }, function(stockResult)
        -- Get sales data
        MySQL.query('SELECT * FROM vehicleshop_sales WHERE shop_name = ? ORDER BY sale_date DESC LIMIT 50', {
            shopName
        }, function(salesResult)
            -- Get society money
            MySQL.query('SELECT money FROM vehicleshop_society WHERE shop_name = ?', {
                shopName
            }, function(societyResult)
                local societyMoney = societyResult[1] and societyResult[1].money or 0
                
                local shopData = {
                    shopName = shopName,
                    owner = ownerName,
                    societyMoney = societyMoney,
                    stock = {},
                    sales = salesResult
                }
                
                for i = 1, #stockResult do
                    local stock = stockResult[i]
                    local configData = Config.Vehicles[stock.vehicle_model]
                    
                    if configData then
                        table.insert(shopData.stock, {
                            model = stock.vehicle_model,
                            name = configData.name,
                            basePrice = configData.price,
                            customPrice = stock.custom_price,
                            stock = stock.stock_amount,
                            category = configData.category
                        })
                    end
                end
                
                cb(shopData)
            end)
        end)
    end)
end



ESX.RegisterServerCallback('vehicleshop:getSocietyMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(0) end
    
    -- Check if player is owner first
    MySQL.query('SELECT shop_name FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(ownerResult)
        if #ownerResult > 0 then
            -- Player is owner
            local shopName = ownerResult[1].shop_name
            MySQL.scalar('SELECT money FROM vehicleshop_society WHERE shop_name = ?', {
                shopName
            }, function(money)
                cb(money or 0)
            end)
        else
            -- Check if player is employee
            MySQL.query('SELECT shop_name FROM vehicleshop_employees WHERE player_identifier = ?', {
                xPlayer.identifier
            }, function(employeeResult)
                if #employeeResult > 0 then
                    -- Player is employee
                    local shopName = employeeResult[1].shop_name
                    MySQL.scalar('SELECT money FROM vehicleshop_society WHERE shop_name = ?', {
                        shopName
                    }, function(money)
                        cb(money or 0)
                    end)
                else
                    -- Player is neither owner nor employee
                    return cb(0)
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback('vehicleshop:getTransactions', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end
    
    -- Check if player is owner first
    MySQL.query('SELECT shop_name FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(ownerResult)
        if #ownerResult > 0 then
            -- Player is owner
            local shopName = ownerResult[1].shop_name
            MySQL.query('SELECT * FROM vehicleshop_transactions WHERE shop_name = ? ORDER BY transaction_date DESC LIMIT 100', {
                shopName
            }, function(result)
                cb(result)
            end)
        else
            -- Check if player is employee
            MySQL.query('SELECT shop_name FROM vehicleshop_employees WHERE player_identifier = ?', {
                xPlayer.identifier
            }, function(employeeResult)
                if #employeeResult > 0 then
                    -- Player is employee
                    local shopName = employeeResult[1].shop_name
                    MySQL.query('SELECT * FROM vehicleshop_transactions WHERE shop_name = ? ORDER BY transaction_date DESC LIMIT 100', {
                        shopName
                    }, function(result)
                        cb(result)
                    end)
                else
                    -- Player is neither owner nor employee
                    return cb({})
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback('vehicleshop:buyVehicle', function(source, cb, vehicleModel, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false) end
    
    -- Check if vehicle exists in config
    local vehicleData = Config.Vehicles[vehicleModel]
    if not vehicleData then
        return cb(false)
    end
    
    -- Get vehicle price and stock
    MySQL.query('SELECT * FROM vehicleshop_stock WHERE shop_name = ? AND vehicle_model = ?', {
        'PDM', vehicleModel
    }, function(result)
        if #result == 0 or result[1].stock_amount <= 0 then
            xPlayer.showNotification('Vehicle out of stock!')
            return cb(false)
        end
        
        local price = result[1].custom_price or vehicleData.price
        
        -- Check if player has enough money
        if xPlayer.getMoney() < price then
            xPlayer.showNotification('Not enough money!')
            return cb(false)
        end
        
        -- Check if plate already exists
        MySQL.scalar('SELECT COUNT(*) FROM owned_vehicles WHERE plate = ?', {
            plate
        }, function(plateCount)
            if plateCount > 0 then
                xPlayer.showNotification('Plate already exists!')
                return cb(false)
            end
            
            -- Process purchase
            xPlayer.removeMoney(price)
            
            -- Add vehicle to player's garage
            local vehicleProps = {
                model = GetHashKey(vehicleModel),
                plate = plate
            }
            
            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored) VALUES (?, ?, ?, ?, ?, ?)', {
                xPlayer.identifier,
                plate,
                json.encode(vehicleProps),
                'car',
                'civ',
                1
            }, function(insertId)
                if insertId then
                    -- Update stock
                    MySQL.update('UPDATE vehicleshop_stock SET stock_amount = stock_amount - 1 WHERE shop_name = ? AND vehicle_model = ?', {
                        'PDM', vehicleModel
                    })
                    
                    -- Record sale
                    MySQL.insert('INSERT INTO vehicleshop_sales (shop_name, buyer_identifier, buyer_name, vehicle_model, vehicle_plate, sale_price) VALUES (?, ?, ?, ?, ?, ?)', {
                        'PDM',
                        xPlayer.identifier,
                        xPlayer.getName(),
                        vehicleModel,
                        plate,
                        price
                    })
                    
                    -- Handle society money and commission if enabled
                    if Config.SocietyMoney.Enable then
                        local ownerCommission = math.floor(price * Config.SocietyMoney.OwnerCommission)
                        local societyAmount = math.floor(price * Config.SocietyMoney.SocietyCommission)
                        
                        -- Add money to society
                        MySQL.update('UPDATE vehicleshop_society SET money = money + ? WHERE shop_name = ?', {
                            societyAmount, 'PDM'
                        })
                        
                        -- Record society transaction
                        MySQL.insert('INSERT INTO vehicleshop_transactions (shop_name, player_identifier, player_name, transaction_type, amount, description) VALUES (?, ?, ?, ?, ?, ?)', {
                            'PDM',
                            xPlayer.identifier,
                            xPlayer.getName(),
                            'sale',
                            societyAmount,
                            'Vehicle sale: ' .. vehicleModel .. ' (Plate: ' .. plate .. ')'
                        })
                        
                        -- Give commission to owner if there is one
                        MySQL.query('SELECT owner_identifier FROM vehicleshop_owners WHERE shop_name = ?', {
                            'PDM'
                        }, function(ownerResult)
                            if #ownerResult > 0 then
                                local ownerPlayer = ESX.GetPlayerFromIdentifier(ownerResult[1].owner_identifier)
                                if ownerPlayer then
                                    ownerPlayer.addMoney(ownerCommission)
                                    ownerPlayer.showNotification('You received $' .. ownerCommission .. ' commission from vehicle sale!')
                                else
                                    -- Owner is offline, add to their bank account
                                    MySQL.update('UPDATE users SET bank = bank + ? WHERE identifier = ?', {
                                        ownerCommission, ownerResult[1].owner_identifier
                                    })
                                end
                                
                                -- Record commission transaction
                                MySQL.insert('INSERT INTO vehicleshop_transactions (shop_name, player_identifier, player_name, transaction_type, amount, description) VALUES (?, ?, ?, ?, ?, ?)', {
                                    'PDM',
                                    ownerResult[1].owner_identifier,
                                    'Shop Owner',
                                    'commission',
                                    ownerCommission,
                                    'Commission from vehicle sale: ' .. vehicleModel
                                })
                            end
                        end)
                    end
                    
                    -- Spawn vehicle
                    TriggerClientEvent('vehicleshop:spawnVehicle', source, {
                        model = vehicleModel,
                        plate = plate,
                        props = vehicleProps
                    })
                    
                    xPlayer.showNotification('Vehicle purchased successfully!')
                    cb(true)
                else
                    xPlayer.addMoney(price) -- Refund
                    cb(false)
                end
            end)
        end)
    end)
end)

-- Server Events
RegisterNetEvent('vehicleshop:addStock')
AddEventHandler('vehicleshop:addStock', function(vehicleModel, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check if player is owner or employee
    ESX.TriggerCallback('vehicleshop:isEmployeeOrOwner', source, function(hasAccess, shopName)
        if not hasAccess then
            xPlayer.showNotification('You are not authorized!')
            return
        end
        
        MySQL.update('UPDATE vehicleshop_stock SET stock_amount = stock_amount + ? WHERE shop_name = ? AND vehicle_model = ?', {
            amount, shopName, vehicleModel
        }, function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification('Stock updated successfully!')
                TriggerClientEvent('vehicleshop:updateShopData', source)
            else
                xPlayer.showNotification('Failed to update stock!')
            end
        end)
    end)
end)

RegisterNetEvent('vehicleshop:removeStock')
AddEventHandler('vehicleshop:removeStock', function(vehicleModel, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check if player is owner or employee
    ESX.TriggerCallback('vehicleshop:isEmployeeOrOwner', source, function(hasAccess, shopName)
        if not hasAccess then
            xPlayer.showNotification('You are not authorized!')
            return
        end
        
        MySQL.update('UPDATE vehicleshop_stock SET stock_amount = GREATEST(0, stock_amount - ?) WHERE shop_name = ? AND vehicle_model = ?', {
            amount, shopName, vehicleModel
        }, function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification('Stock updated successfully!')
                TriggerClientEvent('vehicleshop:updateShopData', source)
            else
                xPlayer.showNotification('Failed to update stock!')
            end
        end)
    end)
end)

RegisterNetEvent('vehicleshop:setPrice')
AddEventHandler('vehicleshop:setPrice', function(vehicleModel, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check if player is owner or employee
    ESX.TriggerCallback('vehicleshop:isEmployeeOrOwner', source, function(hasAccess, shopName)
        if not hasAccess then
            xPlayer.showNotification('You are not authorized!')
            return
        end
        
        local finalPrice = price == 0 and 'NULL' or price
        
        MySQL.update('UPDATE vehicleshop_stock SET custom_price = ? WHERE shop_name = ? AND vehicle_model = ?', {
            finalPrice, shopName, vehicleModel
        }, function(affectedRows)
            if affectedRows > 0 then
                if price == 0 then
                    xPlayer.showNotification('Price reset to default!')
                else
                    xPlayer.showNotification('Custom price set successfully!')
                end
                TriggerClientEvent('vehicleshop:updateShopData', source)
            else
                xPlayer.showNotification('Failed to update price!')
            end
        end)
    end)
end)

RegisterNetEvent('vehicleshop:transferOwnership')
AddEventHandler('vehicleshop:transferOwnership', function(targetId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if not xPlayer or not xTarget then return end
    
    -- Check if player is owner
    MySQL.query('SELECT * FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(result)
        if #result == 0 then
            xPlayer.showNotification('You are not authorized!')
            return
        end
        
        local shopName = result[1].shop_name
        
        MySQL.update('UPDATE vehicleshop_owners SET owner_identifier = ?, owner_name = ? WHERE shop_name = ?', {
            xTarget.identifier, xTarget.getName(), shopName
        }, function(affectedRows)
            if affectedRows > 0 then
                xPlayer.showNotification('Ownership transferred successfully!')
                xTarget.showNotification('You are now the owner of ' .. shopName .. '!')
                TriggerClientEvent('vehicleshop:updateShopData', source)
            else
                xPlayer.showNotification('Failed to transfer ownership!')
            end
        end)
    end)
end)

RegisterNetEvent('vehicleshop:depositMoney')
AddEventHandler('vehicleshop:depositMoney', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if not Config.SocietyMoney.Enable or not Config.SocietyMoney.AllowDeposit then
        xPlayer.showNotification('Deposits are not allowed!')
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount < Config.SocietyMoney.MinDeposit or amount > Config.SocietyMoney.MaxDeposit then
        xPlayer.showNotification('Invalid amount! Min: $' .. Config.SocietyMoney.MinDeposit .. ' Max: $' .. Config.SocietyMoney.MaxDeposit)
        return
    end
    
    -- Check if player is owner or employee
    ESX.TriggerCallback('vehicleshop:isEmployeeOrOwner', source, function(hasAccess, shopName)
        if not hasAccess then
            xPlayer.showNotification('You are not authorized!')
            return
        end
        
        -- Check if player has enough money
        if xPlayer.getMoney() < amount then
            xPlayer.showNotification('Not enough money!')
            return
        end
        
        -- Process deposit
        xPlayer.removeMoney(amount)
        
        MySQL.update('UPDATE vehicleshop_society SET money = money + ? WHERE shop_name = ?', {
            amount, shopName
        }, function(affectedRows)
            if affectedRows > 0 then
                -- Record transaction
                MySQL.insert('INSERT INTO vehicleshop_transactions (shop_name, player_identifier, player_name, transaction_type, amount, description) VALUES (?, ?, ?, ?, ?, ?)', {
                    shopName,
                    xPlayer.identifier,
                    xPlayer.getName(),
                    'deposit',
                    amount,
                    'Money deposit by owner'
                })
                
                xPlayer.showNotification('Successfully deposited $' .. amount .. ' to society!')
                TriggerClientEvent('vehicleshop:updateShopData', source)
            else
                xPlayer.addMoney(amount) -- Refund
                xPlayer.showNotification('Failed to deposit money!')
            end
        end)
    end)
end)

RegisterNetEvent('vehicleshop:withdrawMoney')
AddEventHandler('vehicleshop:withdrawMoney', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if not Config.SocietyMoney.Enable then
        xPlayer.showNotification('Society money system is disabled!')
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount < Config.SocietyMoney.MinWithdraw or amount > Config.SocietyMoney.MaxWithdraw then
        xPlayer.showNotification('Invalid amount! Min: $' .. Config.SocietyMoney.MinWithdraw .. ' Max: $' .. Config.SocietyMoney.MaxWithdraw)
        return
    end
    
    -- Check cooldown
    local currentTime = os.time()
    if withdrawCooldowns[xPlayer.identifier] and (currentTime - withdrawCooldowns[xPlayer.identifier]) < Config.SocietyMoney.WithdrawCooldown then
        local remainingTime = Config.SocietyMoney.WithdrawCooldown - (currentTime - withdrawCooldowns[xPlayer.identifier])
        xPlayer.showNotification('You must wait ' .. remainingTime .. ' seconds before withdrawing again!')
        return
    end
    
    -- Check if player is owner or employee
    ESX.TriggerCallback('vehicleshop:isEmployeeOrOwner', source, function(hasAccess, shopName)
        if not hasAccess then
            xPlayer.showNotification('You are not authorized!')
            return
        end
        
        -- Check society money
        MySQL.scalar('SELECT money FROM vehicleshop_society WHERE shop_name = ?', {
            shopName
        }, function(societyMoney)
            if not societyMoney or societyMoney < amount then
                xPlayer.showNotification('Not enough money in society! Available: $' .. (societyMoney or 0))
                return
            end
            
            -- Process withdrawal
            MySQL.update('UPDATE vehicleshop_society SET money = money - ? WHERE shop_name = ?', {
                amount, shopName
            }, function(affectedRows)
                if affectedRows > 0 then
                    xPlayer.addMoney(amount)
                    withdrawCooldowns[xPlayer.identifier] = currentTime
                    
                    -- Record transaction
                    MySQL.insert('INSERT INTO vehicleshop_transactions (shop_name, player_identifier, player_name, transaction_type, amount, description) VALUES (?, ?, ?, ?, ?, ?)', {
                        shopName,
                        xPlayer.identifier,
                        xPlayer.getName(),
                        'withdraw',
                        amount,
                        'Money withdrawal by owner'
                    })
                    
                    xPlayer.showNotification('Successfully withdrew $' .. amount .. ' from society!')
                    TriggerClientEvent('vehicleshop:updateShopData', source)
                else
                    xPlayer.showNotification('Failed to withdraw money!')
                end
            end)
        end)
    end)
end)

-- Employee Management Callbacks
ESX.RegisterServerCallback('vehicleshop:recruitEmployee', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({success = false, message = 'Player not found'}) end
    
    -- Check if player is shop owner
    MySQL.scalar('SELECT COUNT(*) FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(isOwner)
        if isOwner == 0 then
            return cb({success = false, message = 'You are not a shop owner'})
        end
        
        local targetPlayerId = data.playerId
        local targetPlayerName = data.playerName or 'Unknown'
        
        -- Get target player
        local xTarget = ESX.GetPlayerFromId(targetPlayerId)
        if not xTarget then
            return cb({success = false, message = 'Target player not found or offline'})
        end
        
        -- Get shop name for this owner
        MySQL.scalar('SELECT shop_name FROM vehicleshop_owners WHERE owner_identifier = ?', {
            xPlayer.identifier
        }, function(shopName)
            if not shopName then
                return cb({success = false, message = 'Shop not found'})
            end
            
            -- Check if player is already an employee
            MySQL.scalar('SELECT COUNT(*) FROM vehicleshop_employees WHERE shop_name = ? AND player_identifier = ?', {
                shopName, xTarget.identifier
            }, function(isEmployee)
                if isEmployee > 0 then
                    return cb({success = false, message = 'Player is already an employee'})
                end
                
                -- Check if player is the owner
                if xTarget.identifier == xPlayer.identifier then
                    return cb({success = false, message = 'You cannot recruit yourself'})
                end
                
                -- Recruit the employee
                MySQL.insert('INSERT INTO vehicleshop_employees (shop_name, player_id, player_identifier, name, recruited_by) VALUES (?, ?, ?, ?, ?)', {
                    shopName,
                    targetPlayerId,
                    xTarget.identifier,
                    xTarget.getName(),
                    xPlayer.identifier
                }, function(insertId)
                    if insertId then
                        xTarget.showNotification('You have been recruited as an employee at ' .. shopName .. '!')
                        cb({success = true, message = 'Employee recruited successfully!'})
                    else
                        cb({success = false, message = 'Failed to recruit employee'})
                    end
                end)
            end)
        end)
    end)
end)

ESX.RegisterServerCallback('vehicleshop:fireEmployee', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({success = false, message = 'Player not found'}) end
    
    -- Check if player is shop owner
    MySQL.scalar('SELECT COUNT(*) FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(isOwner)
        if isOwner == 0 then
            return cb({success = false, message = 'You are not a shop owner'})
        end
        
        local targetPlayerId = data.playerId
        
        -- Get shop name for this owner
        MySQL.scalar('SELECT shop_name FROM vehicleshop_owners WHERE owner_identifier = ?', {
            xPlayer.identifier
        }, function(shopName)
            if not shopName then
                return cb({success = false, message = 'Shop not found'})
            end
            
            -- Fire the employee
            MySQL.update('DELETE FROM vehicleshop_employees WHERE shop_name = ? AND player_id = ?', {
                shopName, targetPlayerId
            }, function(affectedRows)
                if affectedRows > 0 then
                    -- Notify target player if online
                    local xTarget = ESX.GetPlayerFromId(targetPlayerId)
                    if xTarget then
                        xTarget.showNotification('You have been fired from ' .. shopName .. '!')
                    end
                    cb({success = true, message = 'Employee fired successfully!'})
                else
                    cb({success = false, message = 'Employee not found'})
                end
            end)
        end)
    end)
end)

ESX.RegisterServerCallback('vehicleshop:getEmployees', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({success = false, message = 'Player not found'}) end
    
    -- Check if player is shop owner
    MySQL.scalar('SELECT COUNT(*) FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(isOwner)
        if isOwner == 0 then
            return cb({success = false, message = 'You are not a shop owner'})
        end
        
        -- Get shop name for this owner
        MySQL.scalar('SELECT shop_name FROM vehicleshop_owners WHERE owner_identifier = ?', {
            xPlayer.identifier
        }, function(shopName)
            if not shopName then
                return cb({success = false, message = 'Shop not found'})
            end
            
            -- Get employees
            MySQL.query('SELECT * FROM vehicleshop_employees WHERE shop_name = ? ORDER BY recruited_at DESC', {
                shopName
            }, function(employees)
                cb({success = true, employees = employees or {}})
            end)
        end)
    end)
end)

ESX.RegisterServerCallback('vehicleshop:isEmployeeOrOwner', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false, nil) end
    
    -- Check if player is shop owner
    MySQL.query('SELECT shop_name FROM vehicleshop_owners WHERE owner_identifier = ?', {
        xPlayer.identifier
    }, function(ownerResult)
        if #ownerResult > 0 then
            return cb(true, ownerResult[1].shop_name)
        end
        
        -- Check if player is an employee
        MySQL.query('SELECT shop_name FROM vehicleshop_employees WHERE player_identifier = ?', {
            xPlayer.identifier
        }, function(employeeResult)
            if #employeeResult > 0 then
                cb(true, employeeResult[1].shop_name)
            else
                cb(false, nil)
            end
        end)
    end)
end)

-- Commands
ESX.RegisterCommand('setshopowner', 'admin', function(xPlayer, args, showError)
    local targetId = tonumber(args.playerId)
    local shopName = args.shopName or 'PDM'
    local xTarget = ESX.GetPlayerFromId(targetId)
    
    if not xTarget then
        return xPlayer.showNotification('Player not found!')
    end
    
    MySQL.query('INSERT INTO vehicleshop_owners (shop_name, owner_identifier, owner_name) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE owner_identifier = VALUES(owner_identifier), owner_name = VALUES(owner_name)', {
        shopName, xTarget.identifier, xTarget.getName()
    }, function(result)
        xPlayer.showNotification('Shop owner set successfully!')
        xTarget.showNotification('You are now the owner of ' .. shopName .. '!')
    end)
end, false, {help = 'Set vehicle shop owner', validate = true, arguments = {
    {name = 'playerId', help = 'Player ID', type = 'number'},
    {name = 'shopName', help = 'Shop name (optional)', type = 'string'}
}})

ESX.RegisterCommand('removeshopowner', 'admin', function(xPlayer, args, showError)
    local shopName = args.shopName or 'PDM'
    
    MySQL.update('DELETE FROM vehicleshop_owners WHERE shop_name = ?', {
        shopName
    }, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification('Shop owner removed successfully!')
        else
            xPlayer.showNotification('No owner found for this shop!')
        end
    end)
end, false, {help = 'Remove vehicle shop owner', validate = false, arguments = {
    {name = 'shopName', help = 'Shop name (optional)', type = 'string'}
}})

ESX.RegisterCommand('addvehiclestock', 'admin', function(xPlayer, args, showError)
    local vehicleModel = args.vehicle
    local amount = tonumber(args.amount) or 1
    local shopName = args.shopName or 'PDM'
    
    if not Config.Vehicles[vehicleModel] then
        return xPlayer.showNotification('Invalid vehicle model!')
    end
    
    MySQL.query('INSERT INTO vehicleshop_stock (shop_name, vehicle_model, stock_amount) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE stock_amount = stock_amount + VALUES(stock_amount)', {
        shopName, vehicleModel, amount
    }, function(result)
        xPlayer.showNotification('Stock added successfully!')
    end)
end, false, {help = 'Add vehicle stock', validate = true, arguments = {
    {name = 'vehicle', help = 'Vehicle model', type = 'string'},
    {name = 'amount', help = 'Amount to add', type = 'number'},
    {name = 'shopName', help = 'Shop name (optional)', type = 'string'}
}})

print('^2[VehicleShop]^7 Server started successfully!')