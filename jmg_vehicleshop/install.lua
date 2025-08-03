-- Vehicle Shop Installation Script
-- Run this script once to setup the database and initial configuration

local MySQL = exports.oxmysql

local function log(message)
    print('^2[VehicleShop Installer]^7 ' .. message)
end

local function logError(message)
    print('^1[VehicleShop Installer ERROR]^7 ' .. message)
end

local function logSuccess(message)
    print('^2[VehicleShop Installer SUCCESS]^7 ' .. message)
end

-- Installation Steps
local installSteps = {
    {
        name = "Creating vehicleshop_owners table",
        query = [[
            CREATE TABLE IF NOT EXISTS `vehicleshop_owners` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `shop_name` varchar(50) NOT NULL,
                `owner_identifier` varchar(60) NOT NULL,
                `owner_name` varchar(100) NOT NULL,
                `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `shop_name` (`shop_name`),
                INDEX `idx_owner_identifier` (`owner_identifier`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    },
    {
        name = "Creating vehicleshop_stock table",
        query = [[
            CREATE TABLE IF NOT EXISTS `vehicleshop_stock` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `shop_name` varchar(50) NOT NULL,
                `vehicle_model` varchar(50) NOT NULL,
                `stock_amount` int(11) DEFAULT 0,
                `custom_price` int(11) DEFAULT NULL,
                `last_updated` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                UNIQUE KEY `shop_vehicle` (`shop_name`, `vehicle_model`),
                INDEX `idx_shop_name` (`shop_name`),
                INDEX `idx_vehicle_model` (`vehicle_model`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    },
    {
        name = "Creating vehicleshop_sales table",
        query = [[
            CREATE TABLE IF NOT EXISTS `vehicleshop_sales` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `shop_name` varchar(50) NOT NULL,
                `buyer_identifier` varchar(60) NOT NULL,
                `buyer_name` varchar(100) NOT NULL,
                `vehicle_model` varchar(50) NOT NULL,
                `vehicle_plate` varchar(20) NOT NULL,
                `sale_price` int(11) NOT NULL,
                `sale_date` timestamp DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`),
                INDEX `idx_shop_name` (`shop_name`),
                INDEX `idx_buyer_identifier` (`buyer_identifier`),
                INDEX `idx_sale_date` (`sale_date`),
                INDEX `idx_vehicle_plate` (`vehicle_plate`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]]
    },
    {
        name = "Creating summary view",
        query = [[
            CREATE OR REPLACE VIEW `v_vehicleshop_summary` AS
            SELECT 
                o.shop_name,
                o.owner_name,
                COUNT(DISTINCT s.vehicle_model) as total_vehicle_types,
                SUM(s.stock_amount) as total_stock,
                COUNT(DISTINCT sa.id) as total_sales,
                COALESCE(SUM(sa.sale_price), 0) as total_revenue
            FROM `vehicleshop_owners` o
            LEFT JOIN `vehicleshop_stock` s ON o.shop_name = s.shop_name
            LEFT JOIN `vehicleshop_sales` sa ON o.shop_name = sa.shop_name
            GROUP BY o.shop_name, o.owner_name;
        ]]
    },
    {
        name = "Creating low stock alerts view",
        query = [[
            CREATE OR REPLACE VIEW `v_low_stock_alerts` AS
            SELECT 
                shop_name,
                vehicle_model,
                stock_amount,
                CASE 
                    WHEN stock_amount = 0 THEN 'OUT_OF_STOCK'
                    WHEN stock_amount <= 2 THEN 'LOW_STOCK'
                    WHEN stock_amount <= 5 THEN 'MEDIUM_STOCK'
                    ELSE 'GOOD_STOCK'
                END as stock_status
            FROM `vehicleshop_stock`
            WHERE stock_amount <= 5
            ORDER BY stock_amount ASC, shop_name, vehicle_model;
        ]]
    },
    {
        name = "Creating sales analytics view",
        query = [[
            CREATE OR REPLACE VIEW `v_sales_analytics` AS
            SELECT 
                shop_name,
                vehicle_model,
                COUNT(*) as sales_count,
                AVG(sale_price) as avg_price,
                MIN(sale_price) as min_price,
                MAX(sale_price) as max_price,
                SUM(sale_price) as total_revenue,
                DATE(MIN(sale_date)) as first_sale,
                DATE(MAX(sale_date)) as last_sale
            FROM `vehicleshop_sales`
            GROUP BY shop_name, vehicle_model
            ORDER BY sales_count DESC, total_revenue DESC;
        ]]
    }
}

-- Stock initialization data
local stockData = {
    {vehicle = 'adder', stock = 2},
    {vehicle = 'banshee', stock = 3},
    {vehicle = 'bullet', stock = 1},
    {vehicle = 'cheetah', stock = 2},
    {vehicle = 'entityxf', stock = 1},
    {vehicle = 'infernus', stock = 3},
    {vehicle = 'osiris', stock = 1},
    {vehicle = 'sultanrs', stock = 4},
    {vehicle = 't20', stock = 1},
    {vehicle = 'turismor', stock = 2},
    {vehicle = 'vacca', stock = 3},
    {vehicle = 'voltic', stock = 5},
    {vehicle = 'zentorno', stock = 1},
    {vehicle = 'alpha', stock = 4},
    {vehicle = 'buffalo', stock = 6},
    {vehicle = 'buffalo2', stock = 4},
    {vehicle = 'elegy2', stock = 8},
    {vehicle = 'futo', stock = 6},
    {vehicle = 'sultan', stock = 6},
    {vehicle = 'baller', stock = 4},
    {vehicle = 'dubsta', stock = 4},
    {vehicle = 'granger', stock = 4},
    {vehicle = 'huntley', stock = 2},
    {vehicle = 'landstalker', stock = 4},
    {vehicle = 'asea', stock = 8},
    {vehicle = 'fugitive', stock = 4},
    {vehicle = 'premier', stock = 5},
    {vehicle = 'stanier', stock = 6},
    {vehicle = 'washington', stock = 5},
    {vehicle = 'blista', stock = 6},
    {vehicle = 'issi2', stock = 6},
    {vehicle = 'panto', stock = 2},
    {vehicle = 'bati', stock = 4},
    {vehicle = 'bati2', stock = 3},
    {vehicle = 'akuma', stock = 5},
    {vehicle = 'pcj', stock = 6},
    {vehicle = 'sanchez', stock = 6}
}

