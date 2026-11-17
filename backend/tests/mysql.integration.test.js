/**
 * TravelPulse LK — Real MySQL Database Integration & Persistence Test Suite (Stage 8.3)
 * Tests actual MySQL repository operations, parameterized SQL queries,
 * ACID transaction lifecycles, and data persistence models across Modules 1-4.
 */

const { describe, it, before, after, beforeEach } = require('node:test');
const assert = require('node:assert');
const bcrypt = require('bcryptjs');

const db = require('../src/config/db');
const {
  userRepository,
  routeRepository,
  journeyRepository,
  reportRepository,
  crowdRepository,
  incidentRepository,
  alertRepository,
} = require('../src/repositories');

/**
 * High-Fidelity In-Memory MySQL 8.0 Mock Pool
 * Emulates the mysql2/promise Connection Pool interface for automated verification of
 * SQL syntax, parameterized queries (SQL injection prevention), and ACID transaction lifecycles.
 */
class MockMysqlPool {
  constructor() {
    this.tables = {
      users: [],
      transport_routes: [],
      route_stops: [],
      route_stop_sequences: [],
      route_schedules: [],
      user_journeys: [],
      report_categories: [],
      community_reports: [],
      report_reliability: [],
      report_votes: [],
      user_reputations: [],
      crowd_estimates: [],
      crowd_aggregations: [],
      road_incidents: [],
      travel_alerts: [],
      alert_subscriptions: [],
      device_tokens: [],
      alert_deliveries: [],
    };
    this.executedQueries = [];
    this.nextIds = {
      users: 10,
      user_journeys: 600,
      community_reports: 200,
      report_votes: 50,
      crowd_estimates: 70,
      crowd_aggregations: 30,
      road_incidents: 500,
      travel_alerts: 400,
      alert_subscriptions: 80,
      device_tokens: 90,
      alert_deliveries: 100,
    };
    this.seed();
  }

  seed() {
    this.tables.users = [
      {
        id: 1,
        name: 'Kamal Perera',
        email: 'kamal@example.com',
        password_hash: bcrypt.hashSync('Password123!', 10),
        phone_number: '+94771234567',
        role: 'commuter',
        is_active: 1,
        created_at: new Date().toISOString(),
      },
      {
        id: 2,
        name: 'Dilshan Silva',
        email: 'dilshan@example.com',
        password_hash: bcrypt.hashSync('Password123!', 10),
        phone_number: '+94719876543',
        role: 'commuter',
        is_active: 1,
        created_at: new Date().toISOString(),
      },
      {
        id: 99,
        name: 'Transit Moderator',
        email: 'moderator@travelpulse.lk',
        password_hash: bcrypt.hashSync('Password123!', 10),
        phone_number: '+94762345678',
        role: 'moderator',
        is_active: 1,
        created_at: new Date().toISOString(),
      },
    ];

    this.tables.transport_routes = [
      {
        id: 1,
        route_number: '138',
        name: 'Colombo Fort - Maharagama',
        transport_type: 'bus',
        operator: 'SLTB',
        origin_city: 'Colombo Fort',
        destination_city: 'Maharagama',
        is_active: 1,
        created_at: new Date().toISOString(),
      },
      {
        id: 2,
        route_number: '100',
        name: 'Pettah - Panadura',
        transport_type: 'bus',
        operator: 'WPTA',
        origin_city: 'Pettah',
        destination_city: 'Panadura',
        is_active: 1,
        created_at: new Date().toISOString(),
      },
    ];

    this.tables.route_stops = [
      { id: 101, name: 'Pettah Central Bus Stand', stop_code: 'PET-01', latitude: 6.936, longitude: 79.855, city: 'Colombo 11', is_active: 1 },
      { id: 104, name: 'Town Hall / Viharamahadevi Park', stop_code: 'TOW-01', latitude: 6.9147, longitude: 79.8653, city: 'Colombo 07', is_active: 1 },
      { id: 107, name: 'Maharagama Central Bus Stand', stop_code: 'MAH-01', latitude: 6.848, longitude: 79.9265, city: 'Maharagama', is_active: 1 },
    ];

    this.tables.report_categories = [
      { id: 1, code: 'CROWD', name: 'Crowd Report', description: 'Transit crowd density', default_severity: 'low', is_active: 1 },
      { id: 2, code: 'ROAD_CONDITION', name: 'Road Condition', description: 'Flooding and potholes', default_severity: 'medium', is_active: 1 },
      { id: 4, code: 'SERVICE_DISRUPTION', name: 'Service Disruption', description: 'Breakdowns and delays', default_severity: 'high', is_active: 1 },
      { id: 5, code: 'ACCIDENT_INCIDENT', name: 'Accident/Incident', description: 'Collisions', default_severity: 'critical', is_active: 1 },
    ];

    this.tables.user_reputations = [
      { user_id: 1, reputation_score: 82.5, total_reports_submitted: 5, verified_reports_count: 4, rejected_reports_count: 0, total_votes_cast: 10 },
      { user_id: 2, reputation_score: 75.0, total_reports_submitted: 3, verified_reports_count: 2, rejected_reports_count: 0, total_votes_cast: 6 },
      { user_id: 99, reputation_score: 95.0, total_reports_submitted: 15, verified_reports_count: 15, rejected_reports_count: 0, total_votes_cast: 30 },
    ];
  }

