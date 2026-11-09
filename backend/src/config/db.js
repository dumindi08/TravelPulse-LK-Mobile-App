/**
 * TravelPulse LK — Shared Database Configuration & Data Store
 * Owning Member: Suneth (Database Architecture, Reliability & Crowd Engine)
 * ---------------------------------------------------------------------------
 * Connects to MySQL 8.0+ when available, or provides a structured in-memory
 * relational store matching MySQL 8.0 schema for offline development & testing.
 *
 * Fully supports:
 *  - Module 1 (Nisal): Users, Routes, Stops, Schedules
 *  - Module 2 (Dumindi): Report categories, Community reports
 *  - Module 3 (Suneth): User reputations, Report votes, Reliability scores,
 *                       Crowd estimates, and Sliding-window crowd aggregations
 */

const { calculateReliability } = require('../engine/confidenceScorer');
const { findDuplicates } = require('../engine/duplicateDetector');
const { aggregateCrowdEstimates } = require('../engine/crowdEngine');

const categoriesSeed = [
  { id: 1, code: 'CROWD', name: 'Crowd Report', description: 'Real-time transit crowd density and wait times', default_severity: 'low', is_active: true },
  { id: 2, code: 'ROAD_CONDITION', name: 'Road Condition', description: 'Potholes, flooding, road closures, and hazards', default_severity: 'medium', is_active: true },
  { id: 3, code: 'TRANSPORT_TRACKING', name: 'Transport/Route Tracking', description: 'Bus and train operational movement and tracking', default_severity: 'low', is_active: true },
  { id: 4, code: 'SERVICE_DISRUPTION', name: 'Service Disruption', description: 'Cancellations, breakdowns, delays, and service interruptions', default_severity: 'high', is_active: true },
  { id: 5, code: 'ACCIDENT_INCIDENT', name: 'Accident/Incident', description: 'Traffic collisions, emergencies, and safety incidents', default_severity: 'critical', is_active: true },
  { id: 6, code: 'OTHER', name: 'Other', description: 'General commuter notices, lost & found, and feedback', default_severity: 'low', is_active: true },
];

const initialUserReputationsSeed = [
  { user_id: 1, reputation_score: 82.50, total_reports_submitted: 6, verified_reports_count: 5, rejected_reports_count: 0, total_votes_cast: 14 },
  { user_id: 2, reputation_score: 76.00, total_reports_submitted: 4, verified_reports_count: 3, rejected_reports_count: 0, total_votes_cast: 10 },
  { user_id: 3, reputation_score: 88.00, total_reports_submitted: 9, verified_reports_count: 8, rejected_reports_count: 0, total_votes_cast: 22 },
  { user_id: 4, reputation_score: 90.00, total_reports_submitted: 11, verified_reports_count: 10, rejected_reports_count: 0, total_votes_cast: 28 },
  { user_id: 5, reputation_score: 98.00, total_reports_submitted: 20, verified_reports_count: 19, rejected_reports_count: 0, total_votes_cast: 45 },
];

