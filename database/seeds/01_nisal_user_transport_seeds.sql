-- =============================================================================
-- TravelPulse LK — Module 1: User, Transport Route & Journey Seed Data
-- Owning Member: Nisal
-- Database Engine: MySQL 8.0+ (InnoDB)
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Table 1: users (Test accounts with bcrypt hashes for 'Password123!')
-- Hash: $2b$10$wT8KzQhUe2nZ1oG7Cj4vOeJzN1yKzW0dQq2sFvXxL9p0tM3e4k6uK (simulated)
-- -----------------------------------------------------------------------------
INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `phone_number`, `role`, `is_active`)
VALUES
  (1, 'Kamal Perera', 'kamal@example.com', '$2b$10$wT8KzQhUe2nZ1oG7Cj4vOeJzN1yKzW0dQq2sFvXxL9p0tM3e4k6uK', '+94771234567', 'commuter', TRUE),
  (2, 'Dilshan Silva', 'dilshan@example.com', '$2b$10$wT8KzQhUe2nZ1oG7Cj4vOeJzN1yKzW0dQq2sFvXxL9p0tM3e4k6uK', '+94719876543', 'commuter', TRUE),
  (3, 'Anusha Silva', 'moderator@travelpulse.lk', '$2b$10$wT8KzQhUe2nZ1oG7Cj4vOeJzN1yKzW0dQq2sFvXxL9p0tM3e4k6uK', '+94762345678', 'moderator', TRUE),
  (4, 'System Administrator', 'admin@travelpulse.lk', '$2b$10$wT8KzQhUe2nZ1oG7Cj4vOeJzN1yKzW0dQq2sFvXxL9p0tM3e4k6uK', '+94703456789', 'admin', TRUE),
  (5, 'Malith Senanayake', 'malith@example.com', '$2b$10$wT8KzQhUe2nZ1oG7Cj4vOeJzN1yKzW0dQq2sFvXxL9p0tM3e4k6uK', '+94784567890', 'commuter', TRUE)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `role` = VALUES(`role`),
  `is_active` = VALUES(`is_active`);

-- -----------------------------------------------------------------------------
-- Table 4: transport_routes
-- -----------------------------------------------------------------------------
INSERT INTO `transport_routes` (`id`, `route_number`, `name`, `transport_type`, `operator`, `origin_city`, `destination_city`, `is_active`)
VALUES
  (1, '138', 'Colombo Fort - Maharagama / Homagama', 'bus', 'SLTB', 'Colombo Fort', 'Maharagama', TRUE),
  (2, '100', 'Pettah - Panadura', 'bus', 'Western Province Transport Authority', 'Pettah', 'Panadura', TRUE),
  (3, 'MAIN-RLY', 'Colombo Fort - Kandy Main Line', 'train', 'Sri Lanka Railways', 'Colombo Fort', 'Kandy', TRUE),
  (4, 'COAST-RLY', 'Colombo Fort - Galle Coastal Line', 'train', 'Sri Lanka Railways', 'Colombo Fort', 'Galle', TRUE)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `transport_type` = VALUES(`transport_type`),
  `is_active` = VALUES(`is_active`);

-- -----------------------------------------------------------------------------
-- Table 5: route_stops
-- -----------------------------------------------------------------------------
INSERT INTO `route_stops` (`id`, `name`, `stop_code`, `latitude`, `longitude`, `city`, `is_active`)
VALUES
  (101, 'Pettah Central Bus Stand', 'PET-01', 6.93600000, 79.85500000, 'Colombo 11', TRUE),
  (102, 'Colombo Fort Railway Station', 'FOT-01', 6.93550000, 79.85300000, 'Colombo 01', TRUE),
  (103, 'Slave Island / Kompannavidiya', 'SLI-01', 6.92300000, 79.85200000, 'Colombo 02', TRUE),
  (104, 'Town Hall / Viharamahadevi Park', 'TOW-01', 6.91470000, 79.86530000, 'Colombo 07', TRUE),
  (105, 'Bambalapitiya Junction', 'BAM-01', 6.88900000, 79.85600000, 'Colombo 04', TRUE),
  (106, 'Nugegoda Supermarket', 'NUG-01', 6.87240000, 79.88980000, 'Nugegoda', TRUE),
  (107, 'Maharagama Central Bus Stand', 'MAH-01', 6.84800000, 79.92650000, 'Maharagama', TRUE),
  (108, 'Homagama Main Bus Stand', 'HOM-01', 6.84150000, 79.99800000, 'Homagama', TRUE),
  (109, 'Mount Lavinia Junction', 'MTL-01', 6.83750000, 79.86400000, 'Mount Lavinia', TRUE),
  (110, 'Moratuwa Bus Stand', 'MOR-01', 6.77300000, 79.88200000, 'Moratuwa', TRUE),
  (111, 'Panadura Central Bus Stand', 'PAN-01', 6.71300000, 79.90700000, 'Panadura', TRUE),
  (112, 'Ragama Junction Railway Station', 'RAG-01', 7.02700000, 79.92300000, 'Ragama', TRUE),
  (113, 'Gampaha Railway Station', 'GAM-01', 7.09100000, 79.99900000, 'Gampaha', TRUE),
  (114, 'Polgahawela Railway Station', 'POL-01', 7.33300000, 80.30000000, 'Polgahawela', TRUE),
  (115, 'Kandy Railway Station', 'KDY-01', 7.29060000, 80.63370000, 'Kandy', TRUE),
  (116, 'Galle Central Railway Station', 'GLE-01', 6.03670000, 80.21700000, 'Galle', TRUE)
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `latitude` = VALUES(`latitude`),
  `longitude` = VALUES(`longitude`),
  `is_active` = VALUES(`is_active`);

