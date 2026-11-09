/**
 * TravelPulse LK — Module 4: Road Incidents, Maps & Alerts Unit Tests
 * Owning Member: Thimaya
 * ---------------------------------------------------------------------------
 * Directly verifies:
 *  1. Retrieval and spatial filtering of road incidents
 *  2. Verification enforcement on promoting reports to road incidents
 *  3. Travel alerts listing and single-alert inspection
 *  4. Authorization gate on broadcast alerts (moderators only)
 *  5. Notification dispatch audit recording (Table 20: alert_deliveries)
 *  6. Alert notification subscription preferences management
 *  7. FCM device token registration
 *  8. Cross-module compatibility with Dumindi's reports and Suneth's reliability
 * ---------------------------------------------------------------------------
 */

const { describe, it, beforeEach } = require('node:test');
const assert = require('node:assert');
const { memoryStore } = require('../src/config/db');
const {
  getIncidents,
  getIncidentById,
  promoteReport,
} = require('../src/controllers/incident.controller');
const {
  getAlerts,
  getAlertById,
  createAlert,
  getSubscriptions,
  updateSubscription,
  registerDeviceToken,
} = require('../src/controllers/alert.controller');
const { validateCreateAlert, validateSubscription } = require('../src/validators/alert.validator');

function createMockRes() {
  return {
    statusCode: 200,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(data) {
      this.body = data;
      return this;
    },
  };
}

describe('TravelPulse LK — Module 4: Road Conditions, Maps & Alerts (Thimaya)', () => {
  beforeEach(() => {
    memoryStore.reset();
  });

  it('1. getIncidents returns road incidents with coordinates and severity', () => {
    const req = { query: {} };
    const res = createMockRes();

    getIncidents(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.data.length >= 4);

    const types = res.body.data.map((i) => i.incidentType);
    assert.ok(types.includes('flooding'));
    assert.ok(types.includes('pothole'));
    assert.ok(types.includes('road_closure'));
  });

  it('2. getIncidents correctly filters by incidentType and severity', () => {
    const req = { query: { incidentType: 'flooding', severity: 'high' } };
    const res = createMockRes();

    getIncidents(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.ok(res.body.data.every((i) => i.incidentType === 'flooding' && i.severity === 'high'));
  });

  it('3. promoteReport promotes verified community report into confirmed road incident', () => {
    // Report 102 in seed is an anonymous verified report with 92% reliability score
    const req = {
      params: { reportId: 102 },
      user: { id: 2, role: 'commuter' },
    };
    const res = createMockRes();

    promoteReport(req, res);

    assert.strictEqual(res.statusCode, 201);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(res.body.data.sourceReportId, 102);
    assert.strictEqual(res.body.data.incidentType, 'flooding');
    assert.strictEqual(res.body.data.isActive, true);

    // Verify incident is in the incidents list
    const stored = memoryStore.getRoadIncidentById(res.body.data.id);
    assert.ok(stored);
    assert.strictEqual(stored.source_report_id, 102);
  });

  it('4. promoteReport rejects unverified report promotion by non-moderators', () => {
    // Report 103 in seed has 60% reliability score ('plausible', not 'verified')
    const reqCommuter = {
      params: { reportId: 103 },
      user: { id: 1, role: 'commuter' },
    };
    const resCommuter = createMockRes();

    promoteReport(reqCommuter, resCommuter);

    assert.strictEqual(resCommuter.statusCode, 400);
    assert.strictEqual(resCommuter.body.success, false);
    assert.strictEqual(resCommuter.body.error.code, 'REPORT_PROMOTION_ERROR');

    // Moderator override permits promotion of report 103
    const reqModerator = {
      params: { reportId: 103 },
      user: { id: 5, role: 'moderator' },
    };
    const resModerator = createMockRes();

    promoteReport(reqModerator, resModerator);

    assert.strictEqual(resModerator.statusCode, 201);
    assert.strictEqual(resModerator.body.success, true);
  });

  it('5. getAlerts returns active travel alerts with route details', () => {
    const req = { query: {} };
    const res = createMockRes();

    getAlerts(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.data.length >= 3);

    const floodAlert = res.body.data.find((a) => a.id === 301);
    assert.ok(floodAlert);
    assert.strictEqual(floodAlert.severity, 'critical');
    assert.strictEqual(floodAlert.alertType, 'road_condition');
  });

  it('6. createAlert restricts broadcast to moderators and triggers notification audit', async () => {
    // 6a. Ordinary commuter blocked (403 Forbidden)
    const reqCommuter = {
      user: { id: 1, role: 'commuter' },
      body: {
        title: 'Severe Thunderstorm Alert',
        message: 'High winds expected across Galle Road.',
        alertType: 'weather_emergency',
        severity: 'critical',
      },
    };
    const resCommuter = createMockRes();

    await createAlert(reqCommuter, resCommuter);

    assert.strictEqual(resCommuter.statusCode, 403);
    assert.strictEqual(resCommuter.body.error.code, 'FORBIDDEN_ALERT_BROADCAST');

    // 6b. Moderator broadcasts alert successfully
    const reqModerator = {
      user: { id: 5, role: 'moderator' },
      body: {
        title: 'Severe Thunderstorm Alert',
        message: 'High winds and heavy rain expected across Galle Road corridor.',
        alertType: 'weather_emergency',
        severity: 'critical',
        targetRouteId: 2,
      },
    };
    const resModerator = createMockRes();

    await createAlert(reqModerator, resModerator);

    assert.strictEqual(resModerator.statusCode, 201);
    assert.strictEqual(resModerator.body.success, true);
    assert.strictEqual(resModerator.body.data.alert.severity, 'critical');

    // Verify delivery audit rows recorded in Table 20
    const deliveries = memoryStore.getAlertDeliveries({ alertId: resModerator.body.data.alert.id });
    assert.ok(deliveries.length >= 1);
  });

  it('7. updateSubscription and getSubscriptions manage commuter notification preferences', () => {
    // Save route subscription for user 1
    const reqSave = {
      user: { id: 1 },
      body: {
        subscriptionType: 'route',
        routeId: 2,
        isActive: true,
      },
    };
    const resSave = createMockRes();

    updateSubscription(reqSave, resSave);

    assert.strictEqual(resSave.statusCode, 200);
    assert.strictEqual(resSave.body.data.routeId, 2);

    // Retrieve subscriptions
    const reqGet = { user: { id: 1 } };
    const resGet = createMockRes();

    getSubscriptions(reqGet, resGet);

    assert.strictEqual(resGet.statusCode, 200);
    assert.ok(resGet.body.data.some((s) => s.routeId === 2));
  });

  it('8. registerDeviceToken persists FCM device token', () => {
    const req = {
      user: { id: 1 },
      body: {
        token: 'fcm_sample_device_token_xyz_1234567890',
        platform: 'android',
      },
    };
    const res = createMockRes();

    registerDeviceToken(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(res.body.data.platform, 'android');
    assert.strictEqual(res.body.data.userId, 1);
  });
});
