Config = {}

-- General Settings
Config.Locale = 'en'
Config.DrawDistance = 10.0
Config.MarkerSize = {x = 1.5, y = 1.5, z = 1.0}
Config.MarkerColor = {r = 50, g = 50, b = 204}
Config.MarkerType = 1

-- Shop Settings
Config.EnablePlayerManagement = true
Config.LicenseEnable = false
Config.LicensePrice = 5000

-- Test Drive Settings
Config.TestDrive = {
    AutoEndOnExit = true, -- Automatically end test drive when player exits vehicle
    ExitConfirmTime = 30000, -- Time in milliseconds to confirm player really exited (30- seconds)
    Duration = 120000 -- Test drive duration in milliseconds (2 minutes)
}

-- Society Money Settings
Config.SocietyMoney = {
    Enable = true,
    SocietyName = 'vehicleshop',
    OwnerCommission = 0.15, -- 15% commission for owner from each sale
    SocietyCommission = 0.85, -- 85% goes to society money
    MinWithdraw = 1000, -- Minimum amount to withdraw
    MaxWithdraw = 100000, -- Maximum amount to withdraw per transaction
    WithdrawCooldown = 300, -- Cooldown in seconds (5 minutes)
    AllowDeposit = true, -- Allow owner to deposit money
    MinDeposit = 1000000,
    MaxDeposit = 100000000
}

-- Vehicle Categories
Config.Categories = {
    ['compacts'] = 'Compacts',
    ['sedans'] = 'Sedans',
    ['suvs'] = 'SUVs',
    ['coupes'] = 'Coupes',
    ['muscle'] = 'Muscle',
    ['sports'] = 'Sports',
    ['super'] = 'Super',
    ['motorcycles'] = 'Motorcycles',
    ['offroad'] = 'Off-Road',
    ['industrial'] = 'Industrial',
    ['utility'] = 'Utility',
    ['vans'] = 'Vans',
    ['cycles'] = 'Cycles',
    ['boats'] = 'Boats',
    ['helicopters'] = 'Helicopters',
    ['planes'] = 'Planes'
}

-- Vehicle Shop Locations
Config.Shops = {
    PDM = {
        Pos = {x = -56.727, y = -1096.612, z = 25.422},
        Heading = 25.0,
        ShowroomVehicles = {
            {coords = {x = -45.65, y = -1093.05, z = 25.44, h = 69.5}, vehicle = 'adder'},
            {coords = {x = -48.27, y = -1101.86, z = 25.44, h = 294.5}, vehicle = 'schafter2'},
            {coords = {x = -39.6, y = -1096.01, z = 25.44, h = 66.5}, vehicle = 'voltic'},
            {coords = {x = -51.21, y = -1096.77, z = 25.44, h = 254.5}, vehicle = 'rapid'},
            {coords = {x = -40.18, y = -1104.13, z = 25.44, h = 338.5}, vehicle = 'bati'},
            {coords = {x = -44.28, y = -1102.47, z = 25.44, h = 298.5}, vehicle = 'bati2'}
        },
        SpawnPoint = {x = -56.79, y = -1109.85, z = 26.43, h = 71.5},
        BossMenu = {x = -59.89, y = -1099.24, z = 26.88}
    }
}