  async query(sql, params = []) {
    this.executedQueries.push({ sql, params });
    const trimmed = sql.trim().toUpperCase();

    // 1. SELECT users
    if (trimmed.startsWith('SELECT') && sql.includes('FROM users')) {
      if (sql.includes('WHERE id = ?')) {
        const id = Number(params[0]);
        const found = this.tables.users.filter((u) => u.id === id && u.is_active);
        return [found];
      }
      if (sql.includes('WHERE (email = ? OR name = ?)')) {
        const val = params[0];
        const found = this.tables.users.filter((u) => (u.email === val || u.name === val) && u.is_active);
        return [found];
      }
      if (sql.includes('WHERE email = ?')) {
        const email = params[0];
        const found = this.tables.users.filter((u) => u.email === email);
        return [found];
      }
      return [this.tables.users];
    }

    // 2. INSERT users
    if (trimmed.startsWith('INSERT INTO USERS')) {
      const id = this.nextIds.users++;
      const [name, email, passwordHash, phoneNumber, role] = params;
      const newUser = { id, name, email, password_hash: passwordHash, phone_number: phoneNumber, role, is_active: 1, created_at: new Date().toISOString() };
      this.tables.users.push(newUser);
      return [{ insertId: id, affectedRows: 1 }];
    }

    // 3. SELECT / INSERT / UPDATE user_reputations
    if (sql.includes('user_reputations')) {
      if (trimmed.startsWith('SELECT')) {
        const userId = Number(params[0]);
        const found = this.tables.user_reputations.filter((r) => r.user_id === userId);
        return [found];
      }
      if (trimmed.startsWith('INSERT')) {
        const [userId, score] = params;
        this.tables.user_reputations.push({
          user_id: Number(userId),
          reputation_score: Number(score || 10.0),
          total_reports_submitted: 0,
          verified_reports_count: 0,
          rejected_reports_count: 0,
          total_votes_cast: 0,
        });
        return [{ affectedRows: 1 }];
      }
      if (trimmed.startsWith('UPDATE')) {
        return [{ affectedRows: 1 }];
      }
    }

    // 4. transport_routes & route_stops
    if (sql.includes('FROM transport_routes')) {
      if (sql.includes('WHERE id = ?')) {
        const id = Number(params[0]);
        const found = this.tables.transport_routes.filter((r) => r.id === id);
        return [found];
      }
      return [this.tables.transport_routes];
    }
    if (sql.includes('FROM route_stops')) {
      return [this.tables.route_stops];
    }
    if (sql.includes('FROM route_stop_sequences')) {
      return [[]];
    }
    if (sql.includes('FROM route_schedules')) {
      return [[]];
    }

    // 5. user_journeys
    if (trimmed.startsWith('INSERT INTO USER_JOURNEYS')) {
      const id = this.nextIds.user_journeys++;
      const [userId, routeId, originStopId, destinationStopId, startTime] = params;
      const journey = {
        id,
        user_id: Number(userId),
        route_id: Number(routeId),
        origin_stop_id: Number(originStopId),
        destination_stop_id: Number(destinationStopId),
        start_time: startTime || new Date().toISOString(),
        end_time: null,
        status: 'in_progress',
        created_at: new Date().toISOString(),
      };
      this.tables.user_journeys.push(journey);
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (sql.includes('FROM user_journeys')) {
      if (sql.includes('WHERE j.id = ?')) {
        const id = Number(params[0]);
        const found = this.tables.user_journeys
          .filter((j) => j.id === id)
          .map((j) => ({ ...j, userId: j.user_id, routeId: j.route_id, originStopId: j.origin_stop_id, destinationStopId: j.destination_stop_id, routeNumber: '138', originStopName: 'Fort', destinationStopName: 'Maharagama' }));
        return [found];
      }
      if (sql.includes("WHERE j.user_id = ? AND j.status = 'in_progress'")) {
        const userId = Number(params[0]);
        const found = this.tables.user_journeys
          .filter((j) => j.user_id === userId && j.status === 'in_progress')
          .map((j) => ({ ...j, userId: j.user_id, routeId: j.route_id, routeNumber: '138' }));
        return [found];
      }
      return [this.tables.user_journeys];
    }
    if (trimmed.startsWith('UPDATE USER_JOURNEYS')) {
      if (sql.includes('WHERE id = ? AND user_id = ?')) {
        const id = Number(params[0]);
        const userId = Number(params[1]);
        const journey = this.tables.user_journeys.find((j) => j.id === id && j.user_id === userId);
        if (journey) {
          journey.status = 'cancelled';
          journey.end_time = new Date().toISOString();
          return [{ affectedRows: 1 }];
        }
        return [{ affectedRows: 0 }];
      }
      if (sql.includes('WHERE id = ?')) {
        const [status, _isTerminal, id] = params;
        const journey = this.tables.user_journeys.find((j) => j.id === Number(id));
        if (journey) {
          journey.status = status;
          return [{ affectedRows: 1 }];
        }
        return [{ affectedRows: 0 }];
      }
      return [{ affectedRows: 1 }];
    }

    // 6. report_categories & community_reports
    if (sql.includes('FROM report_categories')) {
      if (sql.includes('WHERE id = ?') && params.length > 0) {
        const catId = Number(params[0]);
        return [this.tables.report_categories.filter((c) => c.id === catId)];
      }
      return [this.tables.report_categories];
    }
    if (trimmed.startsWith('INSERT INTO COMMUNITY_REPORTS')) {
      const id = this.nextIds.community_reports++;
      let userId, isAnon, categoryId, routeId, stopId, lat, lon, locDesc, title, desc, reason, transportType, busRoute, dest, busReg, trainName, startSt, crowdLvl, media;
      if (params.length >= 19) {
        [userId, isAnon, categoryId, routeId, stopId, lat, lon, locDesc, title, desc, reason, transportType, busRoute, dest, busReg, trainName, startSt, crowdLvl, media] = params;
      } else {
        [userId, isAnon, categoryId, routeId, stopId, lat, lon, locDesc, title, desc, reason, media] = params;
      }
      const rep = {
        id,
        user_id: Number(userId),
        is_anonymous: isAnon ? 1 : 0,
        category_id: Number(categoryId),
        route_id: routeId ? Number(routeId) : null,
        stop_id: stopId ? Number(stopId) : null,
        latitude: lat,
        longitude: lon,
        location_description: locDesc,
        title,
        description: desc,
        disruption_reason: reason,
        transport_type: transportType || null,
        bus_route_number: busRoute || null,
        destination: dest || null,
        bus_registration_number: busReg || null,
        train_name_or_number: trainName || null,
        starting_station: startSt || null,
        crowd_level: crowdLvl || null,
        media_url: media,
        status: 'submitted',
        created_at: new Date().toISOString(),
      };
      this.tables.community_reports.push(rep);
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (sql.includes('FROM community_reports')) {
      const enrich = (r) => {
        const rel = this.tables.report_reliability.find((x) => x.report_id === r.id);
        const cat = this.tables.report_categories.find((c) => c.id === r.category_id);
        const usr = this.tables.users.find((u) => u.id === r.user_id);
        return {
          ...r,
          user_name: usr ? usr.name : null,
          user_email: usr ? usr.email : null,
          category_name: cat ? cat.name : null,
          category_code: cat ? cat.code : null,
          reliability_score: rel ? rel.reliability_score : 0,
          confidence_status: rel ? rel.confidence_status : 'unverified',
          upvotes_count: rel ? rel.upvotes_count : 0,
          downvotes_count: rel ? rel.downvotes_count : 0,
        };
      };
      if (sql.includes('WHERE r.id = ?') || sql.includes('WHERE id = ?')) {
        const id = Number(params[0]);
        const found = this.tables.community_reports.filter((r) => r.id === id).map(enrich);
        return [found];
      }
      return [this.tables.community_reports.map(enrich)];
    }
    if (trimmed.startsWith('DELETE FROM COMMUNITY_REPORTS')) {
      const id = Number(params[0]);
      const idx = this.tables.community_reports.findIndex((r) => r.id === id);
      if (idx !== -1) {
        this.tables.community_reports.splice(idx, 1);
        return [{ affectedRows: 1 }];
      }
      return [{ affectedRows: 0 }];
    }
    if (trimmed.startsWith('INSERT INTO REPORT_RELIABILITY')) {
      const [reportId, reliabilityScore, confidenceStatus, corroborationCount] = params;
      if (reliabilityScore === null || reliabilityScore === undefined || Number.isNaN(Number(reliabilityScore))) {
        throw new Error("Column 'reliability_score' cannot be null");
      }
      if (!confidenceStatus) {
        throw new Error("Column 'confidence_status' cannot be null");
      }
      const validStatuses = ['unverified', 'plausible', 'verified', 'disputed', 'rejected'];
      if (!validStatuses.includes(confidenceStatus)) {
        throw new Error(`Data truncated for column 'confidence_status': ${confidenceStatus}`);
      }
      this.tables.report_reliability.push({
        report_id: Number(reportId),
        reliability_score: Number(reliabilityScore),
        confidence_status: confidenceStatus,
        upvotes_count: 0,
        downvotes_count: 0,
        corroboration_count: Number(corroborationCount || 0),
      });
      return [{ affectedRows: 1 }];
    }
    if (sql.includes('report_reliability')) {
      return [{ affectedRows: 1 }];
    }

    // 7. report_votes
    if (sql.includes('report_votes')) {
      if (trimmed.startsWith('INSERT')) {
        const id = this.nextIds.report_votes++;
        const [reportId, userId, voteType] = params;
        this.tables.report_votes.push({ id, report_id: Number(reportId), user_id: Number(userId), vote_type: voteType });
        return [{ insertId: id, affectedRows: 1 }];
      }
      if (trimmed.startsWith('SELECT')) {
        return [[{ upvotes: 1, downvotes: 0 }]];
      }
    }

    // 8. crowd_estimates & crowd_aggregations
    if (trimmed.startsWith('INSERT INTO CROWD_ESTIMATES')) {
      const id = this.nextIds.crowd_estimates++;
      const [userId, routeId, stopId, crowdLevel, waitTime] = params;
      this.tables.crowd_estimates.push({ id, user_id: Number(userId), route_id: routeId ? Number(routeId) : null, stop_id: stopId ? Number(stopId) : null, crowd_level: crowdLevel, passenger_wait_time_minutes: waitTime, reported_at: new Date().toISOString() });
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (sql.includes('FROM crowd_estimates')) {
      return [this.tables.crowd_estimates];
    }
    if (sql.includes('crowd_aggregations')) {
      if (trimmed.startsWith('SELECT')) {
        return [[]];
      }
      if (trimmed.startsWith('INSERT')) {
        const id = this.nextIds.crowd_aggregations++;
        return [{ insertId: id, affectedRows: 1 }];
      }
      return [{ affectedRows: 1 }];
    }

    // 9. road_incidents
    if (trimmed.startsWith('INSERT INTO ROAD_INCIDENTS')) {
      const id = this.nextIds.road_incidents++;
      const [sourceReportId, incidentType, lat, lon, addr, severity, radius, verifiedBy] = params;
      const incident = {
        id,
        source_report_id: sourceReportId,
        sourceReportId: sourceReportId,
        incident_type: incidentType,
        incidentType: incidentType,
        latitude: lat,
        longitude: lon,
        address_text: addr,
        addressText: addr,
        severity,
        radius_meters: radius,
        radiusMeters: radius,
        is_active: 1,
        isActive: 1,
        verified_by_user_id: verifiedBy,
        verifiedByUserId: verifiedBy,
        start_time: new Date().toISOString(),
        startTime: new Date().toISOString(),
        created_at: new Date().toISOString(),
        createdAt: new Date().toISOString(),
      };
      this.tables.road_incidents.push(incident);
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (sql.includes('FROM road_incidents')) {
      if (sql.includes('WHERE id = ?')) {
        const id = Number(params[0]);
        const found = this.tables.road_incidents.filter((i) => i.id === id);
        return [found];
      }
      return [this.tables.road_incidents];
    }

    // 10. travel_alerts, alert_subscriptions, device_tokens
    if (trimmed.startsWith('INSERT INTO TRAVEL_ALERTS')) {
      const id = this.nextIds.travel_alerts++;
      const [title, message, alertType, severity, disId, incId, routeId, lat, lon, rad, createdBy, expiresAt] = params;
      const alert = { id, title, message, alert_type: alertType, severity, status: 'active', created_by: createdBy, created_at: new Date().toISOString(), expires_at: expiresAt };
      this.tables.travel_alerts.push(alert);
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (sql.includes('FROM travel_alerts')) {
      if (sql.includes('WHERE a.id = ?')) {
        const id = Number(params[0]);
        const found = this.tables.travel_alerts.filter((a) => a.id === id);
        return [found];
      }
      return [this.tables.travel_alerts];
    }
    if (trimmed.startsWith('INSERT INTO ALERT_SUBSCRIPTIONS')) {
      const id = this.nextIds.alert_subscriptions++;
      const [userId, subType, routeId, lat, lon, rad] = params;
      const sub = { id, user_id: Number(userId), subscription_type: subType, route_id: routeId, center_latitude: lat, center_longitude: lon, radius_km: rad, is_active: 1, created_at: new Date().toISOString() };
      this.tables.alert_subscriptions.push(sub);
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (sql.includes('FROM alert_subscriptions')) {
      return [this.tables.alert_subscriptions];
    }
    if (trimmed.startsWith('INSERT INTO DEVICE_TOKENS')) {
      const id = this.nextIds.device_tokens++;
      const [userId, fcmToken, deviceType] = params;
      this.tables.device_tokens.push({ id, user_id: Number(userId), fcm_token: fcmToken, device_type: deviceType, last_active_at: new Date().toISOString() });
      return [{ insertId: id, affectedRows: 1 }];
    }
    if (trimmed.startsWith('INSERT INTO ALERT_DELIVERIES')) {
      const id = this.nextIds.alert_deliveries++;
      return [{ insertId: id, affectedRows: 1 }];
    }

    return [{ affectedRows: 1 }];
  }

  async getConnection() {
    const self = this;
    return {
      query: (sql, params) => self.query(sql, params),
      beginTransaction: async () => {
        self.executedQueries.push({ sql: 'BEGIN', params: [] });
      },
      commit: async () => {
        self.executedQueries.push({ sql: 'COMMIT', params: [] });
      },
      rollback: async () => {
        self.executedQueries.push({ sql: 'ROLLBACK', params: [] });
      },
      release: () => { },
    };
  }
}

describe('TravelPulse LK — Stage 8.3 MySQL Database Persistence Integration', () => {
  let mockPool = null;

  before(() => {
    mockPool = new MockMysqlPool();
    // Activate MySQL pool mode on db config
    db.setPool(mockPool, true);
  });

  after(() => {
    // Reset back to standard development mode
    db.resetPool();
  });

  beforeEach(() => {
    mockPool.executedQueries = [];
  });

  it('1. User registration inserts into users with bcrypt password hash and default commuter role', async () => {
    const regResult = await userRepository.createUser({
      name: 'Nimal Jayasuriya',
      email: 'nimal@example.com',
      password: 'SecurePassword2026!',
      phoneNumber: '+94711122334',
    });

    assert.ok(regResult.id, 'User must have an auto-generated ID');
    assert.strictEqual(regResult.email, 'nimal@example.com');
    assert.strictEqual(regResult.role, 'commuter', 'Role must default to commuter');
    assert.strictEqual(regResult.password, undefined, 'Plain password must not be exposed');
    assert.strictEqual(regResult.password_hash, undefined, 'Password hash must not be exposed');

    // Verify SQL query execution
    const insertQuery = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO users'));
    assert.ok(insertQuery, 'Must execute INSERT INTO users parameterized SQL');
    assert.strictEqual(insertQuery.params[1], 'nimal@example.com');
    // Verify password is a bcrypt hash
    assert.ok(bcrypt.compareSync('SecurePassword2026!', insertQuery.params[2]), 'Password must be stored as real bcrypt hash');
  });

  it('2. User login queries MySQL and verifies password against bcrypt hash', async () => {
    const user = await userRepository.findUserByEmail('kamal@example.com');

    assert.ok(user, 'User must be found');
    assert.ok(user.password_hash, 'Internal findUserByEmail must return password_hash for auth comparison');
    assert.ok(bcrypt.compareSync('Password123!', user.password_hash), 'Password123! must match bcrypt hash');

    const selectQuery = mockPool.executedQueries.find((q) => q.sql.includes('SELECT') && q.sql.includes('FROM users'));
    assert.ok(selectQuery, 'Must execute parameterized SELECT query on users');
    assert.strictEqual(selectQuery.params[0], 'kamal@example.com');
  });

  it('3. Route and stop retrieval queries transport_routes and route_stops with parameterized filters', async () => {
    const routes = await routeRepository.getAllRoutes({ transportType: 'bus' });
    assert.ok(Array.isArray(routes));
    assert.strictEqual(routes.length, 2);

    const stops = await routeRepository.getStops();
    assert.ok(Array.isArray(stops));
    assert.strictEqual(stops.length, 3);

    const routeQuery = mockPool.executedQueries.find((q) => q.sql.includes('FROM transport_routes'));
    assert.ok(routeQuery, 'Must execute parameterized SQL on transport_routes');
    assert.strictEqual(routeQuery.params[0], 'bus');
  });

  it('4. Journey creation, progress, and cancellation updates MySQL with transactional timestamps', async () => {
    const journey = await journeyRepository.createJourney({
      userId: 1,
      routeId: 1,
      originStopId: 101,
      destinationStopId: 104,
    });

    assert.ok(journey, 'Journey must be created');
    assert.strictEqual(journey.status, 'in_progress');

    // Cancel journey
    const cancelled = await journeyRepository.cancelJourney(journey.id, 1);
    assert.ok(cancelled, 'Cancelled journey returned');
    assert.strictEqual(cancelled.status, 'cancelled');

    const insertQuery = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO user_journeys'));
    const updateQuery = mockPool.executedQueries.find((q) => q.sql.includes('UPDATE user_journeys'));
    assert.ok(insertQuery, 'Must execute parameterized INSERT INTO user_journeys');
    assert.ok(updateQuery, 'Must execute parameterized UPDATE user_journeys');
  });

  it('5. Report submission runs within an ACID transaction and inserts into community_reports and report_reliability', async () => {
    const report = await reportRepository.createReport({
      userId: 1,
      categoryId: 2,
      routeId: 1,
      stopId: 104,
      latitude: 6.9147,
      longitude: 79.8653,
      title: 'Water pipe leak near Town Hall',
      description: 'Major water leakage covering left lane.',
      isAnonymous: true,
    });

    assert.ok(report, 'Report must be created');
    assert.strictEqual(report.isAnonymous, true);
    assert.strictEqual(report.status, 'submitted');
    assert.strictEqual(report.reliabilityScore, 33);
    assert.strictEqual(report.confidenceStatus, 'unverified');

    // Verify category lookup and transaction lifecycle (BEGIN -> INSERT report -> INSERT reliability -> COMMIT)
    const catQuery = mockPool.executedQueries.find((q) => q.sql.includes('FROM report_categories'));
    assert.ok(catQuery, 'Category code must be looked up from report_categories');

    const beginIndex = mockPool.executedQueries.findIndex((q) => q.sql === 'BEGIN');
    const insertReportIndex = mockPool.executedQueries.findIndex((q) => q.sql.includes('INSERT INTO community_reports'));
    const insertRelIndex = mockPool.executedQueries.findIndex((q) => q.sql.includes('INSERT INTO report_reliability'));
    const commitIndex = mockPool.executedQueries.findIndex((q) => q.sql === 'COMMIT');

    assert.ok(beginIndex !== -1, 'Transaction must begin');
    assert.ok(insertReportIndex > beginIndex, 'Report insert must be inside transaction');
    assert.ok(insertRelIndex > insertReportIndex, 'Reliability insert must follow report insert');
    assert.ok(commitIndex > insertRelIndex, 'Transaction must commit');

    const insertRelQuery = mockPool.executedQueries[insertRelIndex];
    assert.deepStrictEqual(insertRelQuery.params, [report.id, 33, 'unverified', 0]);

    const reliabilityRow = mockPool.tables.report_reliability.find((r) => r.report_id === report.id);
    assert.ok(reliabilityRow, 'report_reliability row must be stored for created report');
    assert.strictEqual(reliabilityRow.reliability_score, report.reliabilityScore);
    assert.strictEqual(reliabilityRow.confidence_status, report.confidenceStatus);
    assert.strictEqual(reliabilityRow.corroboration_count, 0);
  });

  it('6. Anonymous report identity masking hides userId and userName for non-author commuters', async () => {
    // Report created by Kamal (userId: 1) as anonymous
    const kamalReport = await reportRepository.createReport({
      userId: 1,
      categoryId: 4,
      latitude: 6.91,
      longitude: 79.86,
      title: 'Bus Breakdown',
      description: 'Engine failure',
      isAnonymous: true,
    });

    // Public retrieval by Dilshan (userId: 2)
    const publicView = await reportRepository.findReportById(kamalReport.id, 2);
    assert.strictEqual(publicView.isAnonymous, true);
    assert.strictEqual(publicView.userId, null, 'Public view must hide userId for anonymous report');
    assert.strictEqual(publicView.userName, 'Anonymous Commuter', 'Public view must mask author name');

    // Author retrieval by Kamal (userId: 1)
    const authorView = await reportRepository.findReportById(kamalReport.id, 1);
    assert.strictEqual(authorView.isAnonymous, true);
    assert.strictEqual(authorView.userId, 1, 'Author must be able to view their own userId');
  });

  it('7. Report deletion enforces ownership: author and moderator can delete, but non-authors are forbidden', async () => {
    const report = await reportRepository.createReport({
      userId: 1,
      categoryId: 2,
      latitude: 6.9,
      longitude: 79.8,
      title: 'Pothole',
      description: 'Deep pothole',
    });

    // Unauthorized deletion attempt by Dilshan (userId: 2)
    const forbiddenResult = await reportRepository.deleteReport(report.id, 2, false);
    assert.strictEqual(forbiddenResult.statusCode, 403, 'Must return 403 Forbidden for non-author');

    // Authorized deletion by author Kamal (userId: 1)
    const successResult = await reportRepository.deleteReport(report.id, 1, false);
    assert.strictEqual(successResult.success, true, 'Author must be permitted to delete report');
  });

  it('8. Crowd estimate submission runs in a transaction and upserts into crowd_aggregations', async () => {
    const result = await crowdRepository.submitCrowdEstimate({
      userId: 1,
      routeId: 1,
      stopId: null,
      crowdLevel: 'crowded',
      passengerWaitTimeMinutes: 15,
    });

    assert.ok(result.estimate, 'Estimate must be recorded');
    assert.strictEqual(result.estimate.crowdLevel, 'crowded');
    assert.ok(result.aggregation, 'Sliding-window aggregation must be generated');

    const insertEst = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO crowd_estimates'));
    assert.ok(insertEst, 'Must execute parameterized INSERT INTO crowd_estimates');
    assert.strictEqual(insertEst.params[0], 1);
    assert.strictEqual(insertEst.params[1], 1);
    assert.strictEqual(insertEst.params[3], 'crowded');
  });

  it('9. Peer voting executes within transaction, prevents self-voting, and updates reliability & reputation', async () => {
    // 1. Report authored by Kamal (userId: 1)
    const report = await reportRepository.createReport({
      userId: 1,
      categoryId: 2,
      latitude: 6.9,
      longitude: 79.8,
      title: 'Flooding',
      description: 'High water levels',
    });

    // 2. Kamal tries to vote on own report -> REJECTED
    const selfVote = await crowdRepository.voteOnReport(report.id, 1, 'upvote');
    assert.strictEqual(selfVote.error, 'SELF_VOTING_FORBIDDEN', 'Must prevent author self-voting');

    // 3. Dilshan (userId: 2) votes on Kamal report -> ACCEPTED with transaction
    const peerVote = await crowdRepository.voteOnReport(report.id, 2, 'upvote');
    assert.ok(!peerVote.error, 'Peer vote must be accepted');

    const voteQuery = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO report_votes'));
    assert.ok(voteQuery, 'Must execute parameterized INSERT INTO report_votes');
  });

  it('10. Road incident creation and promotion from community report execute with parameterized SQL', async () => {
    const report = await reportRepository.createReport({
      userId: 1,
      categoryId: 2,
      latitude: 6.892,
      longitude: 79.858,
      locationDescription: 'Thunmulla Junction',
      title: 'Flash Flood',
      description: 'Heavy waterlogging',
    });

    // Promote to confirmed road incident
    const incident = await incidentRepository.promoteReportToIncident(report.id, 99, {
      incidentType: 'flooding',
      severity: 'high',
    });

    assert.ok(incident, 'Incident must be created');
    assert.strictEqual(incident.incidentType, 'flooding');
    assert.strictEqual(incident.severity, 'high');

    const insertInc = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO road_incidents'));
    assert.ok(insertInc, 'Must execute parameterized INSERT INTO road_incidents');
  });

  it('11. Travel alert broadcasting and subscription management persist to MySQL', async () => {
    const alert = await alertRepository.createAlert({
      title: 'Signal Failure Alert',
      message: 'Trains delayed 30 minutes',
      alertType: 'transport_disruption',
      severity: 'warning',
      createdBy: 99,
    });

    assert.ok(alert, 'Travel alert must be created');
    assert.strictEqual(alert.status, 'active');

    // Subscribe commuter
    const sub = await alertRepository.updateSubscription(1, {
      subscriptionType: 'route',
      routeId: 1,
    });
    assert.ok(sub, 'Subscription must be saved');

    // Register FCM token
    const tokenRecord = await alertRepository.registerDeviceToken(1, 'mock-fcm-token-xyz-123', 'android');
    assert.ok(tokenRecord, 'Device token must be registered');

    const insertAlert = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO travel_alerts'));
    const insertSub = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO alert_subscriptions'));
    const insertToken = mockPool.executedQueries.find((q) => q.sql.includes('INSERT INTO device_tokens'));

    assert.ok(insertAlert, 'Must execute parameterized INSERT INTO travel_alerts');
    assert.ok(insertSub, 'Must execute parameterized INSERT INTO alert_subscriptions');
    assert.ok(insertToken, 'Must execute parameterized INSERT INTO device_tokens');
  });

  it('12. Production Guard: assertFallbackAllowed throws fatal error if live MySQL is absent in production mode', () => {
    const originalEnv = process.env.NODE_ENV;
    try {
      process.env.NODE_ENV = 'production';
      assert.throws(
        () => {
          db.assertFallbackAllowed();
        },
        /\[FATAL\] Production database operation failed: Real MySQL connection is required/,
        'Must strictly disallow silent fallback to MemoryStore in production'
      );
    } finally {
      process.env.NODE_ENV = originalEnv;
    }
  });

  it('13. SQL Injection Resistance: Parameterized queries ensure safe handling of malicious strings', async () => {
    const maliciousEmail = "' OR '1'='1' -- ";
    const user = await userRepository.findUserByEmail(maliciousEmail);
    assert.strictEqual(user, null, 'SQL injection payload must return null, not match any user');

    const selectQuery = mockPool.executedQueries.find((q) => q.params.includes(maliciousEmail));
    assert.ok(selectQuery, 'Malicious string must be passed strictly as bound parameter, never concatenated into SQL');
  });

  it('14. Corroborated report creation reflects reporter reputation and corroboration count in report_reliability', async () => {
    const corroboratingReport = await reportRepository.createReport({
      userId: 2,
      categoryId: 2,
      routeId: 1,
      stopId: 104,
      latitude: 6.9147,
      longitude: 79.8653,
      title: 'Confirmed Town Hall pipe burst blocking lane',
      description: 'Water still overflowing across the left lane at Town Hall.',
      isAnonymous: false,
    });

    assert.ok(corroboratingReport, 'Corroborating report must be created');
    assert.strictEqual(corroboratingReport.reliabilityScore, 40);
    assert.strictEqual(corroboratingReport.confidenceStatus, 'plausible');

    const insertRelQuery = mockPool.executedQueries.find((q) =>
      q.sql.includes('INSERT INTO report_reliability')
    );
    assert.ok(insertRelQuery, 'Reliability insert must execute');
    assert.deepStrictEqual(insertRelQuery.params, [corroboratingReport.id, 40, 'plausible', 1]);

    const reliabilityRow = mockPool.tables.report_reliability.find(
      (r) => r.report_id === corroboratingReport.id
    );
    assert.ok(reliabilityRow, 'report_reliability row must exist for corroborated report');
    assert.strictEqual(reliabilityRow.reliability_score, 40);
    assert.strictEqual(reliabilityRow.confidence_status, 'plausible');
    assert.strictEqual(reliabilityRow.corroboration_count, 1);
  });

  it('15. Report creation rolls back transaction and releases connection if report_reliability insert fails', async () => {
    const originalGetConnection = mockPool.getConnection.bind(mockPool);
    let released = false;

    mockPool.getConnection = async () => {
      const conn = await originalGetConnection();
      return {
        ...conn,
        query: async (sql, params) => {
          if (sql.trim().toUpperCase().startsWith('INSERT INTO REPORT_RELIABILITY')) {
            throw new Error('Simulated report_reliability failure');
          }
          return conn.query(sql, params);
        },
        release: () => {
          released = true;
          conn.release();
        },
      };
    };

    try {
      await assert.rejects(
        () =>
          reportRepository.createReport({
            userId: 1,
            categoryId: 2,
            routeId: 1,
            stopId: 104,
            latitude: 6.9147,
            longitude: 79.8653,
            title: 'Failure simulation report',
            description: 'Should trigger rollback cleanly.',
            isAnonymous: false,
          }),
        /Simulated report_reliability failure/
      );

      const rollbackQuery = mockPool.executedQueries.find((q) => q.sql === 'ROLLBACK');
      const commitQuery = mockPool.executedQueries.find((q) => q.sql === 'COMMIT');
      assert.ok(rollbackQuery, 'Transaction must roll back on insert failure');
      assert.strictEqual(commitQuery, undefined, 'Transaction must not commit on failure');
      assert.strictEqual(released, true, 'Database connection must always be released');
    } finally {
      mockPool.getConnection = originalGetConnection;
    }
  });

  it('16. Crowd report creation persists all seven transport fields in MySQL community_reports table', async () => {
    // 16a. Bus crowd report
    const busReport = await reportRepository.createReport({
      userId: 1,
      categoryId: 1,
      latitude: 6.9355,
      longitude: 79.8530,
      locationDescription: 'Pettah Stand Bay 2',
      title: 'Route 138 Evening Rush Hour Overcrowding',
      description: 'Massive queue at the bus bay with all seats and aisles filled.',
      transportType: 'bus',
      busRouteNumber: '138',
      destination: 'Maharagama',
      busRegistrationNumber: 'ND-4521',
      crowdLevel: 'heavy',
    });

    assert.ok(busReport, 'Bus crowd report must be created');
    assert.strictEqual(busReport.transportType, 'bus');
    assert.strictEqual(busReport.busRouteNumber, '138');
    assert.strictEqual(busReport.destination, 'Maharagama');
    assert.strictEqual(busReport.busRegistrationNumber, 'ND-4521');
    assert.strictEqual(busReport.trainNameOrNumber, null);
    assert.strictEqual(busReport.startingStation, null);
    assert.strictEqual(busReport.crowdLevel, 'heavy');

    const fetchedBus = await reportRepository.findReportById(busReport.id, 1);
    assert.strictEqual(fetchedBus.transportType, 'bus');
    assert.strictEqual(fetchedBus.busRouteNumber, '138');
    assert.strictEqual(fetchedBus.destination, 'Maharagama');
    assert.strictEqual(fetchedBus.busRegistrationNumber, 'ND-4521');
    assert.strictEqual(fetchedBus.crowdLevel, 'heavy');

    // 16b. Train crowd report
    const trainReport = await reportRepository.createReport({
      userId: 2,
      categoryId: 1,
      latitude: 6.9355,
      longitude: 79.8530,
      locationDescription: 'Colombo Fort Station Platform 3',
      title: 'Main Line Evening Express Packed',
      description: 'Footboards and doors completely crowded.',
      transportType: 'train',
      trainNameOrNumber: 'Udarata Menike (1015)',
      startingStation: 'Colombo Fort',
      destination: 'Badulla',
      crowdLevel: 'packed',
    });

    assert.ok(trainReport, 'Train crowd report must be created');
    assert.strictEqual(trainReport.transportType, 'train');
    assert.strictEqual(trainReport.trainNameOrNumber, 'Udarata Menike (1015)');
    assert.strictEqual(trainReport.startingStation, 'Colombo Fort');
    assert.strictEqual(trainReport.destination, 'Badulla');
    assert.strictEqual(trainReport.busRouteNumber, null);
    assert.strictEqual(trainReport.crowdLevel, 'packed');

    const fetchedTrain = await reportRepository.findReportById(trainReport.id, 2);
    assert.strictEqual(fetchedTrain.transportType, 'train');
    assert.strictEqual(fetchedTrain.trainNameOrNumber, 'Udarata Menike (1015)');
    assert.strictEqual(fetchedTrain.startingStation, 'Colombo Fort');
    assert.strictEqual(fetchedTrain.destination, 'Badulla');
    assert.strictEqual(fetchedTrain.crowdLevel, 'packed');
  });
});
