/**
 * TravelPulse LK — Transport Route & Schedule Routes (Nisal)
 * Base Path: /api/v1/routes
 */

const express = require('express');
const { getRoutes, getRouteById, getRouteSchedules } = require('../controllers/route.controller');

const router = express.Router();

router.get('/', getRoutes);
router.get('/:id', getRouteById);
router.get('/:id/schedules', getRouteSchedules);

module.exports = router;

