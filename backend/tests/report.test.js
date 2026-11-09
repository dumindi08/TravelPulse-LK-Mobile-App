/**
 * TravelPulse LK — Community Reporting Backend Automated Unit Tests
 * Module 2: Community Reporting & Transport Disruption Management (Dumindi)
 * ---------------------------------------------------------------------------
 * Directly verifies:
 * 1. Category taxonomy (all 6 master categories)
 * 2. Input validation for report creation
 * 3. Service disruption reason mandate and rejection of invented severity
 * 4. Anonymous reporting masking (public views hide reporter details)
 * 5. Report creation retaining internal ownership
 * 6. User-specific report isolation (My Reports)
 * 7. Ownership enforcement on deletion (403 Forbidden for non-authors)
 * ---------------------------------------------------------------------------
 */

const { describe, it, beforeEach } = require('node:test');
const assert = require('node:assert');
const { memoryStore } = require('../src/config/db');
const {
  getCategories,
  getPublicReports,
  getReportById,
  getMyReports,
  createReport,
  updateReport,
  deleteReport,
} = require('../src/controllers/report.controller');
const { validateCreateReport } = require('../src/validators/report.validator');

// Helper to create mock Express response object
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

describe('TravelPulse LK — Community Reporting Backend Logic (Dumindi)', () => {
  beforeEach(() => {
    memoryStore.reset();
  });

  it('1. getCategories returns all 6 master categories with appropriate codes', () => {
    const req = {};
    const res = createMockRes();

    getCategories(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(Array.isArray(res.body.data), true);
    assert.strictEqual(res.body.data.length, 6);

    const codes = res.body.data.map((c) => c.code);
    assert.deepStrictEqual(codes, [
      'CROWD',
      'ROAD_CONDITION',
      'TRANSPORT_TRACKING',
      'SERVICE_DISRUPTION',
      'ACCIDENT_INCIDENT',
      'OTHER',
    ]);
  });

  it('2. validateCreateReport enforces required title, description, category and coordinates', () => {
    const req = {
      body: {
        title: 'Sh', // Too short (< 5)
        description: 'Tiny', // Too short (< 10)
        categoryId: 99, // Invalid (> 6)
        latitude: 'bad-coord',
        longitude: 250, // Out of bounds
      },
    };
    const res = createMockRes();
    let nextCalled = false;

    validateCreateReport(req, res, () => {
      nextCalled = true;
    });

    assert.strictEqual(nextCalled, false);
    assert.strictEqual(res.statusCode, 400);
    assert.strictEqual(res.body.success, false);
    assert.strictEqual(res.body.error.code, 'VALIDATION_ERROR');
    assert.ok(res.body.error.details.length >= 4);
  });

  it('3. validateCreateReport strictly requires disruptionReason for Category 4 and rejects invented severity', () => {
    // 3a. Missing disruption reason on Service Disruption
    const reqMissingReason = {
      body: {
        title: 'Main Line Train Stoppage',
        description: 'Passenger train stuck between Ragama and Gampaha.',
        categoryId: 4, // Service Disruption
        latitude: 7.0270,
        longitude: 79.9230,
      },
    };
    const resMissing = createMockRes();
    let nextCalledA = false;

    validateCreateReport(reqMissingReason, resMissing, () => {
      nextCalledA = true;
    });

    assert.strictEqual(nextCalledA, false);
    assert.strictEqual(resMissing.statusCode, 400);
    assert.ok(resMissing.body.error.details.some((d) => d.field === 'disruptionReason'));

    // 3b. Invented severity submitted for Service Disruption (Must be rejected!)
    const reqSeverity = {
      body: {
        title: 'Main Line Train Stoppage',
        description: 'Passenger train stuck between Ragama and Gampaha.',
        categoryId: 4,
        disruptionReason: 'Engine Overheating',
        severity: 'critical', // Invalid for Service Disruption!
        latitude: 7.0270,
        longitude: 79.9230,
      },
    };
    const resSeverity = createMockRes();
    let nextCalledB = false;

    validateCreateReport(reqSeverity, resSeverity, () => {
      nextCalledB = true;
    });

    assert.strictEqual(nextCalledB, false);
    assert.strictEqual(resSeverity.statusCode, 400);
    assert.ok(resSeverity.body.error.details.some((d) => d.field === 'severity'));

    // 3c. Valid Service Disruption report with specific reason passes validation
    const reqValid = {
      body: {
        title: 'Main Line Train Stoppage',
        description: 'Passenger train stuck between Ragama and Gampaha due to signal fault.',
        categoryId: 4,
        disruptionReason: 'Signal Failure',
        latitude: 7.0270,
        longitude: 79.9230,
      },
    };
    const resValid = createMockRes();
    let nextCalledC = false;

    validateCreateReport(reqValid, resValid, () => {
      nextCalledC = true;
    });

    assert.strictEqual(nextCalledC, true);
  });

  it('4. getPublicReports masks anonymous reporter identity for public commuters', () => {
    const req = { query: {}, user: null }; // Unauthenticated guest
    const res = createMockRes();

    getPublicReports(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);

    // Report #102 in seed is an anonymous Road Condition report by Dilshan (userId: 2)
    const report102 = res.body.data.find((r) => r.id === 102);
    assert.ok(report102);
    assert.strictEqual(report102.isAnonymous, true);
    assert.strictEqual(report102.userName, 'Anonymous Commuter');
    assert.strictEqual(report102.userId, null); // Public must not see internal user_id
    assert.strictEqual(report102.isOwnReport, false);

    // Report #101 is identified by Kamal (userId: 1)
    const report101 = res.body.data.find((r) => r.id === 101);
    assert.ok(report101);
    assert.strictEqual(report101.isAnonymous, false);
    assert.strictEqual(report101.userName, 'Kamal Perera');
  });

  it('5. createReport extracts userId strictly from JWT session and persists anonymous flag', () => {
    const req = {
      user: { id: 1, name: 'Kamal Perera', email: 'kamal@example.com' },
      body: {
        categoryId: 2,
        title: 'Deep Pothole on Duplication Road',
        description: 'Large hazardous pothole right in front of Liberty Plaza entrance.',
        latitude: 6.9050,
        longitude: 79.8510,
        locationDescription: 'Kollupitiya',
        isAnonymous: true,
        userId: 9999, // Malicious spoofed client ID — MUST BE IGNORED!
      },
    };
    const res = createMockRes();

    createReport(req, res);

    assert.strictEqual(res.statusCode, 201);
    assert.strictEqual(res.body.success, true);
    assert.strictEqual(res.body.data.isAnonymous, true);
    assert.strictEqual(res.body.data.isOwnReport, true);

    // Verify stored entity in database retains internal authenticated user_id: 1
    const stored = memoryStore.getReportById(res.body.data.id);
    assert.strictEqual(stored.user_id, 1);
    assert.strictEqual(stored.is_anonymous, true);
  });

  it('6. getMyReports returns all authored reports including anonymous submissions', () => {
    // Kamal (userId: 1) authored reports #101, #103 in seed
    const req = { user: { id: 1, name: 'Kamal Perera' } };
    const res = createMockRes();

    getMyReports(req, res);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.success, true);
    assert.ok(res.body.data.length >= 2);
    assert.ok(res.body.data.every((r) => r.userId === 1));
    assert.ok(res.body.data.every((r) => r.isOwnReport === true));
  });

  it('7. deleteReport enforces strict ownership (403 Forbidden for non-authors)', () => {
    // Dilshan (userId: 2) tries to delete Kamal's report (#101)
    const reqUnauthorized = {
      params: { id: 101 },
      user: { id: 2, role: 'commuter' },
    };
    const resUnauthorized = createMockRes();

    deleteReport(reqUnauthorized, resUnauthorized);

    assert.strictEqual(resUnauthorized.statusCode, 403);
    assert.strictEqual(resUnauthorized.body.success, false);
    assert.strictEqual(resUnauthorized.body.error.code, 'FORBIDDEN_RESOURCE');

    // Verify report #101 was NOT deleted
    assert.ok(memoryStore.getReportById(101));

    // Kamal (userId: 1) deletes his own report (#101)
    const reqAuthorized = {
      params: { id: 101 },
      user: { id: 1, role: 'commuter' },
    };
    const resAuthorized = createMockRes();

    deleteReport(reqAuthorized, resAuthorized);

    assert.strictEqual(resAuthorized.statusCode, 200);
    assert.strictEqual(resAuthorized.body.success, true);
    assert.strictEqual(resAuthorized.body.data.deletedReportId, 101);

    // Verify report #101 is now removed
    assert.strictEqual(memoryStore.getReportById(101), undefined);
  });

  it('8. deleteReport permits moderator override', () => {
    // Dilshan's report #102 deleted by moderator (userId: 99, role: 'moderator')
    const reqModerator = {
      params: { id: 102 },
      user: { id: 99, role: 'moderator' },
    };
    const resModerator = createMockRes();

    deleteReport(reqModerator, resModerator);

    assert.strictEqual(resModerator.statusCode, 200);
    assert.strictEqual(resModerator.body.success, true);
    assert.strictEqual(memoryStore.getReportById(102), undefined);
  });
});
