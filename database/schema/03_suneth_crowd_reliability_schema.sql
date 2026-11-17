-- =============================================================================
-- TravelPulse LK — Module 3: Crowd Intelligence & Report Reliability Engine
-- Owning Member: Suneth
-- Database Engine: MySQL 8.0+ (InnoDB)
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Table 12: user_reputations
-- Commuter trustworthiness and credibility score based on verified contributions.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Table 13: report_votes
-- Peer verification votes on community reports (upvote, downvote, confirm resolved).
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Table 14: report_reliability
-- Calculated algorithmic trustworthiness score and confidence status for reports.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Table 15: crowd_estimates
-- Commuter crowd observations for transit vehicles and stops.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Table 16: crowd_aggregations
-- Aggregated statistical crowd metrics over sliding time intervals (15-30 min).
-- Uses dual nullable foreign keys (route_id, stop_id) with CHECK constraint.
-- -----------------------------------------------------------------------------
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

SET FOREIGN_KEY_CHECKS = 1;

