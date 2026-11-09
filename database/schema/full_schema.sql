-- =============================================================================
-- TravelPulse LK — Complete Consolidated Database Schema
-- Database Engine: MySQL 8.0+ (InnoDB)
-- Collation: utf8mb4 / utf8mb4_unicode_ci
-- Total Tables: 20
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `travelpulse_lk`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `travelpulse_lk`;

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- MODULE 1: NISAL — USER, TRANSPORT ROUTE & JOURNEY MANAGEMENT
-- -----------------------------------------------------------------------------

-- 1. users
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

-- 2. transport_routes
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

-- 3. route_stops
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

-- 4. user_profiles
CREATE TABLE IF NOT EXISTS `user_profiles` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `home_stop_id` BIGINT UNSIGNED NULL,
  `work_stop_id` BIGINT UNSIGNED NULL,
  `preferred_transport_mode` ENUM('bus', 'train', 'any') NOT NULL DEFAULT 'any',
  `bio` VARCHAR(255) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_profiles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_profiles_home_stop` FOREIGN KEY (`home_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_profiles_work_stop` FOREIGN KEY (`work_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. device_tokens
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

-- 6. route_stop_sequences
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

-- 7. route_schedules
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

-- 8. user_journeys
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

-- -----------------------------------------------------------------------------
-- MODULE 2: DUMINDI — COMMUNITY REPORTING & DISRUPTION MANAGEMENT
-- -----------------------------------------------------------------------------

