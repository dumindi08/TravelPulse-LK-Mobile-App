/**
 * TravelPulse LK — Transport Route & Schedule Controller (Nisal)
 * Handles route searching, stops sequencing, master stops catalog, and timetables.
 */

const { routeRepository } = require('../repositories');

async function getRoutes(req, res) {
  try {
    const { transportType, origin, destination } = req.query;

    const routes = await routeRepository.getAllRoutes({
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
  } catch (err) {
    console.error('[RouteController.getRoutes] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to retrieve transit routes.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function getStops(req, res) {
  try {
    const stops = await routeRepository.getStops();

    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: `Retrieved ${stops.length} transit stops.`,
      data: stops,
    });
  } catch (err) {
    console.error('[RouteController.getStops] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to retrieve transit stops.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function getRouteById(req, res) {
  try {
    const { id } = req.params;
    const route = await routeRepository.getRouteById(id);

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
  } catch (err) {
    console.error('[RouteController.getRouteById] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to retrieve transit route details.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

async function getRouteSchedules(req, res) {
  try {
    const { id } = req.params;
    const { direction, dayOfWeek } = req.query;

    const schedules = await routeRepository.getSchedulesByRoute(id, {
      direction: direction || 'outbound',
      dayOfWeek: dayOfWeek || 'all',
    });

    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: `Retrieved ${schedules.length} scheduled departures.`,
      data: schedules,
    });
  } catch (err) {
    console.error('[RouteController.getRouteSchedules] Error:', err);
    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: 'Failed to retrieve route schedules.',
      error: { code: 'SERVER_ERROR' },
    });
  }
}

module.exports = {
  getRoutes,
  getStops,
  getRouteById,
  getRouteSchedules,
};