-- -----------------------------------------------------------------------------
-- Table 2: user_profiles
-- -----------------------------------------------------------------------------
INSERT INTO `user_profiles` (`user_id`, `home_stop_id`, `work_stop_id`, `preferred_transport_mode`, `bio`)
VALUES
  (1, 101, 105, 'bus', 'Daily commuter on route 138.'),
  (2, 104, 102, 'any', 'Colombo transit corridor traveler.'),
  (3, 104, 102, 'any', 'Transit safety moderator for Western Province.'),
  (4, 102, 102, 'any', 'System administrator for TravelPulse LK.'),
  (5, 106, 101, 'bus', 'Frequent route 138 traveler.')
ON DUPLICATE KEY UPDATE
  `home_stop_id` = VALUES(`home_stop_id`),
  `work_stop_id` = VALUES(`work_stop_id`),
  `preferred_transport_mode` = VALUES(`preferred_transport_mode`),
  `bio` = VALUES(`bio`);

-- -----------------------------------------------------------------------------
-- Table 3: device_tokens
-- -----------------------------------------------------------------------------
INSERT INTO `device_tokens` (`id`, `user_id`, `fcm_token`, `device_type`)
VALUES
  (1, 1, 'fcm_token_kamal_android_mock_001', 'android'),
  (2, 2, 'fcm_token_dilshan_ios_mock_002', 'ios'),
  (3, 5, 'fcm_token_malith_android_mock_003', 'android')
ON DUPLICATE KEY UPDATE
  `fcm_token` = VALUES(`fcm_token`),
  `device_type` = VALUES(`device_type`);

-- -----------------------------------------------------------------------------
-- Table 6: route_stop_sequences
-- -----------------------------------------------------------------------------
INSERT INTO `route_stop_sequences` (`id`, `route_id`, `stop_id`, `stop_order`, `distance_from_prev_km`, `est_minutes_from_prev`)
VALUES
  -- Route 1 (138)
  (1001, 1, 101, 1, 0.00, 0),
  (1002, 1, 102, 2, 0.80, 4),
  (1003, 1, 104, 3, 2.50, 10),
  (1004, 1, 106, 4, 6.20, 18),
  (1005, 1, 107, 5, 4.50, 12),
  (1006, 1, 108, 6, 6.00, 14),
  -- Route 2 (100)
  (2001, 2, 101, 1, 0.00, 0),
  (2002, 2, 105, 2, 5.20, 15),
  (2003, 2, 109, 3, 6.00, 16),
  (2004, 2, 110, 4, 7.50, 20),
  (2005, 2, 111, 5, 8.00, 22),
  -- Route 3 (MAIN-RLY)
  (3001, 3, 102, 1, 0.00, 0),
  (3002, 3, 112, 2, 15.00, 25),
  (3003, 3, 113, 3, 12.00, 18),
  (3004, 3, 114, 4, 45.00, 50),
  (3005, 3, 115, 5, 48.00, 65)
ON DUPLICATE KEY UPDATE
  `stop_order` = VALUES(`stop_order`),
  `distance_from_prev_km` = VALUES(`distance_from_prev_km`),
  `est_minutes_from_prev` = VALUES(`est_minutes_from_prev`);

-- -----------------------------------------------------------------------------
-- Table 7: route_schedules
-- -----------------------------------------------------------------------------
INSERT INTO `route_schedules` (`id`, `route_id`, `departure_time`, `arrival_time`, `day_of_week`, `trip_direction`, `is_active`)
VALUES
  (1, 1, '06:00:00', '07:00:00', 'all', 'outbound', TRUE),
  (2, 1, '06:30:00', '07:30:00', 'all', 'outbound', TRUE),
  (3, 1, '07:00:00', '08:00:00', 'all', 'outbound', TRUE),
  (4, 1, '07:30:00', '08:30:00', 'all', 'outbound', TRUE),
  (5, 1, '08:00:00', '09:00:00', 'all', 'outbound', TRUE),
  (6, 2, '06:15:00', '07:35:00', 'all', 'outbound', TRUE),
  (7, 2, '07:00:00', '08:20:00', 'all', 'outbound', TRUE),
  (8, 3, '05:55:00', '08:50:00', 'all', 'outbound', TRUE),
  (9, 3, '07:00:00', '09:45:00', 'all', 'outbound', TRUE)
ON DUPLICATE KEY UPDATE
  `departure_time` = VALUES(`departure_time`),
  `arrival_time` = VALUES(`arrival_time`),
  `is_active` = VALUES(`is_active`);

-- -----------------------------------------------------------------------------
-- Table 8: user_journeys
-- -----------------------------------------------------------------------------
INSERT INTO `user_journeys` (`id`, `user_id`, `route_id`, `origin_stop_id`, `destination_stop_id`, `start_time`, `end_time`, `status`)
VALUES
  (501, 1, 1, 101, 107, DATE_SUB(NOW(), INTERVAL 3 HOUR), DATE_SUB(NOW(), INTERVAL 2 HOUR), 'completed'),
  (502, 2, 2, 101, 105, DATE_SUB(NOW(), INTERVAL 1 HOUR), NULL, 'in_progress')
ON DUPLICATE KEY UPDATE
  `status` = VALUES(`status`),
  `end_time` = VALUES(`end_time`);

SET FOREIGN_KEY_CHECKS = 1;

