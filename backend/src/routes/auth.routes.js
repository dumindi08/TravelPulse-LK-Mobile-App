/**
 * TravelPulse LK — Authentication Routes (Nisal)
 * Base Path: /api/v1/auth
 */

const express = require('express');
const { login, register, getMe } = require('../controllers/auth.controller');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/login', login);
router.post('/register', register);
router.get('/me', requireAuth, getMe);

module.exports = router;