-- Installation function
local function runInstallation()
    log("Starting Vehicle Shop installation...")
    
    local completedSteps = 0
    local totalSteps = #installSteps + 1 -- +1 for stock initialization
    
    -- Execute each installation step
    for i, step in ipairs(installSteps) do
        log("Step " .. i .. "/" .. (#installSteps) .. ": " .. step.name)
        
        local success = MySQL.Sync.execute(step.query)
        
        if success then
            logSuccess("✓ " .. step.name .. " completed")
            completedSteps = completedSteps + 1
        else
            logError("✗ " .. step.name .. " failed")
        end
        
        Wait(100) -- Small delay between steps
    end
    
    -- Initialize stock data
    log("Initializing default stock data...")
    local stockInserted = 0
    
    for _, item in ipairs(stockData) do
        local result = MySQL.Sync.execute(
            'INSERT IGNORE INTO vehicleshop_stock (shop_name, vehicle_model, stock_amount) VALUES (?, ?, ?)',
            {'PDM', item.vehicle, item.stock}
        )
        
        if result then
            stockInserted = stockInserted + 1
        end
    end
    
    if stockInserted > 0 then
        logSuccess("✓ Stock initialization completed (" .. stockInserted .. " vehicles added)")
        completedSteps = completedSteps + 1
    else
        log("Stock data already exists, skipping initialization")
        completedSteps = completedSteps + 1
    end
    
    -- Installation summary
    log("")
    log("=== INSTALLATION SUMMARY ===")
    log("Completed steps: " .. completedSteps .. "/" .. totalSteps)
    
    if completedSteps == totalSteps then
        logSuccess("🎉 Vehicle Shop installation completed successfully!")
        logSuccess("")
        logSuccess("Next steps:")
        logSuccess("1. Restart the vehicleshop resource")
        logSuccess("2. Use /setshopowner [playerId] PDM to set a shop owner")
        logSuccess("3. Enjoy your new vehicle shop!")
    else
        logError("⚠️  Installation completed with some issues")
        logError("Please check the errors above and try again")
    end
    
    log("")
end

-- Auto-run installation when resource starts
CreateThread(function()
    -- Wait for database to be ready
    while not MySQL do
        Wait(100)
    end
    
    Wait(2000) -- Additional wait to ensure everything is loaded
    
    -- Check if installation is needed
      local result = MySQL.scalar.await(
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'vehicleshop_owners'"
    )

    if not tablesExist or tablesExist == 0 then
        log("Database tables not found, starting installation...")
        runInstallation()
    else
        log("Database tables already exist, skipping installation")
        log("If you want to reinstall, please drop the vehicleshop tables manually")
    end
end)

-- Manual installation command for admins
RegisterCommand('vehicleshop:install', function(source, args)
    if source == 0 then -- Console only
        runInstallation()
    else
        print("This command can only be run from the server console")
    end
end, true)

-- Check installation status command
RegisterCommand('vehicleshop:status', function(source, args)
    if source == 0 then -- Console only
        log("Checking Vehicle Shop installation status...")
        
        local tables = {
            'vehicleshop_owners',
            'vehicleshop_stock',
            'vehicleshop_sales'
        }
        
        local views = {
            'v_vehicleshop_summary',
            'v_low_stock_alerts',
            'v_sales_analytics'
        }
        
        -- Check tables
        for _, tableName in ipairs(tables) do
            local exists = MySQL.Sync.fetchScalar(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = ?",
                {tableName}
            )
            
            if exists and exists > 0 then
                logSuccess("✓ Table " .. tableName .. " exists")
            else
                logError("✗ Table " .. tableName .. " missing")
            end
        end
        
        -- Check views
        for _, viewName in ipairs(views) do
            local exists = MySQL.Sync.fetchScalar(
                "SELECT COUNT(*) FROM information_schema.views WHERE table_schema = DATABASE() AND table_name = ?",
                {viewName}
            )
            
            if exists and exists > 0 then
                logSuccess("✓ View " .. viewName .. " exists")
            else
                logError("✗ View " .. viewName .. " missing")
            end
        end
        
        -- Check stock data
        local stockCount = MySQL.Sync.fetchScalar(
            "SELECT COUNT(*) FROM vehicleshop_stock WHERE shop_name = 'PDM'"
        )
        
        if stockCount and stockCount > 0 then
            logSuccess("✓ Stock data exists (" .. stockCount .. " vehicles)")
        else
            logError("✗ No stock data found")
        end
        
        log("Status check completed")
    else
        print("This command can only be run from the server console")
    end
end, true)

log("Installation script loaded. Use 'vehicleshop:install' to manually install or 'vehicleshop:status' to check status")