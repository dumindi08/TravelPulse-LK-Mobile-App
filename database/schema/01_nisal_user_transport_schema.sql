-- =============================================================================
-- TravelPulse LK — Module 1: User, Transport Route & Journey Management
-- Owning Member: Nisal
-- Database Engine: MySQL 8.0+ (InnoDB)
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Table 1: users
-- Core commuter accounts, credentials, and access roles.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `phone_number` VARCHAR(20) NULL,
  `role` ENUM('commuter', 'moderator', 'admin') NOT NULL DEFAULT 'commuter',
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  INDEX `idx_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 2: user_profiles
-- Commuter preferences and frequent transit locations.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_profiles` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `home_stop_id` BIGINT UNSIGNED NULL,
  `work_stop_id` BIGINT UNSIGNED NULL,
  `preferred_transport_mode` ENUM('bus', 'train', 'any') NOT NULL DEFAULT 'any',
  `bio` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 3: device_tokens
-- Firebase Cloud Messaging (FCM) tokens for targeted push notifications.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `device_tokens` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `fcm_token` VARCHAR(255) NOT NULL,
  `device_type` ENUM('android', 'ios') NOT NULL DEFAULT 'android',
  `last_active_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_device_fcm_token` (`fcm_token`),
  INDEX `idx_device_tokens_user` (`user_id`),
  CONSTRAINT `fk_device_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 4: transport_routes
-- Master public transit routes (bus lines, train lines).
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `transport_routes` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_number` VARCHAR(20) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `transport_type` ENUM('bus', 'train') NOT NULL,
  `operator` VARCHAR(100) NULL,
  `origin_city` VARCHAR(100) NOT NULL,
  `destination_city` VARCHAR(100) NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_routes_lookup` (`route_number`, `transport_type`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 5: route_stops
-- Master catalog of physical bus stops and train stations with GPS coordinates.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `route_stops` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `stop_code` VARCHAR(50) NULL,
  `latitude` DECIMAL(10, 8) NOT NULL,
  `longitude` DECIMAL(11, 8) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_stops_code` (`stop_code`),
  INDEX `idx_stops_coords` (`latitude`, `longitude`),
  INDEX `idx_stops_city` (`city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add deferred foreign keys from user_profiles to route_stops
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `fk_profiles_home_stop` FOREIGN KEY (`home_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_profiles_work_stop` FOREIGN KEY (`work_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE SET NULL;

-- -----------------------------------------------------------------------------
-- Table 6: route_stop_sequences
-- Ordered sequence of stops defining the transit line path.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `route_stop_sequences` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_id` BIGINT UNSIGNED NOT NULL,
  `stop_id` BIGINT UNSIGNED NOT NULL,
  `stop_order` SMALLINT UNSIGNED NOT NULL,
  `distance_from_prev_km` DECIMAL(6, 2) NULL DEFAULT 0.00,
  `est_minutes_from_prev` SMALLINT UNSIGNED NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_route_stop_order` (`route_id`, `stop_order`),
  UNIQUE KEY `uq_route_stop_pair` (`route_id`, `stop_id`),
  CONSTRAINT `fk_seq_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_seq_stop` FOREIGN KEY (`stop_id`) REFERENCES `route_stops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 7: route_schedules
-- Timetables and scheduled departures for transit lines.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `route_schedules` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_id` BIGINT UNSIGNED NOT NULL,
  `departure_time` TIME NOT NULL,
  `arrival_time` TIME NOT NULL,
  `day_of_week` ENUM('all', 'weekday', 'weekend', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday') NOT NULL DEFAULT 'all',
  `trip_direction` ENUM('outbound', 'inbound') NOT NULL DEFAULT 'outbound',
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`id`),
  INDEX `idx_schedules_route_day` (`route_id`, `day_of_week`, `departure_time`),
  CONSTRAINT `fk_schedules_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 8: user_journeys
-- Commuter travel journeys, logged for history and personalized alerting.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user_journeys` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `route_id` BIGINT UNSIGNED NOT NULL,
  `origin_stop_id` BIGINT UNSIGNED NOT NULL,
  `destination_stop_id` BIGINT UNSIGNED NOT NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NULL,
  `status` ENUM('planned', 'in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'planned',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_journeys_user_status` (`user_id`, `status`),
  CONSTRAINT `fk_journeys_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_journeys_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_journeys_origin` FOREIGN KEY (`origin_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_journeys_dest` FOREIGN KEY (`destination_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

