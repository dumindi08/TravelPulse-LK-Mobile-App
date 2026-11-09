/**
 * TravelPulse LK — Transport Route & Schedule Controller (Nisal)
 * Handles route searching, stops sequencing, and timetables.
 */

const { memoryStore } = require('../config/db');

async function getRoutes(req, res) {
  const { transportType, origin, destination } = req.query;

  const routes = memoryStore.getRoutes({
    transportType,
    origin,
    destination,
  });

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: `Retrieved ${routes.length} transit routes.`,
    data: routes,
  });
}

async function getRouteById(req, res) {
  const { id } = req.params;
  const route = memoryStore.getRouteById(id);

  if (!route) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Transit route with ID ${id} not found.`,
      error: { code: 'ROUTE_NOT_FOUND' },
    });
  }

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Transit route details retrieved successfully.',
    data: route,
  });
}

async function getRouteSchedules(req, res) {
  const { id } = req.params;
  const { direction, dayOfWeek } = req.query;

  const schedules = memoryStore.getRouteSchedules(id, {
    direction: direction || 'outbound',
    dayOfWeek: dayOfWeek || 'all',
  });

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: `Retrieved ${schedules.length} scheduled departures.`,
    data: schedules,
  });
}

module.exports = {
  getRoutes,
  getRouteById,
  getRouteSchedules,
};