-- 9. report_categories
CREATE TABLE IF NOT EXISTS `report_categories` (
  `id` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(255) NULL,
  `default_severity` ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_report_cat_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. community_reports
CREATE TABLE IF NOT EXISTS `community_reports` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `is_anonymous` BOOLEAN NOT NULL DEFAULT FALSE,
  `category_id` SMALLINT UNSIGNED NOT NULL,
  `route_id` BIGINT UNSIGNED NULL,
  `stop_id` BIGINT UNSIGNED NULL,
  `latitude` DECIMAL(10, 8) NOT NULL,
  `longitude` DECIMAL(11, 8) NOT NULL,
  `location_description` VARCHAR(255) NULL,
  `title` VARCHAR(150) NOT NULL,
  `description` TEXT NOT NULL,
  `disruption_reason` VARCHAR(100) NULL,
  `media_url` VARCHAR(255) NULL,
  `status` ENUM('submitted', 'verified', 'disputed', 'resolved', 'rejected', 'expired') NOT NULL DEFAULT 'submitted',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_reports_coords` (`latitude`, `longitude`),
  INDEX `idx_reports_route_status` (`route_id`, `status`),
  INDEX `idx_reports_user` (`user_id`),
  INDEX `idx_reports_created` (`created_at`),
  CONSTRAINT `fk_reports_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reports_category` FOREIGN KEY (`category_id`) REFERENCES `report_categories` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_reports_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reports_stop` FOREIGN KEY (`stop_id`) REFERENCES `route_stops` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. transport_disruptions
CREATE TABLE IF NOT EXISTS `transport_disruptions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `originating_report_id` BIGINT UNSIGNED NULL,
  `route_id` BIGINT UNSIGNED NOT NULL,
  `affected_stop_id` BIGINT UNSIGNED NULL,
  `disruption_type` VARCHAR(50) NOT NULL,
  `severity` ENUM('low', 'medium', 'high', 'critical') NOT NULL DEFAULT 'medium',
  `headline` VARCHAR(200) NOT NULL,
  `details` TEXT NOT NULL,
  `status` ENUM('active', 'cleared', 'archived') NOT NULL DEFAULT 'active',
  `started_at` DATETIME NOT NULL,
  `estimated_cleared_at` DATETIME NULL,
  `cleared_at` DATETIME NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_disruptions_route_status` (`route_id`, `status`),
  CONSTRAINT `fk_disruptions_report` FOREIGN KEY (`originating_report_id`) REFERENCES `community_reports` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_disruptions_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_disruptions_stop` FOREIGN KEY (`affected_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- MODULE 3: SUNETH — CROWD INTELLIGENCE & REPORT RELIABILITY ENGINE
-- -----------------------------------------------------------------------------

-- 12. user_reputations
CREATE TABLE IF NOT EXISTS `user_reputations` (
  `user_id` BIGINT UNSIGNED NOT NULL,
  `reputation_score` DECIMAL(5, 2) NOT NULL DEFAULT 10.00,
  `total_reports_submitted` INT UNSIGNED NOT NULL DEFAULT 0,
  `verified_reports_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `rejected_reports_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `total_votes_cast` INT UNSIGNED NOT NULL DEFAULT 0,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  INDEX `idx_reputation_score` (`reputation_score`),
  CONSTRAINT `fk_reputation_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. report_votes
CREATE TABLE IF NOT EXISTS `report_votes` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `report_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `vote_type` ENUM('upvote', 'downvote', 'confirm_resolved') NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_report_user_vote` (`report_id`, `user_id`),
  INDEX `idx_votes_report` (`report_id`),
  INDEX `idx_votes_user` (`user_id`),
  CONSTRAINT `fk_votes_report` FOREIGN KEY (`report_id`) REFERENCES `community_reports` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_votes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. report_reliability
CREATE TABLE IF NOT EXISTS `report_reliability` (
  `report_id` BIGINT UNSIGNED NOT NULL,
  `reliability_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
  `confidence_status` ENUM('unverified', 'plausible', 'verified', 'disputed', 'rejected') NOT NULL DEFAULT 'unverified',
  `upvotes_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `downvotes_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `corroboration_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `last_calculated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  INDEX `idx_reliability_status` (`confidence_status`, `reliability_score`),
  CONSTRAINT `fk_reliability_report` FOREIGN KEY (`report_id`) REFERENCES `community_reports` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. crowd_estimates
CREATE TABLE IF NOT EXISTS `crowd_estimates` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `route_id` BIGINT UNSIGNED NULL,
  `stop_id` BIGINT UNSIGNED NULL,
  `crowd_level` ENUM('empty', 'moderate', 'crowded', 'very_crowded') NOT NULL,
  `passenger_wait_time_minutes` SMALLINT UNSIGNED NULL,
  `reported_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_crowd_route_time` (`route_id`, `reported_at`),
  INDEX `idx_crowd_stop_time` (`stop_id`, `reported_at`),
  INDEX `idx_crowd_user` (`user_id`),
  CONSTRAINT `fk_crowd_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_crowd_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_crowd_stop` FOREIGN KEY (`stop_id`) REFERENCES `route_stops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. crowd_aggregations
CREATE TABLE IF NOT EXISTS `crowd_aggregations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_id` BIGINT UNSIGNED NULL,
  `stop_id` BIGINT UNSIGNED NULL,
  `time_slot` DATETIME NOT NULL,
  `aggregated_crowd_level` ENUM('empty', 'moderate', 'crowded', 'very_crowded') NOT NULL,
  `sample_count` INT UNSIGNED NOT NULL DEFAULT 1,
  `confidence_score` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
  `last_updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_crowd_agg_route_slot` (`route_id`, `time_slot`),
  INDEX `idx_crowd_agg_stop_slot` (`stop_id`, `time_slot`),
  CONSTRAINT `chk_crowd_agg_target` CHECK (
    (`route_id` IS NOT NULL AND `stop_id` IS NULL) OR
    (`route_id` IS NULL AND `stop_id` IS NOT NULL)
  ),
  CONSTRAINT `fk_crowd_agg_route` FOREIGN KEY (`route_id`) REFERENCES `transport_routes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_crowd_agg_stop` FOREIGN KEY (`stop_id`) REFERENCES `route_stops` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- MODULE 4: THIMAYA — ROAD CONDITIONS, MAPS & TRAVEL ALERT SYSTEM
-- -----------------------------------------------------------------------------

-- 17. road_incidents
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

-- 18. travel_alerts
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

-- 19. alert_subscriptions
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

-- 20. alert_deliveries
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

