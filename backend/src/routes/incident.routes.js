/**
 * TravelPulse LK — Road Incident Routes
 * Module 4: Road Conditions, Maps & Alerts (Thimaya)
 * Base URL: /api/v1/incidents
 */

const express = require('express');
const router = express.Router();

const {
  getIncidents,
  getIncidentById,
  promoteReport,
} = require('../controllers/incident.controller');

const { requireAuth } = require('../middleware/auth.middleware');

// 1. Get active road incidents & hazards for map display (Public)
router.get('/', getIncidents);

// 2. Get single incident details (Public)
router.get('/:id', getIncidentById);

// 3. Promote community report to confirmed road incident (Protected — Verified report or Moderator)
router.post('/promote/:reportId', requireAuth, promoteReport);

module.exports = router;