const initialReportsSeed = [
  {
    id: 101,
    user_id: 1,
    user_name: 'Kamal Perera',
    user_email: 'kamal@example.com',
    is_anonymous: false,
    category_id: 4,
    category_name: 'Service Disruption',
    route_id: 1,
    route_number: '138',
    stop_id: 104,
    stop_name: 'Town Hall / Viharamahadevi Park',
    latitude: 6.9147,
    longitude: 79.8653,
    location_description: 'Town Hall roundabout near Public Library',
    title: 'Bus Breakdown Blocking Center Lane',
    description: 'Route 138 SLTB bus broke down right after the roundabout. Traffic backing up towards Maradana and Borella.',
    disruption_reason: 'Vehicle Breakdown',
    media_url: null,
    status: 'verified',
    reliability_score: 84.0,
    confidence_status: 'verified',
    upvotes_count: 8,
    downvotes_count: 1,
    created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
  {
    id: 102,
    user_id: 2,
    user_name: 'Dilshan Silva',
    user_email: 'dilshan@example.com',
    is_anonymous: true,
    category_id: 2,
    category_name: 'Road Condition',
    route_id: 2,
    route_number: '100',
    stop_id: null,
    stop_name: null,
    latitude: 6.8920,
    longitude: 79.8580,
    location_description: 'Bauddhaloka Mawatha near Thunmulla',
    title: 'Severe Waterlogging / Flash Flood',
    description: 'Heavy rain has flooded the junction with 1.5 feet of water. Low clearance three-wheelers and cars cannot pass. Buses moving slowly.',
    disruption_reason: 'Road Inundation / Flooding',
    media_url: null,
    status: 'verified',
    reliability_score: 92.0,
    confidence_status: 'verified',
    upvotes_count: 14,
    downvotes_count: 0,
    created_at: new Date(Date.now() - 70 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
  {
    id: 103,
    user_id: 1,
    user_name: 'Kamal Perera',
    user_email: 'kamal@example.com',
    is_anonymous: false,
    category_id: 1,
    category_name: 'Crowd Report',
    route_id: 1,
    route_number: '138',
    stop_id: 101,
    stop_name: 'Pettah Main Bus Stand',
    latitude: 6.9355,
    longitude: 79.8530,
    location_description: 'Route 138 bus bay',
    title: 'Heavy Evening Rush Hour Overcrowding',
    description: 'Huge queue extending over 50 meters. Buses arriving every 10 minutes but fill immediately.',
    disruption_reason: null,
    media_url: null,
    status: 'submitted',
    reliability_score: 60.0,
    confidence_status: 'plausible',
    upvotes_count: 3,
    downvotes_count: 0,
    created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
];

const initialReportVotesSeed = [
  { id: 1, report_id: 101, user_id: 2, vote_type: 'upvote', created_at: new Date(Date.now() - 20 * 60 * 1000).toISOString() },
  { id: 2, report_id: 101, user_id: 3, vote_type: 'upvote', created_at: new Date(Date.now() - 18 * 60 * 1000).toISOString() },
  { id: 3, report_id: 101, user_id: 4, vote_type: 'upvote', created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() },
  { id: 4, report_id: 101, user_id: 5, vote_type: 'upvote', created_at: new Date(Date.now() - 12 * 60 * 1000).toISOString() },
  { id: 5, report_id: 102, user_id: 1, vote_type: 'upvote', created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() },
  { id: 6, report_id: 102, user_id: 3, vote_type: 'upvote', created_at: new Date(Date.now() - 55 * 60 * 1000).toISOString() },
  { id: 7, report_id: 102, user_id: 4, vote_type: 'upvote', created_at: new Date(Date.now() - 50 * 60 * 1000).toISOString() },
  { id: 8, report_id: 103, user_id: 2, vote_type: 'upvote', created_at: new Date(Date.now() - 10 * 60 * 1000).toISOString() },
  { id: 9, report_id: 103, user_id: 3, vote_type: 'upvote', created_at: new Date(Date.now() - 8 * 60 * 1000).toISOString() },
];

const initialCrowdEstimatesSeed = [
  { id: 1, user_id: 1, route_id: 1, stop_id: null, crowd_level: 'crowded', passenger_wait_time_minutes: 15, reported_at: new Date(Date.now() - 12 * 60 * 1000).toISOString() },
  { id: 2, user_id: 2, route_id: 1, stop_id: null, crowd_level: 'very_crowded', passenger_wait_time_minutes: 20, reported_at: new Date(Date.now() - 18 * 60 * 1000).toISOString() },
  { id: 3, user_id: 3, route_id: 1, stop_id: null, crowd_level: 'crowded', passenger_wait_time_minutes: 18, reported_at: new Date(Date.now() - 24 * 60 * 1000).toISOString() },
  { id: 4, user_id: 4, route_id: 2, stop_id: null, crowd_level: 'moderate', passenger_wait_time_minutes: 8, reported_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() },
  { id: 5, user_id: 1, route_id: 2, stop_id: null, crowd_level: 'moderate', passenger_wait_time_minutes: 10, reported_at: new Date(Date.now() - 25 * 60 * 1000).toISOString() },
  { id: 6, user_id: 2, route_id: null, stop_id: 101, crowd_level: 'very_crowded', passenger_wait_time_minutes: 25, reported_at: new Date(Date.now() - 14 * 60 * 1000).toISOString() },
  { id: 7, user_id: 3, route_id: null, stop_id: 101, crowd_level: 'very_crowded', passenger_wait_time_minutes: 20, reported_at: new Date(Date.now() - 22 * 60 * 1000).toISOString() },
  { id: 8, user_id: 4, route_id: null, stop_id: 104, crowd_level: 'moderate', passenger_wait_time_minutes: 10, reported_at: new Date(Date.now() - 16 * 60 * 1000).toISOString() },
  { id: 9, user_id: 5, route_id: 3, stop_id: null, crowd_level: 'crowded', passenger_wait_time_minutes: 12, reported_at: new Date(Date.now() - 28 * 60 * 1000).toISOString() },
];

const initialCrowdAggregationsSeed = [
  { id: 1, route_id: 1, stop_id: null, time_slot: new Date().toISOString(), aggregated_crowd_level: 'very_crowded', sample_count: 8, confidence_score: 88.50, last_updated_at: new Date().toISOString() },
  { id: 2, route_id: 2, stop_id: null, time_slot: new Date().toISOString(), aggregated_crowd_level: 'moderate', sample_count: 5, confidence_score: 82.00, last_updated_at: new Date().toISOString() },
  { id: 3, route_id: 3, stop_id: null, time_slot: new Date().toISOString(), aggregated_crowd_level: 'crowded', sample_count: 6, confidence_score: 85.00, last_updated_at: new Date().toISOString() },
  { id: 4, route_id: null, stop_id: 101, time_slot: new Date().toISOString(), aggregated_crowd_level: 'very_crowded', sample_count: 9, confidence_score: 91.00, last_updated_at: new Date().toISOString() },
  { id: 5, route_id: null, stop_id: 104, time_slot: new Date().toISOString(), aggregated_crowd_level: 'moderate', sample_count: 4, confidence_score: 78.50, last_updated_at: new Date().toISOString() },
];

const initialRoadIncidentsSeed = [
  {
    id: 401,
    source_report_id: 102,
    incident_type: 'flooding',
    latitude: 6.8920,
    longitude: 79.8580,
    address_text: 'Bauddhaloka Mawatha, Thunmulla Junction, Colombo 04',
    severity: 'high',
    radius_meters: 250,
    is_active: true,
    verified_by_user_id: 5,
    start_time: new Date(Date.now() - 70 * 60 * 1000).toISOString(),
    end_time: null,
    created_at: new Date(Date.now() - 70 * 60 * 1000).toISOString(),
  },
  {
    id: 402,
    source_report_id: 101,
    incident_type: 'road_closure',
    latitude: 6.9147,
    longitude: 79.8653,
    address_text: 'Town Hall Roundabout, Colombo 07',
    severity: 'medium',
    radius_meters: 120,
    is_active: true,
    verified_by_user_id: 5,
    start_time: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    end_time: null,
    created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
  },
  {
    id: 403,
    source_report_id: null,
    incident_type: 'pothole',
    latitude: 6.8724,
    longitude: 79.8898,
    address_text: 'High Level Road near Nugegoda Flyover',
    severity: 'medium',
    radius_meters: 50,
    is_active: true,
    verified_by_user_id: 5,
    start_time: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
    end_time: null,
    created_at: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: 404,
    source_report_id: null,
    incident_type: 'traffic_lights_down',
    latitude: 6.9022,
    longitude: 79.8610,
    address_text: 'Thimbirigasyaya Junction traffic signal malfunction',
    severity: 'low',
    radius_meters: 80,
    is_active: true,
    verified_by_user_id: 5,
    start_time: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
    end_time: null,
    created_at: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
  },
];

const initialTravelAlertsSeed = [
  {
    id: 301,
    title: 'Flash Flood Warning — Thunmulla Junction',
    message: 'Severe waterlogging at Bauddhaloka Mawatha near Thunmulla roundabout. Routes 138 and 100 operating with heavy delays. Light vehicles advised to divert via Havelock Road.',
    alert_type: 'road_condition',
    severity: 'critical',
    related_incident_id: 401,
    target_route_id: 1,
    target_route_number: '138',
    target_latitude: 6.8920,
    target_longitude: 79.8580,
    target_radius_km: 2.5,
    status: 'active',
    created_by: 5,
    created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
    expires_at: new Date(Date.now() + 3 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: 302,
    title: 'Main Line Railway Signal Interruption',
    message: 'Signal failures between Ragama and Gampaha. Up-country commuter trains from Colombo Fort experiencing 25-30 minute delays.',
    alert_type: 'transport_disruption',
    severity: 'warning',
    related_incident_id: null,
    target_route_id: 3,
    target_route_number: 'MAIN-RLY',
    target_latitude: 7.0270,
    target_longitude: 79.9230,
    target_radius_km: 5.0,
    status: 'active',
    created_by: 5,
    created_at: new Date(Date.now() - 40 * 60 * 1000).toISOString(),
    expires_at: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString(),
  },
  {
    id: 303,
    title: 'Route 138 Centre-Lane Obstruction at Town Hall',
    message: 'Broken down SLTB bus near Town Hall roundabout. Single lane traffic moving slowly towards Maradana.',
    alert_type: 'transport_disruption',
    severity: 'info',
    related_incident_id: 402,
    target_route_id: 1,
    target_route_number: '138',
    target_latitude: 6.9147,
    target_longitude: 79.8653,
    target_radius_km: 1.0,
    status: 'active',
    created_by: 5,
    created_at: new Date(Date.now() - 20 * 60 * 1000).toISOString(),
    expires_at: new Date(Date.now() + 1 * 60 * 60 * 1000).toISOString(),
  },
];

const initialAlertSubscriptionsSeed = [
  { id: 1, user_id: 1, subscription_type: 'route', route_id: 1, center_latitude: null, center_longitude: null, radius_km: null, is_active: true },
  { id: 2, user_id: 1, subscription_type: 'geo_radius', route_id: null, center_latitude: 6.9271, center_longitude: 79.8612, radius_km: 5.0, is_active: true },
  { id: 3, user_id: 2, subscription_type: 'all_critical', route_id: null, center_latitude: null, center_longitude: null, radius_km: null, is_active: true },
];

const initialAlertDeliveriesSeed = [
  { id: 1, alert_id: 301, user_id: 1, device_token_id: null, delivery_status: 'sent', fcm_message_id: 'fcm_mock_msg_301_001', delivered_at: new Date(Date.now() - 55 * 60 * 1000).toISOString(), created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() },
  { id: 2, alert_id: 301, user_id: 2, device_token_id: null, delivery_status: 'sent', fcm_message_id: 'fcm_mock_msg_301_002', delivered_at: new Date(Date.now() - 55 * 60 * 1000).toISOString(), created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() },
];

const initialUsersSeed = [
  { id: 1, name: 'Kamal Perera', email: 'kamal@example.com', password: 'Password123!', phoneNumber: '+94771234567', role: 'commuter', isActive: true },
  { id: 2, name: 'Dilshan Silva', email: 'dilshan@example.com', password: 'Password123!', phoneNumber: '+94719876543', role: 'commuter', isActive: true },
  { id: 3, name: 'Anusha Silva', email: 'moderator@travelpulse.lk', password: 'Password123!', phoneNumber: '+94762345678', role: 'moderator', isActive: true },
  { id: 4, name: 'System Administrator', email: 'admin@travelpulse.lk', password: 'Password123!', phoneNumber: '+94703456789', role: 'admin', isActive: true },
  { id: 5, name: 'Malith Senanayake', email: 'malith@example.com', password: 'Password123!', phoneNumber: '+94784567890', role: 'commuter', isActive: true },
];

const initialStopsSeed = [
  { id: 101, name: 'Pettah Central Bus Stand', stopCode: 'PET-01', latitude: 6.9360, longitude: 79.8550, city: 'Colombo 11', isActive: true },
  { id: 102, name: 'Colombo Fort Railway Station', stopCode: 'FOT-01', latitude: 6.9355, longitude: 79.8530, city: 'Colombo 01', isActive: true },
  { id: 103, name: 'Slave Island / Kompannavidiya', stopCode: 'SLI-01', latitude: 6.9230, longitude: 79.8520, city: 'Colombo 02', isActive: true },
  { id: 104, name: 'Town Hall / Viharamahadevi Park', stopCode: 'TOW-01', latitude: 6.9147, longitude: 79.8653, city: 'Colombo 07', isActive: true },
  { id: 105, name: 'Bambalapitiya Junction', stopCode: 'BAM-01', latitude: 6.8890, longitude: 79.8560, city: 'Colombo 04', isActive: true },
  { id: 106, name: 'Nugegoda Supermarket', stopCode: 'NUG-01', latitude: 6.8724, longitude: 79.8898, city: 'Nugegoda', isActive: true },
  { id: 107, name: 'Maharagama Central Bus Stand', stopCode: 'MAH-01', latitude: 6.8480, longitude: 79.9265, city: 'Maharagama', isActive: true },
  { id: 108, name: 'Homagama Main Bus Stand', stopCode: 'HOM-01', latitude: 6.8415, longitude: 79.9980, city: 'Homagama', isActive: true },
  { id: 109, name: 'Mount Lavinia Junction', stopCode: 'MTL-01', latitude: 6.8375, longitude: 79.8640, city: 'Mount Lavinia', isActive: true },
  { id: 110, name: 'Moratuwa Bus Stand', stopCode: 'MOR-01', latitude: 6.7730, longitude: 79.8820, city: 'Moratuwa', isActive: true },
  { id: 111, name: 'Panadura Central Bus Stand', stopCode: 'PAN-01', latitude: 6.7130, longitude: 79.9070, city: 'Panadura', isActive: true },
  { id: 112, name: 'Ragama Junction Railway Station', stopCode: 'RAG-01', latitude: 7.0270, longitude: 79.9230, city: 'Ragama', isActive: true },
  { id: 113, name: 'Gampaha Railway Station', stopCode: 'GAM-01', latitude: 7.0910, longitude: 79.9990, city: 'Gampaha', isActive: true },
  { id: 114, name: 'Polgahawela Railway Station', stopCode: 'POL-01', latitude: 7.3330, longitude: 80.3000, city: 'Polgahawela', isActive: true },
  { id: 115, name: 'Kandy Railway Station', stopCode: 'KDY-01', latitude: 7.2906, longitude: 80.6337, city: 'Kandy', isActive: true },
  { id: 116, name: 'Galle Central Railway Station', stopCode: 'GLE-01', latitude: 6.0367, longitude: 80.2170, city: 'Galle', isActive: true },
];

const initialRoutesSeed = [
  {
    id: 1,
    routeNumber: '138',
    name: 'Colombo Fort - Maharagama / Homagama',
    transportType: 'bus',
    operator: 'SLTB',
    originCity: 'Colombo Fort',
    destinationCity: 'Maharagama',
    isActive: true,
    estTotalMinutes: 48,
    stops: [
      { id: 1001, routeId: 1, stopId: 101, stopName: 'Pettah Central Bus Stand', stopOrder: 1, latitude: 6.9360, longitude: 79.8550, distanceFromPrevKm: 0.0, estMinutesFromPrev: 0 },
      { id: 1002, routeId: 1, stopId: 102, stopName: 'Colombo Fort Railway Station', stopOrder: 2, latitude: 6.9355, longitude: 79.8530, distanceFromPrevKm: 0.8, estMinutesFromPrev: 4 },
      { id: 1003, routeId: 1, stopId: 104, stopName: 'Town Hall / Viharamahadevi Park', stopOrder: 3, latitude: 6.9147, longitude: 79.8653, distanceFromPrevKm: 2.5, estMinutesFromPrev: 10 },
      { id: 1004, routeId: 1, stopId: 106, stopName: 'Nugegoda Supermarket', stopOrder: 4, latitude: 6.8724, longitude: 79.8898, distanceFromPrevKm: 6.2, estMinutesFromPrev: 18 },
      { id: 1005, routeId: 1, stopId: 107, stopName: 'Maharagama Central Bus Stand', stopOrder: 5, latitude: 6.8480, longitude: 79.9265, distanceFromPrevKm: 4.5, estMinutesFromPrev: 12 },
      { id: 1006, routeId: 1, stopId: 108, stopName: 'Homagama Main Bus Stand', stopOrder: 6, latitude: 6.8415, longitude: 79.9980, distanceFromPrevKm: 6.0, estMinutesFromPrev: 14 },
    ],
  },
  {
    id: 2,
    routeNumber: '100',
    name: 'Pettah - Panadura',
    transportType: 'bus',
    operator: 'Western Province Transport Authority',
    originCity: 'Pettah',
    destinationCity: 'Panadura',
    isActive: true,
    estTotalMinutes: 70,
    stops: [
      { id: 2001, routeId: 2, stopId: 101, stopName: 'Pettah Central Bus Stand', stopOrder: 1, latitude: 6.9360, longitude: 79.8550, distanceFromPrevKm: 0.0, estMinutesFromPrev: 0 },
      { id: 2002, routeId: 2, stopId: 105, stopName: 'Bambalapitiya Junction', stopOrder: 2, latitude: 6.8890, longitude: 79.8560, distanceFromPrevKm: 5.2, estMinutesFromPrev: 15 },
      { id: 2003, routeId: 2, stopId: 109, stopName: 'Mount Lavinia Junction', stopOrder: 3, latitude: 6.8375, longitude: 79.8640, distanceFromPrevKm: 6.0, estMinutesFromPrev: 16 },
      { id: 2004, routeId: 2, stopId: 110, stopName: 'Moratuwa Bus Stand', stopOrder: 4, latitude: 6.7730, longitude: 79.8820, distanceFromPrevKm: 7.5, estMinutesFromPrev: 20 },
      { id: 2005, routeId: 2, stopId: 111, stopName: 'Panadura Central Bus Stand', stopOrder: 5, latitude: 6.7130, longitude: 79.9070, distanceFromPrevKm: 8.0, estMinutesFromPrev: 22 },
    ],
  },
  {
    id: 3,
    routeNumber: 'MAIN-RLY',
    name: 'Colombo Fort - Kandy Main Line',
    transportType: 'train',
    operator: 'Sri Lanka Railways',
    originCity: 'Colombo Fort',
    destinationCity: 'Kandy',
    isActive: true,
    estTotalMinutes: 165,
    stops: [
      { id: 3001, routeId: 3, stopId: 102, stopName: 'Colombo Fort Railway Station', stopOrder: 1, latitude: 6.9355, longitude: 79.8530, distanceFromPrevKm: 0.0, estMinutesFromPrev: 0 },
      { id: 3002, routeId: 3, stopId: 112, stopName: 'Ragama Junction Railway Station', stopOrder: 2, latitude: 7.0270, longitude: 79.9230, distanceFromPrevKm: 15.0, estMinutesFromPrev: 25 },
      { id: 3003, routeId: 3, stopId: 113, stopName: 'Gampaha Railway Station', stopOrder: 3, latitude: 7.0910, longitude: 79.9990, distanceFromPrevKm: 12.0, estMinutesFromPrev: 18 },
      { id: 3004, routeId: 3, stopId: 114, stopName: 'Polgahawela Railway Station', stopOrder: 4, latitude: 7.3330, longitude: 80.3000, distanceFromPrevKm: 45.0, estMinutesFromPrev: 50 },
      { id: 3005, routeId: 3, stopId: 115, stopName: 'Kandy Railway Station', stopOrder: 5, latitude: 7.2906, longitude: 80.6337, distanceFromPrevKm: 48.0, estMinutesFromPrev: 65 },
    ],
  },
  {
    id: 4,
    routeNumber: 'COAST-RLY',
    name: 'Colombo Fort - Galle Coastal Line',
    transportType: 'train',
    operator: 'Sri Lanka Railways',
    originCity: 'Colombo Fort',
    destinationCity: 'Galle',
    isActive: true,
    estTotalMinutes: 130,
    stops: [
      { id: 4001, routeId: 4, stopId: 102, stopName: 'Colombo Fort Railway Station', stopOrder: 1, latitude: 6.9355, longitude: 79.8530, distanceFromPrevKm: 0.0, estMinutesFromPrev: 0 },
      { id: 4002, routeId: 4, stopId: 105, stopName: 'Bambalapitiya Junction', stopOrder: 2, latitude: 6.8890, longitude: 79.8560, distanceFromPrevKm: 5.2, estMinutesFromPrev: 12 },
      { id: 4003, routeId: 4, stopId: 109, stopName: 'Mount Lavinia Junction', stopOrder: 3, latitude: 6.8375, longitude: 79.8640, distanceFromPrevKm: 6.0, estMinutesFromPrev: 14 },
      { id: 4004, routeId: 4, stopId: 111, stopName: 'Panadura Central Bus Stand', stopOrder: 4, latitude: 6.7130, longitude: 79.9070, distanceFromPrevKm: 15.0, estMinutesFromPrev: 24 },
      { id: 4005, routeId: 4, stopId: 116, stopName: 'Galle Central Railway Station', stopOrder: 5, latitude: 6.0367, longitude: 80.2170, distanceFromPrevKm: 85.0, estMinutesFromPrev: 80 },
    ],
  },
];

const initialSchedulesSeed = [
  { id: 1, routeId: 1, departureTime: '06:00:00', arrivalTime: '07:00:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 2, routeId: 1, departureTime: '06:30:00', arrivalTime: '07:30:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 3, routeId: 1, departureTime: '07:00:00', arrivalTime: '08:00:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 4, routeId: 1, departureTime: '07:30:00', arrivalTime: '08:30:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 5, routeId: 1, departureTime: '08:00:00', arrivalTime: '09:00:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 6, routeId: 2, departureTime: '06:15:00', arrivalTime: '07:35:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 7, routeId: 2, departureTime: '07:00:00', arrivalTime: '08:20:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 8, routeId: 3, departureTime: '05:55:00', arrivalTime: '08:50:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
  { id: 9, routeId: 3, departureTime: '07:00:00', arrivalTime: '09:45:00', dayOfWeek: 'all', tripDirection: 'outbound', isActive: true },
];

const initialJourneysSeed = [
  { id: 501, userId: 1, routeId: 1, routeNumber: '138', originStopId: 101, originStopName: 'Pettah Central Bus Stand', destinationStopId: 107, destinationStopName: 'Maharagama Central Bus Stand', startTime: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(), endTime: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), status: 'completed' },
  { id: 502, userId: 2, routeId: 2, routeNumber: '100', originStopId: 101, originStopName: 'Pettah Central Bus Stand', destinationStopId: 105, destinationStopName: 'Bambalapitiya Junction', startTime: new Date(Date.now() - 60 * 60 * 1000).toISOString(), endTime: null, status: 'in_progress' },
];

/**
 * In-Memory Database Store (active for fast, reliable unit testing & offline dev)
 */
class MemoryStore {
  constructor() {
    this.users = JSON.parse(JSON.stringify(initialUsersSeed));
    this.routes = JSON.parse(JSON.stringify(initialRoutesSeed));
    this.stops = JSON.parse(JSON.stringify(initialStopsSeed));
    this.schedules = JSON.parse(JSON.stringify(initialSchedulesSeed));
    this.journeys = JSON.parse(JSON.stringify(initialJourneysSeed));
    this.categories = [...categoriesSeed];
    this.reports = JSON.parse(JSON.stringify(initialReportsSeed));
    this.userReputations = JSON.parse(JSON.stringify(initialUserReputationsSeed));
    this.reportVotes = JSON.parse(JSON.stringify(initialReportVotesSeed));
    this.crowdEstimates = JSON.parse(JSON.stringify(initialCrowdEstimatesSeed));
    this.crowdAggregations = JSON.parse(JSON.stringify(initialCrowdAggregationsSeed));
    this.roadIncidents = JSON.parse(JSON.stringify(initialRoadIncidentsSeed));
    this.travelAlerts = JSON.parse(JSON.stringify(initialTravelAlertsSeed));
    this.alertSubscriptions = JSON.parse(JSON.stringify(initialAlertSubscriptionsSeed));
    this.alertDeliveries = JSON.parse(JSON.stringify(initialAlertDeliveriesSeed));
    this.deviceTokens = [];

    this.nextUserId = 6;
    this.nextJourneyId = 503;
    this.nextReportId = 104;
    this.nextVoteId = 10;
    this.nextEstimateId = 10;
    this.nextAggregationId = 6;
    this.nextIncidentId = 405;
    this.nextAlertId = 304;
    this.nextSubId = 4;
    this.nextDeliveryId = 3;
    this.nextTokenId = 1;
  }

  // ---------------------------------------------------------------------------
  // Module 1: Nisal (Users, Routes, Schedules & Journeys)
  // ---------------------------------------------------------------------------
  findUserByEmail(email) {
    if (!email) return null;
    return this.users.find((u) => u.email.toLowerCase() === email.toLowerCase()) || null;
  }

  findUserById(id) {
    const user = this.users.find((u) => Number(u.id) === Number(id));
    if (!user) return null;
    const { password, ...safeUser } = user;
    return safeUser;
  }

  createUser({ name, email, password, phoneNumber = null, role = 'commuter' }) {
    const existing = this.findUserByEmail(email);
    if (existing) {
      return { error: 'EMAIL_EXISTS', message: 'An account with this email already exists.' };
    }
    const newUser = {
      id: this.nextUserId++,
      name,
      email,
      password: password || 'Password123!',
      phoneNumber,
      role,
      isActive: true,
      createdAt: new Date().toISOString(),
    };
    this.users.push(newUser);
    // Initialize reputation record in Suneth's table
    this.userReputations.push({
      user_id: newUser.id,
      reputation_score: 10.0,
      total_reports_submitted: 0,
      verified_reports_count: 0,
      rejected_reports_count: 0,
      total_votes_cast: 0,
    });
    const { password: _, ...safeUser } = newUser;
    return safeUser;
  }

  getRoutes({ transportType, origin, destination }) {
    let result = [...this.routes];
    if (transportType && transportType.toLowerCase() !== 'all') {
      result = result.filter((r) => r.transportType.toLowerCase() === transportType.toLowerCase());
    }
    if (origin) {
      const q = origin.toLowerCase();
      result = result.filter((r) =>
        r.originCity.toLowerCase().includes(q) ||
        r.name.toLowerCase().includes(q) ||
        r.stops.some((s) => s.stopName.toLowerCase().includes(q))
      );
    }
    if (destination) {
      const q = destination.toLowerCase();
      result = result.filter((r) =>
        r.destinationCity.toLowerCase().includes(q) ||
        r.name.toLowerCase().includes(q) ||
        r.stops.some((s) => s.stopName.toLowerCase().includes(q))
      );
    }
    // Attach live crowd level from aggregations if available
    return result.map((r) => {
      const agg = this.getCrowdAggregation({ routeId: r.id });
      return {
        ...r,
        currentCrowdLevel: agg ? agg.aggregated_crowd_level : 'moderate',
      };
    });
  }

  getRouteById(id) {
    const route = this.routes.find((r) => Number(r.id) === Number(id));
    if (!route) return null;
    const agg = this.getCrowdAggregation({ routeId: route.id });
    // Active disruptions on this route
    const activeReports = this.reports.filter(
      (rep) => Number(rep.route_id) === Number(route.id) && rep.status !== 'resolved' && rep.status !== 'rejected'
    );
    return {
      ...route,
      currentCrowdLevel: agg ? agg.aggregated_crowd_level : 'moderate',
      crowdConfidenceScore: agg ? agg.confidence_score : 75.0,
      activeDisruptions: activeReports.map((rep) => ({
        id: rep.id,
        title: rep.title,
        status: rep.status,
        reason: rep.disruption_reason,
        location: rep.location_description,
      })),
    };
  }

  getRouteSchedules(routeId, { direction = 'outbound', dayOfWeek = 'all' } = {}) {
    return this.schedules.filter((s) => {
      if (Number(s.routeId) !== Number(routeId)) return false;
      if (direction && s.tripDirection.toLowerCase() !== direction.toLowerCase()) return false;
      if (dayOfWeek && dayOfWeek !== 'all' && s.dayOfWeek !== 'all' && s.dayOfWeek !== dayOfWeek) return false;
      return true;
    });
  }

  getJourneys(userId) {
    return this.journeys.filter((j) => Number(j.userId) === Number(userId));
  }

  createJourney({ userId, routeId, originStopId, destinationStopId }) {
    const route = this.routes.find((r) => Number(r.id) === Number(routeId));
    const origin = this.stops.find((s) => Number(s.id) === Number(originStopId));
    const dest = this.stops.find((s) => Number(s.id) === Number(destinationStopId));

    const newJourney = {
      id: this.nextJourneyId++,
      userId: Number(userId),
      routeId: Number(routeId),
      routeNumber: route ? route.routeNumber : 'UNKNOWN',
      originStopId: Number(originStopId),
      originStopName: origin ? origin.name : 'Origin Stop',
      destinationStopId: Number(destinationStopId),
      destinationStopName: dest ? dest.name : 'Destination Stop',
      startTime: new Date().toISOString(),
      endTime: null,
      status: 'in_progress',
    };
    this.journeys.unshift(newJourney);
    return newJourney;
  }

  completeJourney(journeyId, userId) {
    const journey = this.journeys.find(
      (j) => Number(j.id) === Number(journeyId) && Number(j.userId) === Number(userId)
    );
    if (!journey) return null;
    journey.status = 'completed';
    journey.endTime = new Date().toISOString();
    return journey;
  }

  // ---------------------------------------------------------------------------
  // Categories (Dumindi Module)
  // ---------------------------------------------------------------------------
  getCategories() {
    return this.categories.filter((c) => c.is_active);
  }

  getCategoryById(id) {
    return this.categories.find((c) => c.id === Number(id));
  }

  // ---------------------------------------------------------------------------
  // Community Reports (Dumindi Module)
  // ---------------------------------------------------------------------------
  getReports({ categoryId, status, routeId }) {
    let result = [...this.reports];
    if (categoryId) {
      result = result.filter((r) => r.category_id === Number(categoryId));
    }
    if (status && status.toLowerCase() !== 'all') {
      result = result.filter((r) => r.status.toLowerCase() === status.toLowerCase());
    }
    if (routeId) {
      result = result.filter((r) => r.route_id === Number(routeId));
    }
    return result.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  getReportById(id) {
    return this.reports.find((r) => r.id === Number(id));
  }

  getReportsByUserId(userId) {
    return this.reports
      .filter((r) => r.user_id === Number(userId))
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  createReport(data) {
    const category = this.getCategoryById(data.category_id);
    const categoryCode = category ? category.code : 'OTHER';

    // 1. Check for spatial-temporal duplicates and corroboration (Suneth's engine)
    const dupCheck = findDuplicates(
      {
        ...data,
        createdAt: new Date(),
      },
      this.reports
    );

    // 2. Fetch author reputation
    const authorRep = this.getUserReputation(data.user_id);
    const baseReputation = authorRep ? authorRep.reputation_score : 10.0;

    // 3. Compute initial reliability score
    const reliabilityResult = calculateReliability({
      baseReputation,
      upvotes: 1, // Author implicit initial confidence
      downvotes: 0,
      corroborations: dupCheck.corroborationCount,
      createdAt: new Date(),
      categoryCode,
    });

    const newReport = {
      id: this.nextReportId++,
      user_id: data.user_id,
      user_name: data.user_name || 'Commuter',
      user_email: data.user_email || 'commuter@travelpulse.lk',
      is_anonymous: Boolean(data.is_anonymous),
      category_id: data.category_id,
      category_name: category ? category.name : 'General Report',
      route_id: data.route_id ? Number(data.route_id) : null,
      route_number: data.route_number || null,
      stop_id: data.stop_id ? Number(data.stop_id) : null,
      stop_name: data.stop_name || null,
      latitude: Number(data.latitude),
      longitude: Number(data.longitude),
      location_description: data.location_description || '',
      title: data.title,
      description: data.description,
      disruption_reason: data.disruption_reason || null,
      media_url: data.media_url || null,
      status: reliabilityResult.confidenceStatus === 'verified' ? 'verified' : 'submitted',
      reliability_score: reliabilityResult.reliabilityScore,
      confidence_status: reliabilityResult.confidenceStatus,
      upvotes_count: 1,
      downvotes_count: 0,
      created_at: new Date().toISOString(),
      resolved_at: null,
    };

    this.reports.unshift(newReport);

    // Update author's report submission counter
    this.updateUserReputation(data.user_id, {
      total_reports_submitted: (authorRep?.total_reports_submitted || 0) + 1,
    });

    return newReport;
  }

  updateReport(id, updates) {
    const report = this.getReportById(id);
    if (!report) return null;
    Object.assign(report, updates);
    return report;
  }

  deleteReport(id) {
    const index = this.reports.findIndex((r) => r.id === Number(id));
    if (index === -1) return false;
    this.reports.splice(index, 1);
    // Remove associated votes
    this.reportVotes = this.reportVotes.filter((v) => v.report_id !== Number(id));
    return true;
  }

  // ---------------------------------------------------------------------------
  // Module 3: User Reputations (Suneth)
  // ---------------------------------------------------------------------------
  getUserReputation(userId) {
    const rep = this.userReputations.find((r) => r.user_id === Number(userId));
    if (!rep) {
      // Default initial reputation for newly registered commuters
      const defaultRep = {
        user_id: Number(userId),
        reputation_score: 10.00,
        total_reports_submitted: 0,
        verified_reports_count: 0,
        rejected_reports_count: 0,
        total_votes_cast: 0,
        updated_at: new Date().toISOString(),
      };
      this.userReputations.push(defaultRep);
      return defaultRep;
    }
    return rep;
  }

  updateUserReputation(userId, updates) {
    const rep = this.getUserReputation(userId);
    Object.assign(rep, updates, { updated_at: new Date().toISOString() });
    return rep;
  }

  // ---------------------------------------------------------------------------
  // Module 3: Report Peer Voting & Reliability (Suneth)
  // ---------------------------------------------------------------------------
  getUserVoteOnReport(reportId, userId) {
    return this.reportVotes.find(
      (v) => v.report_id === Number(reportId) && v.user_id === Number(userId)
    );
  }

  getVotesForReport(reportId) {
    return this.reportVotes.filter((v) => v.report_id === Number(reportId));
  }

  castReportVote({ reportId, userId, voteType }) {
    const report = this.getReportById(reportId);
    if (!report) {
      throw new Error('Report not found');
    }

    const existingVote = this.getUserVoteOnReport(reportId, userId);

    if (existingVote) {
      if (existingVote.vote_type === voteType) {
        // Toggle/remove vote if clicked again
        const voteIdx = this.reportVotes.indexOf(existingVote);
        this.reportVotes.splice(voteIdx, 1);

        if (voteType === 'upvote') {
          report.upvotes_count = Math.max(0, report.upvotes_count - 1);
        } else if (voteType === 'downvote') {
          report.downvotes_count = Math.max(0, report.downvotes_count - 1);
        }
      } else {
        // Switch vote
        if (existingVote.vote_type === 'upvote') {
          report.upvotes_count = Math.max(0, report.upvotes_count - 1);
        } else if (existingVote.vote_type === 'downvote') {
          report.downvotes_count = Math.max(0, report.downvotes_count - 1);
        }

        existingVote.vote_type = voteType;
        if (voteType === 'upvote') {
          report.upvotes_count += 1;
        } else if (voteType === 'downvote') {
          report.downvotes_count += 1;
        }
      }
    } else {
      // New vote
      const newVote = {
        id: this.nextVoteId++,
        report_id: Number(reportId),
        user_id: Number(userId),
        vote_type: voteType,
        created_at: new Date().toISOString(),
      };
      this.reportVotes.push(newVote);

      if (voteType === 'upvote') {
        report.upvotes_count += 1;
      } else if (voteType === 'downvote') {
        report.downvotes_count += 1;
      }

      // Update voter reputation metric
      const voterRep = this.getUserReputation(userId);
      this.updateUserReputation(userId, {
        total_votes_cast: voterRep.total_votes_cast + 1,
      });
    }

    // Recalculate report reliability score using Suneth's confidenceScorer
    const authorRep = this.getUserReputation(report.user_id);
    const category = this.getCategoryById(report.category_id);
    const categoryCode = category ? category.code : 'OTHER';

    // Find any corroborating reports in the system
    const dupCheck = findDuplicates(report, this.reports);

    const reliabilityResult = calculateReliability({
      baseReputation: authorRep ? authorRep.reputation_score : 10.0,
      upvotes: report.upvotes_count,
      downvotes: report.downvotes_count,
      corroborations: dupCheck.corroborationCount,
      createdAt: report.created_at,
      categoryCode,
    });

    report.reliability_score = reliabilityResult.reliabilityScore;
    report.confidence_status = reliabilityResult.confidenceStatus;

    if (reliabilityResult.confidenceStatus === 'verified' && report.status === 'submitted') {
      report.status = 'verified';
      // Reward author with positive reputation score
      this.updateUserReputation(report.user_id, {
        verified_reports_count: authorRep.verified_reports_count + 1,
        reputation_score: Math.min(100.0, authorRep.reputation_score + 2.5),
      });
    }

    return {
      report,
      userVote: this.getUserVoteOnReport(reportId, userId)?.vote_type || null,
      reliabilityResult,
    };
  }

  // ---------------------------------------------------------------------------
  // Module 3: Crowd Estimates & Aggregations (Suneth)
  // ---------------------------------------------------------------------------
  addCrowdEstimate(data) {
    const hasRoute = data.route_id !== null && data.route_id !== undefined;
    const hasStop = data.stop_id !== null && data.stop_id !== undefined;

    if ((hasRoute && hasStop) || (!hasRoute && !hasStop)) {
      throw new Error('Crowd estimate must specify either route_id OR stop_id, not both.');
    }

    const newEstimate = {
      id: this.nextEstimateId++,
      user_id: Number(data.user_id),
      route_id: hasRoute ? Number(data.route_id) : null,
      stop_id: hasStop ? Number(data.stop_id) : null,
      crowd_level: data.crowd_level,
      passenger_wait_time_minutes: data.passenger_wait_time_minutes ? Number(data.passenger_wait_time_minutes) : null,
      reported_at: new Date().toISOString(),
    };

    this.crowdEstimates.unshift(newEstimate);

    // Recompute real-time aggregation for the affected target
    this.recomputeCrowdAggregation({
      routeId: newEstimate.route_id,
      stopId: newEstimate.stop_id,
    });

    return newEstimate;
  }

  getCrowdEstimates({ routeId, stopId }) {
    return this.crowdEstimates.filter((e) => {
      if (routeId) return Number(e.route_id) === Number(routeId);
      if (stopId) return Number(e.stop_id) === Number(stopId);
      return true;
    });
  }

  recomputeCrowdAggregation({ routeId, stopId }) {
    const repsMap = {};
    for (const r of this.userReputations) {
      repsMap[r.user_id] = r.reputation_score;
    }

    const aggResult = aggregateCrowdEstimates({
      routeId,
      stopId,
      estimates: this.crowdEstimates,
      userReputations: repsMap,
      windowMinutes: 30,
    });

    // Check if aggregation record exists
    let existing = this.crowdAggregations.find((a) => {
      if (routeId) return Number(a.route_id) === Number(routeId);
      if (stopId) return Number(a.stop_id) === Number(stopId);
      return false;
    });

    if (existing) {
      Object.assign(existing, {
        aggregated_crowd_level: aggResult.aggregated_crowd_level,
        sample_count: aggResult.sample_count,
        confidence_score: aggResult.confidence_score,
        last_updated_at: new Date().toISOString(),
      });
      return existing;
    } else {
      const newAgg = {
        id: this.nextAggregationId++,
        route_id: aggResult.route_id,
        stop_id: aggResult.stop_id,
        time_slot: aggResult.time_slot,
        aggregated_crowd_level: aggResult.aggregated_crowd_level,
        sample_count: aggResult.sample_count,
        confidence_score: aggResult.confidence_score,
        last_updated_at: new Date().toISOString(),
      };
      this.crowdAggregations.push(newAgg);
      return newAgg;
    }
  }

  getCrowdAggregation({ routeId, stopId }) {
    return (
      this.crowdAggregations.find((a) => {
        if (routeId) return Number(a.route_id) === Number(routeId);
        if (stopId) return Number(a.stop_id) === Number(stopId);
        return false;
      }) || null
    );
  }

  getAllCrowdAggregations() {
    return [...this.crowdAggregations];
  }

  // ---------------------------------------------------------------------------
  // Module 4: Road Conditions, Maps & Travel Alerts (Thimaya)
  // ---------------------------------------------------------------------------
  getRoadIncidents({ incidentType, severity, isActive, minLat, maxLat, minLon, maxLon }) {
    let list = [...this.roadIncidents];

    if (isActive !== undefined) {
      const activeBool = String(isActive).toLowerCase() === 'true';
      list = list.filter((i) => i.is_active === activeBool);
    }

    if (incidentType && incidentType.toLowerCase() !== 'all') {
      list = list.filter((i) => i.incident_type.toLowerCase() === incidentType.toLowerCase());
    }

    if (severity && severity.toLowerCase() !== 'all') {
      list = list.filter((i) => i.severity.toLowerCase() === severity.toLowerCase());
    }

    if (minLat !== undefined && maxLat !== undefined && minLon !== undefined && maxLon !== undefined) {
      list = list.filter((i) =>
        i.latitude >= Number(minLat) &&
        i.latitude <= Number(maxLat) &&
        i.longitude >= Number(minLon) &&
        i.longitude <= Number(maxLon)
      );
    }

    return list.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  getRoadIncidentById(id) {
    return this.roadIncidents.find((i) => i.id === Number(id));
  }

  createRoadIncident(data) {
    const newIncident = {
      id: this.nextIncidentId++,
      source_report_id: data.source_report_id ? Number(data.source_report_id) : null,
      incident_type: data.incident_type,
      latitude: Number(data.latitude),
      longitude: Number(data.longitude),
      address_text: data.address_text || '',
      severity: data.severity || 'medium',
      radius_meters: data.radius_meters ? Number(data.radius_meters) : 100,
      is_active: data.is_active !== undefined ? Boolean(data.is_active) : true,
      verified_by_user_id: data.verified_by_user_id ? Number(data.verified_by_user_id) : null,
      start_time: data.start_time || new Date().toISOString(),
      end_time: data.end_time || null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    this.roadIncidents.unshift(newIncident);
    return newIncident;
  }

  /**
   * Promotes a community report to a confirmed road incident.
   * STRICT REQUIREMENT: Only verified reports (reliability score >= 70 OR verified by moderator)
   * can be promoted into active road incidents!
   */
  promoteReportToIncident(reportId, verifierUser) {
    const report = this.getReportById(reportId);
    if (!report) {
      throw new Error(`Report #${reportId} not found.`);
    }

    const isStaff = verifierUser && (verifierUser.role === 'moderator' || verifierUser.role === 'admin');
    const isAlgorithmicVerified = report.status === 'verified' || report.confidence_status === 'verified' || report.reliability_score >= 70.0;

    if (!isAlgorithmicVerified && !isStaff) {
      throw new Error('Cannot promote report: Report is unverified (reliability score < 70) and requesting user lacks moderator privileges.');
    }

    // Map incident type based on report content
    let incidentType = 'congestion';
    const text = `${report.title} ${report.description} ${report.disruption_reason || ''}`.toLowerCase();

    if (text.includes('flood') || text.includes('waterlog') || text.includes('inundat')) {
      incidentType = 'flooding';
    } else if (text.includes('pothole') || text.includes('crater')) {
      incidentType = 'pothole';
    } else if (text.includes('accident') || text.includes('collision') || text.includes('crash')) {
      incidentType = 'accident';
    } else if (text.includes('closure') || text.includes('closed') || text.includes('blocked') || text.includes('breakdown')) {
      incidentType = 'road_closure';
    } else if (text.includes('signal') || text.includes('traffic light')) {
      incidentType = 'traffic_lights_down';
    } else if (text.includes('landslide') || text.includes('earthslip')) {
      incidentType = 'landslide';
    }

    const newIncident = this.createRoadIncident({
      source_report_id: report.id,
      incident_type: incidentType,
      latitude: report.latitude,
      longitude: report.longitude,
      address_text: report.location_description || report.title,
      severity: report.category_id === 4 ? 'high' : 'medium',
      radius_meters: 150,
      is_active: true,
      verified_by_user_id: verifierUser ? verifierUser.id : 5,
      start_time: report.created_at,
    });

    return newIncident;
  }

  // Travel Alerts
  getTravelAlerts({ alertType, severity, status = 'active', routeId }) {
    let list = [...this.travelAlerts];

    if (status && status.toLowerCase() !== 'all') {
      list = list.filter((a) => a.status.toLowerCase() === status.toLowerCase());
    }

    if (alertType && alertType.toLowerCase() !== 'all') {
      list = list.filter((a) => a.alert_type.toLowerCase() === alertType.toLowerCase());
    }

    if (severity && severity.toLowerCase() !== 'all') {
      list = list.filter((a) => a.severity.toLowerCase() === severity.toLowerCase());
    }

    if (routeId) {
      list = list.filter((a) => Number(a.target_route_id) === Number(routeId));
    }

    return list.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  getTravelAlertById(id) {
    return this.travelAlerts.find((a) => a.id === Number(id));
  }

  createTravelAlert(data) {
    const newAlert = {
      id: this.nextAlertId++,
      title: data.title,
      message: data.message,
      alert_type: data.alert_type || 'transport_disruption',
      severity: data.severity || 'info',
      related_incident_id: data.related_incident_id ? Number(data.related_incident_id) : null,
      target_route_id: data.target_route_id ? Number(data.target_route_id) : null,
      target_route_number: data.target_route_number || null,
      target_latitude: data.target_latitude ? Number(data.target_latitude) : null,
      target_longitude: data.target_longitude ? Number(data.target_longitude) : null,
      target_radius_km: data.target_radius_km ? Number(data.target_radius_km) : null,
      status: 'active',
      created_by: data.created_by ? Number(data.created_by) : 5,
      created_at: new Date().toISOString(),
      expires_at: data.expires_at || new Date(Date.now() + 4 * 60 * 60 * 1000).toISOString(),
    };
    this.travelAlerts.unshift(newAlert);
    return newAlert;
  }

  // Alert Subscriptions & Push Notifications
  getUserAlertSubscriptions(userId) {
    return this.alertSubscriptions.filter((s) => s.user_id === Number(userId));
  }

  saveUserAlertSubscription(userId, data) {
    const routeId = data.routeId !== undefined ? (data.routeId ? Number(data.routeId) : null) : (data.route_id ? Number(data.route_id) : null);
    const subType = data.subscriptionType || data.subscription_type || 'route';
    const centerLat = data.centerLatitude !== undefined ? Number(data.centerLatitude) : (data.center_latitude !== undefined ? Number(data.center_latitude) : null);
    const centerLon = data.centerLongitude !== undefined ? Number(data.centerLongitude) : (data.center_longitude !== undefined ? Number(data.center_longitude) : null);
    const radiusKm = data.radiusKm !== undefined ? Number(data.radiusKm) : (data.radius_km !== undefined ? Number(data.radius_km) : null);
    const isActive = data.isActive !== undefined ? Boolean(data.isActive) : (data.is_active !== undefined ? Boolean(data.is_active) : true);

    let existing = this.alertSubscriptions.find(
      (s) => s.user_id === Number(userId) && s.subscription_type === subType && s.route_id === routeId
    );

    if (existing) {
      Object.assign(existing, {
        center_latitude: centerLat !== null ? centerLat : existing.center_latitude,
        center_longitude: centerLon !== null ? centerLon : existing.center_longitude,
        radius_km: radiusKm !== null ? radiusKm : existing.radius_km,
        is_active: isActive,
      });
      return existing;
    } else {
      const newSub = {
        id: this.nextSubId++,
        user_id: Number(userId),
        subscription_type: subType,
        route_id: routeId,
        center_latitude: centerLat,
        center_longitude: centerLon,
        radius_km: radiusKm,
        is_active: isActive,
        created_at: new Date().toISOString(),
      };
      this.alertSubscriptions.push(newSub);
      return newSub;
    }
  }

  saveDeviceToken({ userId, token, platform = 'android' }) {
    let existing = this.deviceTokens.find((t) => t.token === token);
    if (existing) {
      existing.user_id = Number(userId);
      existing.platform = platform;
      existing.updated_at = new Date().toISOString();
      return existing;
    }
    const record = {
      id: this.nextTokenId++,
      user_id: Number(userId),
      token,
      platform,
      created_at: new Date().toISOString(),
    };
    this.deviceTokens.push(record);
    return record;
  }

  recordAlertDelivery({ alertId, userId, deviceTokenId, deliveryStatus = 'sent', fcmMessageId }) {
    const delivery = {
      id: this.nextDeliveryId++,
      alert_id: Number(alertId),
      user_id: Number(userId),
      device_token_id: deviceTokenId ? Number(deviceTokenId) : null,
      delivery_status: deliveryStatus,
      fcm_message_id: fcmMessageId || `fcm_mock_${Date.now()}`,
      delivered_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
    };
    this.alertDeliveries.push(delivery);
    return delivery;
  }

  getAlertDeliveries({ alertId, userId }) {
    return this.alertDeliveries.filter((d) => {
      if (alertId && Number(d.alert_id) !== Number(alertId)) return false;
      if (userId && Number(d.user_id) !== Number(userId)) return false;
      return true;
    });
  }

  // ---------------------------------------------------------------------------
  // Reset store for unit tests
  // ---------------------------------------------------------------------------
  reset() {
    this.users = JSON.parse(JSON.stringify(initialUsersSeed));
    this.routes = JSON.parse(JSON.stringify(initialRoutesSeed));
    this.stops = JSON.parse(JSON.stringify(initialStopsSeed));
    this.schedules = JSON.parse(JSON.stringify(initialSchedulesSeed));
    this.journeys = JSON.parse(JSON.stringify(initialJourneysSeed));
    this.reports = JSON.parse(JSON.stringify(initialReportsSeed));
    this.userReputations = JSON.parse(JSON.stringify(initialUserReputationsSeed));
    this.reportVotes = JSON.parse(JSON.stringify(initialReportVotesSeed));
    this.crowdEstimates = JSON.parse(JSON.stringify(initialCrowdEstimatesSeed));
    this.crowdAggregations = JSON.parse(JSON.stringify(initialCrowdAggregationsSeed));
    this.roadIncidents = JSON.parse(JSON.stringify(initialRoadIncidentsSeed));
    this.travelAlerts = JSON.parse(JSON.stringify(initialTravelAlertsSeed));
    this.alertSubscriptions = JSON.parse(JSON.stringify(initialAlertSubscriptionsSeed));
    this.alertDeliveries = JSON.parse(JSON.stringify(initialAlertDeliveriesSeed));
    this.deviceTokens = [];
    this.nextUserId = 6;
    this.nextJourneyId = 503;
    this.nextReportId = 104;
    this.nextVoteId = 10;
    this.nextEstimateId = 10;
    this.nextAggregationId = 6;
    this.nextIncidentId = 405;
    this.nextAlertId = 304;
    this.nextSubId = 4;
    this.nextDeliveryId = 3;
    this.nextTokenId = 1;
  }
}

const memoryStore = new MemoryStore();

// Live MySQL 8.0+ Connection Pool (Optional — Activated when DB_HOST is set)
let pool = null;

if (process.env.DB_HOST) {
  try {
    const mysql = require('mysql2/promise');
    pool = mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT) || 3306,
      user: process.env.DB_USER || 'travelpulse',
      password: process.env.DB_PASSWORD || 'travelpulse_pass',
      database: process.env.DB_NAME || 'travelpulse_lk',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      enableKeepAlive: true,
      keepAliveInitialDelay: 0,
    });
    console.log(`[DB] MySQL pool initialized: ${process.env.DB_HOST}:${process.env.DB_PORT || 3306}/${process.env.DB_NAME || 'travelpulse_lk'}`);
  } catch (err) {
    console.warn(`[DB] mysql2 driver not available or failed to connect (${err.message}). Using MemoryStore.`);
  }
}

module.exports = {
  memoryStore,
  pool,
  isLiveDb: Boolean(pool),
  getPool: () => pool,
};
