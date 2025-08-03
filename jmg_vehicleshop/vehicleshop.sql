-- Vehicle Shop Database Schema
-- Execute this SQL file in your MySQL database

-- Create vehicleshop_owners table
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

-- Create vehicleshop_stock table
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

-- Create vehicleshop_sales table
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

-- Create vehicleshop_employees table
CREATE TABLE IF NOT EXISTS `vehicleshop_employees` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `shop_name` varchar(50) NOT NULL,
    `player_id` int(11) NOT NULL,
    `player_identifier` varchar(60) NOT NULL,
    `name` varchar(100) NOT NULL,
    `recruited_by` varchar(60) NOT NULL,
    `recruited_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `shop_employee` (`shop_name`, `player_identifier`),
    INDEX `idx_shop_name` (`shop_name`),
    INDEX `idx_player_identifier` (`player_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create vehicleshop_society table
CREATE TABLE IF NOT EXISTS `vehicleshop_society` (
    `shop_name` varchar(50) NOT NULL,
    `money` int(11) DEFAULT 0,
    `last_updated` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`shop_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create vehicleshop_transactions table
CREATE TABLE IF NOT EXISTS `vehicleshop_transactions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `shop_name` varchar(50) NOT NULL,
    `transaction_type` enum('deposit','withdraw','sale') NOT NULL,
    `amount` int(11) NOT NULL,
    `description` varchar(255) DEFAULT NULL,
    `player_identifier` varchar(60) DEFAULT NULL,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_shop_name` (`shop_name`),
    INDEX `idx_transaction_type` (`transaction_type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default stock for PDM shop (optional)
-- You can modify these values or add more vehicles as needed
INSERT IGNORE INTO `vehicleshop_stock` (`shop_name`, `vehicle_model`, `stock_amount`) VALUES
('PDM', 'adder', 2),
('PDM', 'banshee', 3),
('PDM', 'bullet', 1),
('PDM', 'cheetah', 2),
('PDM', 'entityxf', 1),
('PDM', 'infernus', 3),
('PDM', 'osiris', 1),
('PDM', 'sultanrs', 4),
('PDM', 't20', 1),
('PDM', 'turismor', 2),
('PDM', 'vacca', 3),
('PDM', 'voltic', 5),
('PDM', 'zentorno', 1),
('PDM', 'alpha', 4),
('PDM', 'banshee2', 2),
('PDM', 'bestiagts', 3),
('PDM', 'buffalo', 6),
('PDM', 'buffalo2', 4),
('PDM', 'carbonizzare', 3),
('PDM', 'comet2', 4),
('PDM', 'coquette', 3),
('PDM', 'elegy2', 8),
('PDM', 'feltzer2', 4),
('PDM', 'furoregt', 3),
('PDM', 'fusilade', 4),
('PDM', 'futo', 6),
('PDM', 'jester', 3),
('PDM', 'khamelion', 2),
('PDM', 'kuruma', 5),
('PDM', 'lynx', 2),
('PDM', 'massacro', 3),
('PDM', 'ninef', 3),
('PDM', 'ninef2', 2),
('PDM', 'omnis', 4),
('PDM', 'penumbra', 5),
('PDM', 'rapidgt', 4),
('PDM', 'rapidgt2', 3),
('PDM', 'ruston', 2),
('PDM', 'schafter3', 3),
('PDM', 'sultan', 6),
('PDM', 'surano', 3),
('PDM', 'tampa2', 2),
('PDM', 'tropos', 4),
('PDM', 'verlierer2', 2),
('PDM', 'baller', 4),
('PDM', 'baller2', 3),
('PDM', 'bjxl', 5),
('PDM', 'cavalcade', 4),
('PDM', 'cavalcade2', 3),
('PDM', 'contender', 2),
('PDM', 'dubsta', 4),
('PDM', 'dubsta2', 2),
('PDM', 'fq2', 5),
('PDM', 'granger', 4),
('PDM', 'gresley', 4),
('PDM', 'habanero', 3),
('PDM', 'huntley', 2),
('PDM', 'landstalker', 4),
('PDM', 'mesa', 6),
('PDM', 'mesa2', 4),
('PDM', 'patriot', 3),
('PDM', 'radi', 4),
('PDM', 'rocoto', 3),
('PDM', 'seminole', 5),
('PDM', 'serrano', 4),
('PDM', 'xls', 3),
('PDM', 'asea', 8),
('PDM', 'asterope', 5),
('PDM', 'cog55', 2),
('PDM', 'cognoscenti', 2),
('PDM', 'emperor', 6),
('PDM', 'fugitive', 4),
('PDM', 'glendale', 6),
('PDM', 'ingot', 5),
('PDM', 'intruder', 6),
('PDM', 'premier', 5),
('PDM', 'primo', 5),
('PDM', 'primo2', 3),
('PDM', 'regina', 7),
('PDM', 'schafter2', 4),
('PDM', 'stanier', 6),
('PDM', 'stratum', 5),
('PDM', 'stretch', 1),
('PDM', 'superd', 1),
('PDM', 'surge', 3),
('PDM', 'tailgater', 4),
('PDM', 'warrener', 7),
('PDM', 'washington', 5),
('PDM', 'blista', 6),
('PDM', 'brioso', 4),
('PDM', 'dilettante', 5),
('PDM', 'issi2', 6),
('PDM', 'panto', 2),
('PDM', 'prairie', 5),
('PDM', 'rhapsody', 4),
('PDM', 'akuma', 5),
('PDM', 'bagger', 3),
('PDM', 'bati', 4),
('PDM', 'bati2', 3),
('PDM', 'bf400', 5),
('PDM', 'carbonrs', 3),
('PDM', 'cliffhanger', 4),
('PDM', 'daemon', 4),
('PDM', 'daemon2', 3),
('PDM', 'defiler', 4),
('PDM', 'double', 2),
('PDM', 'enduro', 6),
('PDM', 'esskey', 7),
('PDM', 'faggio', 8),
('PDM', 'faggio2', 6),
('PDM', 'gargoyle', 3),
('PDM', 'hakuchou', 2),
('PDM', 'hakuchou2', 1),
('PDM', 'hexer', 4),
('PDM', 'innovation', 3),
('PDM', 'lectro', 1),
('PDM', 'nemesis', 5),
('PDM', 'pcj', 6),
('PDM', 'ruffian', 5),
('PDM', 'sanchez', 6),
('PDM', 'sanchez2', 6),
('PDM', 'sovereign', 2),
('PDM', 'thrust', 3),
('PDM', 'vader', 5),
('PDM', 'vindicator', 3),
('PDM', 'vortex', 4),
('PDM', 'wolfsbane', 4),
('PDM', 'zombiea', 3),
('PDM', 'zombieb', 3);

-- Create example owner (optional - replace with actual player data)
-- INSERT INTO `vehicleshop_owners` (`shop_name`, `owner_identifier`, `owner_name`) VALUES
-- ('PDM', 'char1:your_license_here', 'Your Name Here');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS `idx_vehicleshop_stock_shop_vehicle` ON `vehicleshop_stock` (`shop_name`, `vehicle_model`);
CREATE INDEX IF NOT EXISTS `idx_vehicleshop_sales_shop_date` ON `vehicleshop_sales` (`shop_name`, `sale_date`);
CREATE INDEX IF NOT EXISTS `idx_vehicleshop_owners_identifier` ON `vehicleshop_owners` (`owner_identifier`);

-- Add foreign key constraints (optional, for data integrity)
-- Note: Uncomment these if you want strict referential integrity
-- ALTER TABLE `vehicleshop_stock` ADD CONSTRAINT `fk_stock_owner` 
--     FOREIGN KEY (`shop_name`) REFERENCES `vehicleshop_owners` (`shop_name`) 
--     ON DELETE CASCADE ON UPDATE CASCADE;

-- ALTER TABLE `vehicleshop_sales` ADD CONSTRAINT `fk_sales_owner` 
--     FOREIGN KEY (`shop_name`) REFERENCES `vehicleshop_owners` (`shop_name`) 
--     ON DELETE CASCADE ON UPDATE CASCADE;

-- Create views for easier data access (optional)
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

-- Create view for low stock alerts
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

-- Create view for sales analytics
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

-- Insert initial society money for PDM shop
INSERT IGNORE INTO `vehicleshop_society` (`shop_name`, `money`) VALUES
('PDM', 50000);

-- Success message
SELECT 'Vehicle Shop database schema created successfully!' as message;
SELECT 'Remember to set shop owners using the /setshopowner command in-game' as reminder;
SELECT 'Default stock has been added to PDM shop' as stock_info;
SELECT 'Initial society money (50000) has been added to PDM shop' as society_info;