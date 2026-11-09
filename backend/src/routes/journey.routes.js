/**
 * TravelPulse LK — Commuter Journey Routes (Nisal)
 * Base Path: /api/v1/journeys
 */

const express = require('express');
const { getJourneys, createJourney, completeJourney } = require('../controllers/journey.controller');
const { requireAuth } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/', requireAuth, getJourneys);
router.post('/', requireAuth, createJourney);
router.patch('/:id/complete', requireAuth, completeJourney);

module.exports = router;