-- Vehicles Database
Config.Vehicles = {
    -- Compacts
    ['blista'] = {name = 'Blista', price = 8000, category = 'compacts'},
    ['brioso'] = {name = 'Brioso R/A', price = 18000, category = 'compacts'},
    ['dilettante'] = {name = 'Dilettante', price = 12000, category = 'compacts'},
    ['issi2'] = {name = 'Issi', price = 10000, category = 'compacts'},
    ['panto'] = {name = 'Panto', price = 85000, category = 'compacts'},
    ['prairie'] = {name = 'Prairie', price = 12000, category = 'compacts'},
    ['rhapsody'] = {name = 'Rhapsody', price = 14000, category = 'compacts'},
    
    -- Sedans
    ['asea'] = {name = 'Asea', price = 5500, category = 'sedans'},
    ['asterope'] = {name = 'Asterope', price = 26000, category = 'sedans'},
    ['cog55'] = {name = 'Cognoscenti 55', price = 58000, category = 'sedans'},
    ['cognoscenti'] = {name = 'Cognoscenti', price = 55000, category = 'sedans'},
    ['emperor'] = {name = 'Emperor', price = 8500, category = 'sedans'},
    ['fugitive'] = {name = 'Fugitive', price = 24000, category = 'sedans'},
    ['glendale'] = {name = 'Glendale', price = 7500, category = 'sedans'},
    ['ingot'] = {name = 'Ingot', price = 8000, category = 'sedans'},
    ['intruder'] = {name = 'Intruder', price = 7500, category = 'sedans'},
    ['premier'] = {name = 'Premier', price = 8000, category = 'sedans'},
    ['primo'] = {name = 'Primo', price = 8500, category = 'sedans'},
    ['primo2'] = {name = 'Primo Custom', price = 14000, category = 'sedans'},
    ['regina'] = {name = 'Regina', price = 5000, category = 'sedans'},
    ['schafter2'] = {name = 'Schafter', price = 25000, category = 'sedans'},
    ['stanier'] = {name = 'Stanier', price = 7000, category = 'sedans'},
    ['stratum'] = {name = 'Stratum', price = 9000, category = 'sedans'},
    ['stretch'] = {name = 'Stretch', price = 90000, category = 'sedans'},
    ['superd'] = {name = 'Super Diamond', price = 130000, category = 'sedans'},
    ['surge'] = {name = 'Surge', price = 35000, category = 'sedans'},
    ['tailgater'] = {name = 'Tailgater', price = 27000, category = 'sedans'},
    ['warrener'] = {name = 'Warrener', price = 4000, category = 'sedans'},
    ['washington'] = {name = 'Washington', price = 9000, category = 'sedans'},
    
    -- SUVs
    ['baller'] = {name = 'Baller', price = 40000, category = 'suvs'},
    ['baller2'] = {name = 'Baller 2', price = 60000, category = 'suvs'},
    ['bjxl'] = {name = 'BeeJay XL', price = 27000, category = 'suvs'},
    ['cavalcade'] = {name = 'Cavalcade', price = 30000, category = 'suvs'},
    ['cavalcade2'] = {name = 'Cavalcade 2', price = 35000, category = 'suvs'},
    ['contender'] = {name = 'Contender', price = 70000, category = 'suvs'},
    ['dubsta'] = {name = 'Dubsta', price = 45000, category = 'suvs'},
    ['dubsta2'] = {name = 'Dubsta 2', price = 60000, category = 'suvs'},
    ['fq2'] = {name = 'FQ 2', price = 25000, category = 'suvs'},
    ['granger'] = {name = 'Granger', price = 29000, category = 'suvs'},
    ['gresley'] = {name = 'Gresley', price = 27500, category = 'suvs'},
    ['habanero'] = {name = 'Habanero', price = 32000, category = 'suvs'},
    ['huntley'] = {name = 'Huntley S', price = 60000, category = 'suvs'},
    ['landstalker'] = {name = 'Landstalker', price = 35000, category = 'suvs'},
    ['mesa'] = {name = 'Mesa', price = 16000, category = 'suvs'},
    ['mesa2'] = {name = 'Mesa 2', price = 20000, category = 'suvs'},
    ['patriot'] = {name = 'Patriot', price = 35000, category = 'suvs'},
    ['radi'] = {name = 'Radius', price = 29000, category = 'suvs'},
    ['rocoto'] = {name = 'Rocoto', price = 45000, category = 'suvs'},
    ['seminole'] = {name = 'Seminole', price = 25000, category = 'suvs'},
    ['serrano'] = {name = 'Serrano', price = 30000, category = 'suvs'},
    ['xls'] = {name = 'XLS', price = 32000, category = 'suvs'},
    
    -- Sports
    ['alpha'] = {name = 'Alpha', price = 60000, category = 'sports'},
    ['banshee'] = {name = 'Banshee', price = 70000, category = 'sports'},
    ['bestiagts'] = {name = 'Bestia GTS', price = 55000, category = 'sports'},
    ['blista2'] = {name = 'Blista Compact', price = 42000, category = 'sports'},
    ['buffalo'] = {name = 'Buffalo', price = 12000, category = 'sports'},
    ['buffalo2'] = {name = 'Buffalo S', price = 20000, category = 'sports'},
    ['carbonizzare'] = {name = 'Carbonizzare', price = 75000, category = 'sports'},
    ['comet2'] = {name = 'Comet', price = 65000, category = 'sports'},
    ['coquette'] = {name = 'Coquette', price = 65000, category = 'sports'},
    ['elegy2'] = {name = 'Elegy RH8', price = 38500, category = 'sports'},
    ['feltzer2'] = {name = 'Feltzer', price = 55000, category = 'sports'},
    ['furoregt'] = {name = 'Furore GT', price = 45000, category = 'sports'},
    ['fusilade'] = {name = 'Fusilade', price = 40000, category = 'sports'},
    ['futo'] = {name = 'Futo', price = 9000, category = 'sports'},
    ['jester'] = {name = 'Jester', price = 65000, category = 'sports'},
    ['khamelion'] = {name = 'Khamelion', price = 38000, category = 'sports'},
    ['kuruma'] = {name = 'Kuruma', price = 30000, category = 'sports'},
    ['lynx'] = {name = 'Lynx', price = 58000, category = 'sports'},
    ['massacro'] = {name = 'Massacro', price = 65000, category = 'sports'},
    ['ninef'] = {name = '9F', price = 65000, category = 'sports'},
    ['ninef2'] = {name = '9F Cabrio', price = 80000, category = 'sports'},
    ['omnis'] = {name = 'Omnis', price = 35000, category = 'sports'},
    ['penumbra'] = {name = 'Penumbra', price = 28000, category = 'sports'},
    ['rapidgt'] = {name = 'Rapid GT', price = 35000, category = 'sports'},
    ['rapidgt2'] = {name = 'Rapid GT2', price = 45000, category = 'sports'},
    ['ruston'] = {name = 'Ruston', price = 75000, category = 'sports'},
    ['schafter3'] = {name = 'Schafter V12', price = 50000, category = 'sports'},
    ['sultan'] = {name = 'Sultan', price = 15000, category = 'sports'},
    ['surano'] = {name = 'Surano', price = 50000, category = 'sports'},
    ['tampa2'] = {name = 'Drift Tampa', price = 80000, category = 'sports'},
    ['tropos'] = {name = 'Tropos', price = 40000, category = 'sports'},
    ['verlierer2'] = {name = 'Verliere', price = 70000, category = 'sports'},
    
    -- Super
    ['adder'] = {name = 'Adder', price = 1000000, category = 'super'},
    ['banshee2'] = {name = 'Banshee 900R', price = 255000, category = 'super'},
    ['bullet'] = {name = 'Bullet', price = 90000, category = 'super'},
    ['cheetah'] = {name = 'Cheetah', price = 375000, category = 'super'},
    ['entityxf'] = {name = 'Entity XF', price = 425000, category = 'super'},
    ['sheava'] = {name = 'ETR1', price = 199500, category = 'super'},
    ['fmj'] = {name = 'FMJ', price = 185000, category = 'super'},
    ['infernus'] = {name = 'Infernus', price = 180000, category = 'super'},
    ['osiris'] = {name = 'Osiris', price = 120000, category = 'super'},
    ['le7b'] = {name = 'RE-7B', price = 325000, category = 'super'},
    ['reaper'] = {name = 'Reaper', price = 150000, category = 'super'},
    ['sultanrs'] = {name = 'Sultan RS', price = 65000, category = 'super'},
    ['t20'] = {name = 'T20', price = 300000, category = 'super'},
    ['turismor'] = {name = 'Turismo R', price = 350000, category = 'super'},
    ['tyrus'] = {name = 'Tyrus', price = 600000, category = 'super'},
    ['vacca'] = {name = 'Vacca', price = 120000, category = 'super'},
    ['voltic'] = {name = 'Voltic', price = 90000, category = 'super'},
    ['zentorno'] = {name = 'Zentorno', price = 725000, category = 'super'},
    
    -- Motorcycles
    ['akuma'] = {name = 'Akuma', price = 7500, category = 'motorcycles'},
    ['bagger'] = {name = 'Bagger', price = 13500, category = 'motorcycles'},
    ['bati'] = {name = 'Bati 801', price = 12000, category = 'motorcycles'},
    ['bati2'] = {name = 'Bati 801RR', price = 19000, category = 'motorcycles'},
    ['bf400'] = {name = 'BF400', price = 6500, category = 'motorcycles'},
    ['carbonrs'] = {name = 'Carbon RS', price = 18000, category = 'motorcycles'},
    ['cliffhanger'] = {name = 'Cliffhanger', price = 9500, category = 'motorcycles'},
    ['daemon'] = {name = 'Daemon', price = 11500, category = 'motorcycles'},
    ['daemon2'] = {name = 'Daemon High', price = 13500, category = 'motorcycles'},
    ['defiler'] = {name = 'Defiler', price = 9800, category = 'motorcycles'},
    ['double'] = {name = 'Double T', price = 28000, category = 'motorcycles'},
    ['enduro'] = {name = 'Enduro', price = 5500, category = 'motorcycles'},
    ['esskey'] = {name = 'Esskey', price = 4200, category = 'motorcycles'},
    ['faggio'] = {name = 'Faggio', price = 1900, category = 'motorcycles'},
    ['faggio2'] = {name = 'Faggio Sport', price = 2800, category = 'motorcycles'},
    ['gargoyle'] = {name = 'Gargoyle', price = 16500, category = 'motorcycles'},
    ['hakuchou'] = {name = 'Hakuchou', price = 31000, category = 'motorcycles'},
    ['hakuchou2'] = {name = 'Hakuchou Drag', price = 55000, category = 'motorcycles'},
    ['hexer'] = {name = 'Hexer', price = 12000, category = 'motorcycles'},
    ['innovation'] = {name = 'Innovation', price = 23500, category = 'motorcycles'},
    ['lectro'] = {name = 'Lectro', price = 700000, category = 'motorcycles'},
    ['nemesis'] = {name = 'Nemesis', price = 5800, category = 'motorcycles'},
    ['pcj'] = {name = 'PCJ-600', price = 6200, category = 'motorcycles'},
    ['ruffian'] = {name = 'Ruffian', price = 6800, category = 'motorcycles'},
    ['sanchez'] = {name = 'Sanchez', price = 5300, category = 'motorcycles'},
    ['sanchez2'] = {name = 'Sanchez Sport', price = 5300, category = 'motorcycles'},
    ['sovereign'] = {name = 'Sovereign', price = 22000, category = 'motorcycles'},
    ['thrust'] = {name = 'Thrust', price = 24000, category = 'motorcycles'},
    ['vader'] = {name = 'Vader', price = 7200, category = 'motorcycles'},
    ['vindicator'] = {name = 'Vindicator', price = 19000, category = 'motorcycles'},
    ['vortex'] = {name = 'Vortex', price = 9800, category = 'motorcycles'},
    ['wolfsbane'] = {name = 'Wolfsbane', price = 9000, category = 'motorcycles'},
    ['zombiea'] = {name = 'Zombie Bobber', price = 9500, category = 'motorcycles'},
    ['zombieb'] = {name = 'Zombie Chopper', price = 9500, category = 'motorcycles'}
}