-- =============================================================================
-- TravelPulse LK — Module 4: Road Conditions, Maps & Alerts Seed Data
-- Owning Member: Thimaya
-- =============================================================================

-- Table 17: road_incidents
INSERT INTO `road_incidents` (
  `id`, `source_report_id`, `incident_type`, `latitude`, `longitude`,
  `address_text`, `severity`, `radius_meters`, `is_active`, `verified_by_user_id`,
  `start_time`, `end_time`, `created_at`
) VALUES
  (
    401, 102, 'flooding', 6.89200000, 79.85800000,
    'Bauddhaloka Mawatha, Thunmulla Junction, Colombo 04', 'high', 250, TRUE, 5,
    DATE_SUB(NOW(), INTERVAL 70 MINUTE), NULL, DATE_SUB(NOW(), INTERVAL 70 MINUTE)
  ),
  (
    402, 101, 'road_closure', 6.91470000, 79.86530000,
    'Town Hall Roundabout, Colombo 07', 'medium', 120, TRUE, 5,
    DATE_SUB(NOW(), INTERVAL 25 MINUTE), NULL, DATE_SUB(NOW(), INTERVAL 25 MINUTE)
  ),
  (
    403, NULL, 'pothole', 6.87240000, 79.88980000,
    'High Level Road near Nugegoda Flyover', 'medium', 50, TRUE, 5,
    DATE_SUB(NOW(), INTERVAL 24 HOUR), NULL, DATE_SUB(NOW(), INTERVAL 24 HOUR)
  ),
  (
    404, NULL, 'traffic_lights_down', 6.90220000, 79.86100000,
    'Thimbirigasyaya Junction traffic signal malfunction', 'low', 80, TRUE, 5,
    DATE_SUB(NOW(), INTERVAL 45 MINUTE), NULL, DATE_SUB(NOW(), INTERVAL 45 MINUTE)
  )
ON DUPLICATE KEY UPDATE
  `incident_type` = VALUES(`incident_type`),
  `severity` = VALUES(`severity`),
  `is_active` = VALUES(`is_active`);

-- Table 18: travel_alerts
INSERT INTO `travel_alerts` (
  `id`, `title`, `message`, `alert_type`, `severity`,
  `related_incident_id`, `target_route_id`, `target_latitude`, `target_longitude`,
  `target_radius_km`, `status`, `created_by`, `created_at`, `expires_at`
) VALUES
  (
    301, 'Flash Flood Warning — Thunmulla Junction',
    'Severe waterlogging at Bauddhaloka Mawatha near Thunmulla roundabout. Routes 138 and 100 operating with heavy delays. Light vehicles advised to divert via Havelock Road.',
    'road_condition', 'critical',
    401, 1, 6.89200000, 79.85800000, 2.50, 'active', 5,
    DATE_SUB(NOW(), INTERVAL 60 MINUTE), DATE_ADD(NOW(), INTERVAL 3 HOUR)
  ),
  (
    302, 'Main Line Railway Signal Interruption',
    'Signal failures between Ragama and Gampaha. Up-country commuter trains from Colombo Fort experiencing 25-30 minute delays.',
    'transport_disruption', 'warning',
    NULL, 3, 7.02700000, 79.92300000, 5.00, 'active', 5,
    DATE_SUB(NOW(), INTERVAL 40 MINUTE), DATE_ADD(NOW(), INTERVAL 2 HOUR)
  ),
  (
    303, 'Route 138 Centre-Lane Obstruction at Town Hall',
    'Broken down SLTB bus near Town Hall roundabout. Single lane traffic moving slowly towards Maradana.',
    'transport_disruption', 'info',
    402, 1, 6.91470000, 79.86530000, 1.00, 'active', 5,
    DATE_SUB(NOW(), INTERVAL 20 MINUTE), DATE_ADD(NOW(), INTERVAL 1 HOUR)
  )
ON DUPLICATE KEY UPDATE
  `title` = VALUES(`title`),
  `message` = VALUES(`message`),
  `status` = VALUES(`status`);

-- Table 19: alert_subscriptions
INSERT INTO `alert_subscriptions` (
  `id`, `user_id`, `subscription_type`, `route_id`, `center_latitude`, `center_longitude`, `radius_km`, `is_active`
) VALUES
  (1, 1, 'route', 1, NULL, NULL, NULL, TRUE),
  (2, 1, 'geo_radius', NULL, 6.92710000, 79.86120000, 5.00, TRUE),
  (3, 2, 'all_critical', NULL, NULL, NULL, NULL, TRUE)
ON DUPLICATE KEY UPDATE
  `is_active` = VALUES(`is_active`);

-- Table 20: alert_deliveries
INSERT INTO `alert_deliveries` (
  `id`, `alert_id`, `user_id`, `device_token_id`, `delivery_status`, `fcm_message_id`, `delivered_at`, `created_at`
) VALUES
  (1, 301, 1, NULL, 'sent', 'fcm_mock_msg_301_001', DATE_SUB(NOW(), INTERVAL 55 MINUTE), DATE_SUB(NOW(), INTERVAL 60 MINUTE)),
  (2, 301, 2, NULL, 'sent', 'fcm_mock_msg_301_002', DATE_SUB(NOW(), INTERVAL 55 MINUTE), DATE_SUB(NOW(), INTERVAL 60 MINUTE))
ON DUPLICATE KEY UPDATE
  `delivery_status` = VALUES(`delivery_status`);

