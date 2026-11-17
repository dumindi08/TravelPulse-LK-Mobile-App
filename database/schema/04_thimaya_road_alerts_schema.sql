-- =============================================================================
-- TravelPulse LK — Module 4: Road Conditions, Maps and Travel Alert System
-- Owning Member: Thimaya
-- Database Engine: MySQL 8.0+ (InnoDB)
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Table 17: road_incidents
-- Physical road hazards, closures, and condition markers displayed on Google Maps.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `road_incidents` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `source_report_id` BIGINT UNSIGNED NULL,
  `incident_type` ENUM('pothole', 'flooding', 'landslide', 'road_closure', 'accident', 'congestion', 'traffic_lights_down') NOT NULL,
  `latitude` DECIMAL(10, 8) NOT NULL,
  `longitude` DECIMAL(11, 8) NOT NULL,
  `address_text` VARCHAR(255) NULL,
  `severity` ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
  `radius_meters` INT UNSIGNED NOT NULL DEFAULT 100,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `verified_by_user_id` BIGINT UNSIGNED NULL,
  `start_time` DATETIME NOT NULL,
  `end_time` DATETIME NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_incidents_coords_active` (`latitude`, `longitude`, `is_active`),
  INDEX `idx_incidents_type` (`incident_type`),
  CONSTRAINT `fk_incidents_report` FOREIGN KEY (`source_report_id`) REFERENCES `community_reports` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_incidents_verifier` FOREIGN KEY (`verified_by_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 18: travel_alerts
-- Public travel alerts and emergency transit broadcasts.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `travel_alerts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(150) NOT NULL,
  `message` TEXT NOT NULL,
  `alert_type` ENUM('transport_disruption', 'road_condition', 'weather_emergency', 'security') NOT NULL,
  `severity` ENUM('info', 'warning', 'critical') NOT NULL DEFAULT 'info',
  `related_disruption_id` BIGINT UNSIGNED NULL,
  `related_incident_id` BIGINT UNSIGNED NULL,
  `target_route_id` BIGINT UNSIGNED NULL,
  `target_latitude` DECIMAL(10, 8) NULL,
  `target_longitude` DECIMAL(11, 8) NULL,
  `target_radius_km` DECIMAL(5, 2) NULL,
  `status` ENUM('active', 'expired', 'cancelled') NOT NULL DEFAULT 'active',
  `created_by` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_alerts_status_expires` (`status`, `expires_at`),
  INDEX `idx_alerts_route` (`target_route_id`),
  CONSTRAINT `fk_alerts_disruption` FOREIGN KEY (`related_disruption_id`) REFERENCES `transport_disruptions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_alerts_incident` FOREIGN KEY (`related_incident_id`) REFERENCES `road_incidents` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_alerts_route` FOREIGN KEY (`target_route_id`) REFERENCES `transport_routes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_alerts_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 19: alert_subscriptions
-- Commuter preferences for alerts on routes or geographic locations.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `alert_subscriptions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `subscription_type` ENUM('route', 'geo_radius', 'all_critical') NOT NULL DEFAULT 'route',
  `route_id` BIGINT UNSIGNED NULL,
  `center_latitude` DECIMAL(10, 8) NULL,
  `center_longitude` DECIMAL(11, 8) NULL,
  `radius_km` DECIMAL(5, 2) NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_sub_user` (`user_id`),
  INDEX `idx_sub_route` (`route_id`),
  CONSTRAINT `fk_sub_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sub_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Table 20: alert_deliveries
-- Audit tracking for push notifications dispatched to device tokens.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `alert_deliveries` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `alert_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `device_token_id` BIGINT UNSIGNED NULL,
  `delivery_status` ENUM('pending', 'sent', 'failed') NOT NULL DEFAULT 'pending',
  `fcm_message_id` VARCHAR(255) NULL,
  `delivered_at` DATETIME NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_delivery_alert` (`alert_id`),
  INDEX `idx_delivery_user` (`user_id`),
  CONSTRAINT `fk_delivery_alert` FOREIGN KEY (`alert_id`) REFERENCES `travel_alerts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_delivery_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_delivery_token` FOREIGN KEY (`device_token_id`) REFERENCES `device_tokens` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

