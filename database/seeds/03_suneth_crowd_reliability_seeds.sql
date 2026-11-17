-- =============================================================================
-- TravelPulse LK — Module 3: Crowd Intelligence & Report Reliability Seed Data
-- Owning Member: Suneth
-- =============================================================================

-- Table 12: user_reputations
INSERT INTO `user_reputations` (
  `user_id`, `reputation_score`, `total_reports_submitted`,
  `verified_reports_count`, `rejected_reports_count`, `total_votes_cast`, `updated_at`
) VALUES
  (1, 82.50, 6, 5, 0, 14, NOW()),
  (2, 76.00, 4, 3, 0, 10, NOW()),
  (3, 88.00, 9, 8, 0, 22, NOW()),
  (4, 90.00, 11, 10, 0, 28, NOW()),
  (5, 98.00, 20, 19, 0, 45, NOW())
ON DUPLICATE KEY UPDATE
  `reputation_score` = VALUES(`reputation_score`),
  `total_reports_submitted` = VALUES(`total_reports_submitted`),
  `verified_reports_count` = VALUES(`verified_reports_count`),
  `total_votes_cast` = VALUES(`total_votes_cast`);

-- Table 13: report_votes
INSERT INTO `report_votes` (`report_id`, `user_id`, `vote_type`, `created_at`)
VALUES
  (101, 2, 'upvote', DATE_SUB(NOW(), INTERVAL 20 MINUTE)),
  (101, 3, 'upvote', DATE_SUB(NOW(), INTERVAL 18 MINUTE)),
  (101, 4, 'upvote', DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
  (101, 5, 'upvote', DATE_SUB(NOW(), INTERVAL 12 MINUTE)),
  (102, 1, 'upvote', DATE_SUB(NOW(), INTERVAL 60 MINUTE)),
  (102, 3, 'upvote', DATE_SUB(NOW(), INTERVAL 55 MINUTE)),
  (102, 4, 'upvote', DATE_SUB(NOW(), INTERVAL 50 MINUTE)),
  (102, 5, 'upvote', DATE_SUB(NOW(), INTERVAL 40 MINUTE)),
  (103, 2, 'upvote', DATE_SUB(NOW(), INTERVAL 10 MINUTE)),
  (103, 3, 'upvote', DATE_SUB(NOW(), INTERVAL 8 MINUTE)),
  (103, 4, 'upvote', DATE_SUB(NOW(), INTERVAL 5 MINUTE))
ON DUPLICATE KEY UPDATE
  `vote_type` = VALUES(`vote_type`);

-- Table 14: report_reliability
INSERT INTO `report_reliability` (
  `report_id`, `reliability_score`, `confidence_status`,
  `upvotes_count`, `downvotes_count`, `corroboration_count`, `last_calculated_at`
) VALUES
  (101, 84.00, 'verified', 8, 1, 3, NOW()),
  (102, 92.00, 'verified', 14, 0, 5, NOW()),
  (103, 60.00, 'plausible', 3, 0, 2, NOW())
ON DUPLICATE KEY UPDATE
  `reliability_score` = VALUES(`reliability_score`),
  `confidence_status` = VALUES(`confidence_status`),
  `upvotes_count` = VALUES(`upvotes_count`),
  `downvotes_count` = VALUES(`downvotes_count`),
  `corroboration_count` = VALUES(`corroboration_count`);

-- Table 15: crowd_estimates
INSERT INTO `crowd_estimates` (
  `user_id`, `route_id`, `stop_id`, `crowd_level`, `passenger_wait_time_minutes`, `reported_at`
) VALUES
  (1, 1, NULL, 'crowded', 15, DATE_SUB(NOW(), INTERVAL 12 MINUTE)),
  (2, 1, NULL, 'very_crowded', 20, DATE_SUB(NOW(), INTERVAL 18 MINUTE)),
  (3, 1, NULL, 'crowded', 18, DATE_SUB(NOW(), INTERVAL 24 MINUTE)),
  (4, 2, NULL, 'moderate', 8, DATE_SUB(NOW(), INTERVAL 15 MINUTE)),
  (1, 2, NULL, 'moderate', 10, DATE_SUB(NOW(), INTERVAL 25 MINUTE)),
  (2, NULL, 101, 'very_crowded', 25, DATE_SUB(NOW(), INTERVAL 14 MINUTE)),
  (3, NULL, 101, 'very_crowded', 20, DATE_SUB(NOW(), INTERVAL 22 MINUTE)),
  (4, NULL, 104, 'moderate', 10, DATE_SUB(NOW(), INTERVAL 16 MINUTE)),
  (5, 3, NULL, 'crowded', 12, DATE_SUB(NOW(), INTERVAL 28 MINUTE));

-- Table 16: crowd_aggregations (dual nullable foreign keys adhering to chk_crowd_agg_target)
INSERT INTO `crowd_aggregations` (
  `route_id`, `stop_id`, `time_slot`, `aggregated_crowd_level`,
  `sample_count`, `confidence_score`, `last_updated_at`
) VALUES
  (1, NULL, NOW(), 'very_crowded', 8, 88.50, NOW()),
  (2, NULL, NOW(), 'moderate', 5, 82.00, NOW()),
  (3, NULL, NOW(), 'crowded', 6, 85.00, NOW()),
  (NULL, 101, NOW(), 'very_crowded', 9, 91.00, NOW()),
  (NULL, 104, NOW(), 'moderate', 4, 78.50, NOW())
ON DUPLICATE KEY UPDATE
  `aggregated_crowd_level` = VALUES(`aggregated_crowd_level`),
  `sample_count` = VALUES(`sample_count`),
  `confidence_score` = VALUES(`confidence_score`);

