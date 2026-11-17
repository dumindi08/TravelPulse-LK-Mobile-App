/**
 * TravelPulse LK — Travel Alert Routes
 * Module 4: Road Conditions, Maps & Alerts (Thimaya)
 * Base URL: /api/v1/alerts
 */

const express = require('express');
const router = express.Router();

const {
  getAlerts,
  getAlertById,
  createAlert,
  getSubscriptions,
  updateSubscription,
  registerDeviceToken,
} = require('../controllers/alert.controller');

const { requireAuth } = require('../middleware/auth.middleware');
const {
  validateCreateAlert,
  validateSubscription,
  validateDeviceToken,
} = require('../validators/alert.validator');

// 1. Commuter notification preferences & subscriptions (Protected)
router.get('/subscriptions', requireAuth, getSubscriptions);
router.post('/subscriptions', requireAuth, validateSubscription, updateSubscription);

// 2. Register FCM device token for push notifications (Protected)
router.post('/device-token', requireAuth, validateDeviceToken, registerDeviceToken);

// 3. Get active travel alerts (Public)
router.get('/', getAlerts);

// 4. Get single alert by ID (Public)
router.get('/:id', getAlertById);

// 5. Broadcast new travel alert (Protected — Staff/Moderator)
router.post('/', requireAuth, validateCreateAlert, createAlert);

module.exports = router;

