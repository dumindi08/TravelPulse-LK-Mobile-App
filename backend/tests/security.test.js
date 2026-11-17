/**
 * TravelPulse LK — Stage 8.2 Security & Authentication Test Suite
 * Comprehensive automated verification of authentication security, cryptographic JWTs,
 * role authorization, and data privacy safeguards.
 */

const { describe, it, beforeEach } = require('node:test');
const assert = require('node:assert/strict');
const { Readable } = require('node:stream');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = require('../src/app');
const { memoryStore } = require('../src/config/db');
const { getJwtSecret, createToken } = require('../src/controllers/auth.controller');

function makeRequest(app, method, url, { headers = {}, body = null } = {}) {
  return new Promise((resolve) => {
    const reqHeaders = { ...headers };
    let bodyBuffer = null;

    if (body) {
      bodyBuffer = Buffer.from(JSON.stringify(body), 'utf8');
      reqHeaders['content-type'] = 'application/json';
      reqHeaders['content-length'] = bodyBuffer.length.toString();
    }

    const req = Readable.from(bodyBuffer ? [bodyBuffer] : []);
    req.method = method;
    req.url = url;
    req.originalUrl = url;
    req.headers = reqHeaders;
    req.query = {};
    req.params = {};

    const res = {
      statusCode: 200,
      headers: {},
      bodyData: '',
      status(code) {
        this.statusCode = code;
        return this;
      },
      setHeader(name, val) {
        this.headers[name.toLowerCase()] = val;
      },
      header(name, val) {
        this.headers[name.toLowerCase()] = val;
      },
      json(data) {
        this.bodyData = JSON.stringify(data);
        resolve({
          status: this.statusCode,
          headers: this.headers,
          body: data,
        });
      },
      send(data) {
        this.bodyData = data;
        let parsed;
        try {
          parsed = JSON.parse(data);
        } catch (_) {
          parsed = data;
        }
        resolve({
          status: this.statusCode,
          headers: this.headers,
          body: parsed,
        });
      },
      sendStatus(code) {
        this.statusCode = code;
        resolve({ status: code, headers: {}, body: null });
      },
      end() {
        resolve({ status: this.statusCode, headers: this.headers, body: null });
      },
    };

    app.handle(req, res);
  });
}

