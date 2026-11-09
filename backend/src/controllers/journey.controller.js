/**
 * TravelPulse LK — Commuter Journey Controller (Nisal)
 * Handles journey logging, active journey tracking, and completion.
 */

const { memoryStore } = require('../config/db');

async function getJourneys(req, res) {
  const userId = req.user && req.user.id;
  const journeys = memoryStore.getJourneys(userId);

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: `Retrieved ${journeys.length} journeys.`,
    data: journeys,
  });
}

async function createJourney(req, res) {
  const userId = req.user && req.user.id;
  const { routeId, originStopId, destinationStopId } = req.body || {};

  if (!routeId || !originStopId || !destinationStopId) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'routeId, originStopId, and destinationStopId are required.',
      error: { code: 'VALIDATION_ERROR' },
    });
  }

  const journey = memoryStore.createJourney({
    userId,
    routeId,
    originStopId,
    destinationStopId,
  });

  return res.status(201).json({
    success: true,
    statusCode: 201,
    message: 'Commuter journey started successfully.',
    data: journey,
  });
}

async function completeJourney(req, res) {
  const userId = req.user && req.user.id;
  const { id } = req.params;

  const journey = memoryStore.completeJourney(id, userId);

  if (!journey) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Active journey with ID ${id} not found for this user.`,
      error: { code: 'JOURNEY_NOT_FOUND' },
    });
  }

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Journey marked as completed.',
    data: journey,
  });
}

module.exports = {
  getJourneys,
  createJourney,
  completeJourney,
};

