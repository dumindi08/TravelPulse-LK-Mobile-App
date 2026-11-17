/**
 * TravelPulse LK — Commuter Journey Controller (Nisal)
 * Handles journey logging, active journey tracking, completion, and cancellation.
 */

const { journeyRepository } = require('../repositories');

async function getJourneys(req, res) {
  try {
    const userId = req.user && req.user.id;
    const journeys = await journeyRepository.getJourneys(userId);

    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: `Retrieved ${journeys.length} journeys.`,
      data: journeys,
    });
  } catch (err) {
    console.error('[JourneyController.getJourneys] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to retrieve journeys.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function createJourney(req, res) {
  try {
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

    const journey = await journeyRepository.createJourney({
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
  } catch (err) {
    console.error('[JourneyController.createJourney] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to start commuter journey.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function completeJourney(req, res) {
  try {
    const userId = req.user && req.user.id;
    const { id } = req.params;

    const journey = await journeyRepository.completeJourney(id, userId);

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
  } catch (err) {
    console.error('[JourneyController.completeJourney] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to complete journey.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function cancelJourney(req, res) {
  try {
    const userId = req.user && req.user.id;
    const { id } = req.params;

    const journey = await journeyRepository.cancelJourney(id, userId);

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
      message: 'Journey marked as cancelled.',
      data: journey,
    });
  } catch (err) {
    console.error('[JourneyController.cancelJourney] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to cancel journey.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

module.exports = {
  getJourneys,
  createJourney,
  completeJourney,
  cancelJourney,
};