describe('TravelPulse LK — Stage 8.2 Security Safeguards', () => {
  beforeEach(() => {
    process.env.NODE_ENV = 'test';
    memoryStore.reset();
  });

  // 1. Valid login credentials work
  it('1. Valid login credentials authenticate successfully and issue genuine JWT', async () => {
    const res = await makeRequest(app, 'POST', '/api/v1/auth/login', {
      body: {
        emailOrUsername: 'kamal@example.com',
        password: 'Password123!',
      },
    });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.token, 'Must return JWT token');
    assert.equal(res.body.data.user.email, 'kamal@example.com');
    assert.equal(res.body.data.user.role, 'commuter');

    // Verify token structure
    const decoded = jwt.verify(res.body.data.token, getJwtSecret());
    assert.equal(decoded.id, 1);
    assert.equal(decoded.email, 'kamal@example.com');
  });

  // 2. Incorrect passwords are rejected
  it('2. Incorrect passwords are rejected with HTTP 401 INVALID_CREDENTIALS', async () => {
    const res = await makeRequest(app, 'POST', '/api/v1/auth/login', {
      body: {
        emailOrUsername: 'kamal@example.com',
        password: 'WrongPassword999!',
      },
    });

    assert.equal(res.status, 401);
    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'INVALID_CREDENTIALS');
  });

  // 3. Passwords are stored as hashes (never in plain text)
  it('3. Passwords are never stored in plain text and use bcrypt hashes', async () => {
    // Check initial seed users
    for (const u of memoryStore.users) {
      assert.equal(u.password, undefined, 'Plain-text password property must not exist');
      assert.ok(u.password_hash, 'password_hash must exist');
      assert.ok(u.password_hash.startsWith('$2'), 'Must be a valid bcrypt hash');
    }

    // Register a new user
    const regRes = await makeRequest(app, 'POST', '/api/v1/auth/register', {
      body: {
        name: 'Test Hash User',
        email: 'hashuser@example.com',
        password: 'MyPlainTextSecretPassword123!',
      },
    });

    assert.equal(regRes.status, 201);
    const createdUser = memoryStore.users.find((u) => u.email === 'hashuser@example.com');
    assert.ok(createdUser, 'User must be found in memoryStore');
    assert.equal(createdUser.password, undefined, 'Plain-text password must not be saved');
    assert.ok(createdUser.password_hash, 'password_hash must be saved');
    assert.notEqual(createdUser.password_hash, 'MyPlainTextSecretPassword123!');
    assert.ok(bcrypt.compareSync('MyPlainTextSecretPassword123!', createdUser.password_hash), 'Hash must verify with bcrypt');
  });

  // 4. Valid JWTs are accepted
  it('4. Valid JWTs are accepted and populate authenticated commuter profile', async () => {
    const validToken = createToken({
      id: 1,
      name: 'Kamal Perera',
      email: 'kamal@example.com',
      role: 'commuter',
    });

    const res = await makeRequest(app, 'GET', '/api/v1/auth/me', {
      headers: { authorization: `Bearer ${validToken}` },
    });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.id, 1);
    assert.equal(res.body.data.email, 'kamal@example.com');
  });

  // 5. Tampered JWTs are rejected
  it('5. Tampered JWT payloads are rejected with HTTP 401 UNAUTHORIZED', async () => {
    const validToken = createToken({
      id: 1,
      name: 'Kamal Perera',
      email: 'kamal@example.com',
      role: 'commuter',
    });

    const parts = validToken.split('.');
    // Tamper with payload (elevate role to admin in base64 payload without modifying signature)
    const tamperedPayload = Buffer.from(
      JSON.stringify({ id: 1, name: 'Kamal Perera', email: 'kamal@example.com', role: 'admin' })
    ).toString('base64url');

    const tamperedToken = `${parts[0]}.${tamperedPayload}.${parts[2]}`;

    const res = await makeRequest(app, 'GET', '/api/v1/auth/me', {
      headers: { authorization: `Bearer ${tamperedToken}` },
    });

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'UNAUTHORIZED');
  });

  // 6. Expired JWTs are rejected
  it('6. Expired JWTs are rejected with HTTP 401 UNAUTHORIZED', async () => {
    const expiredToken = jwt.sign(
      { id: 1, name: 'Kamal Perera', email: 'kamal@example.com', role: 'commuter' },
      getJwtSecret(),
      { expiresIn: '-10s' } // Expired 10 seconds ago
    );

    const res = await makeRequest(app, 'GET', '/api/v1/auth/me', {
      headers: { authorization: `Bearer ${expiredToken}` },
    });

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'UNAUTHORIZED');
  });

  // 7. Invalid signatures are rejected
  it('7. JWTs signed with an invalid secret are rejected with HTTP 401 UNAUTHORIZED', async () => {
    const forgedToken = jwt.sign(
      { id: 1, name: 'Kamal Perera', email: 'kamal@example.com', role: 'admin' },
      'forged_and_invalid_attacker_signing_secret_999',
      { expiresIn: '1h' }
    );

    const res = await makeRequest(app, 'GET', '/api/v1/auth/me', {
      headers: { authorization: `Bearer ${forgedToken}` },
    });

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'UNAUTHORIZED');
  });

  // 8. Test tokens cannot authenticate in production mode
  it('8. Development test tokens cannot authenticate when NODE_ENV is production', async () => {
    process.env.NODE_ENV = 'production';
    process.env.JWT_SECRET = 'temporary_test_prod_jwt_secret_key_555';

    try {
      // Attempt using development test tokens
      const resKamal = await makeRequest(app, 'GET', '/api/v1/auth/me', {
        headers: { authorization: 'Bearer test-token-kamal' },
      });
      assert.equal(resKamal.status, 401, 'test-token-kamal must be rejected in production');

      const resAdmin = await makeRequest(app, 'GET', '/api/v1/auth/me', {
        headers: { authorization: 'Bearer test-token-admin' },
      });
      assert.equal(resAdmin.status, 401, 'test-token-admin must be rejected in production');
    } finally {
      process.env.NODE_ENV = 'test';
    }
  });

  // 9. Ordinary users cannot access moderator-only operations
  it('9. Ordinary commuters cannot broadcast travel alerts (HTTP 403 FORBIDDEN)', async () => {
    const commuterToken = createToken({
      id: 1,
      name: 'Kamal Perera',
      email: 'kamal@example.com',
      role: 'commuter',
    });

    const res = await makeRequest(app, 'POST', '/api/v1/alerts', {
      headers: { authorization: `Bearer ${commuterToken}` },
      body: {
        title: 'Unauthorized Emergency Alert',
        message: 'This alert should be blocked because user is not a moderator.',
        alertType: 'transport_disruption',
        severity: 'critical',
      },
    });

    assert.equal(res.status, 403);
    assert.equal(res.body.error.code, 'FORBIDDEN_ALERT_BROADCAST');
  });

  // 10. Users cannot delete reports belonging to other users
  it('10. Commuters cannot delete reports authored by other commuters (HTTP 403)', async () => {
    // Report 101 belongs to User 1 (Kamal)
    const report101 = memoryStore.getReportById(101);
    assert.equal(report101.user_id, 1);

    // User 2 (Dilshan) attempts to delete report 101
    const user2Token = createToken({
      id: 2,
      name: 'Dilshan Silva',
      email: 'dilshan@example.com',
      role: 'commuter',
    });

    const delRes = await makeRequest(app, 'DELETE', '/api/v1/reports/101', {
      headers: { authorization: `Bearer ${user2Token}` },
    });

    assert.equal(delRes.status, 403);
    assert.equal(delRes.body.error.code, 'FORBIDDEN_RESOURCE');

    // Confirm report is still present
    const checkReport = memoryStore.getReportById(101);
    assert.ok(checkReport, 'Report 101 must not have been deleted');
  });

  // 11. Anonymous reports do not expose reporter identity
  it('11. Anonymous community reports mask reporter name and userId in public views', async () => {
    // Report 102 is anonymous, authored by user 2
    const report102 = memoryStore.getReportById(102);
    assert.equal(report102.is_anonymous, true);
    assert.equal(report102.user_id, 2);

    // Another commuter (User 1) views report 102
    const user1Token = createToken({
      id: 1,
      name: 'Kamal Perera',
      email: 'kamal@example.com',
      role: 'commuter',
    });

    const viewRes = await makeRequest(app, 'GET', '/api/v1/reports/102', {
      headers: { authorization: `Bearer ${user1Token}` },
    });

    assert.equal(viewRes.status, 200);
    assert.equal(viewRes.body.data.isAnonymous, true);
    assert.equal(viewRes.body.data.userName, 'Anonymous Commuter');
    assert.equal(viewRes.body.data.userId, null, 'Reporter userId must be masked as null');

    // Public unauthenticated commuter views the feed
    const publicFeedRes = await makeRequest(app, 'GET', '/api/v1/reports');
    assert.equal(publicFeedRes.status, 200);
    const pubRep102 = publicFeedRes.body.data.find((r) => r.id === 102);
    assert.ok(pubRep102);
    assert.equal(pubRep102.userName, 'Anonymous Commuter');
    assert.equal(pubRep102.userId, null);
  });
});

