/**
 * TravelPulse LK — Road Incident Validators
 * Module 4: Road Conditions, Maps & Alerts (Thimaya)
 */

const ALLOWED_INCIDENT_TYPES = [
  'pothole',
  'flooding',
  'landslide',
  'road_closure',
  'accident',
  'congestion',
  'traffic_lights_down',
];

const ALLOWED_SEVERITIES = ['low', 'medium', 'high', 'critical'];

function validateCreateIncident(req, res, next) {
  const { incidentType, latitude, longitude, severity } = req.body;
  const errors = [];

  if (!incidentType || !ALLOWED_INCIDENT_TYPES.includes(String(incidentType).toLowerCase())) {
    errors.push({
      field: 'incidentType',
      message: `incidentType must be one of: ${ALLOWED_INCIDENT_TYPES.join(', ')}.`,
    });
  }

  const lat = Number(latitude);
  const lon = Number(longitude);
  if (latitude === undefined || isNaN(lat) || lat < 5.8 || lat > 9.9) {
    errors.push({ field: 'latitude', message: 'Valid Sri Lankan latitude between 5.8 and 9.9 is required.' });
  }

  if (longitude === undefined || isNaN(lon) || lon < 79.5 || lon > 82.0) {
    errors.push({ field: 'longitude', message: 'Valid Sri Lankan longitude between 79.5 and 82.0 is required.' });
  }

  if (severity && !ALLOWED_SEVERITIES.includes(String(severity).toLowerCase())) {
    errors.push({
      field: 'severity',
      message: `severity must be one of: ${ALLOWED_SEVERITIES.join(', ')}.`,
    });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Validation failed for road incident.',
      error: { code: 'VALIDATION_ERROR', details: errors },
    });
  }

  next();
}

module.exports = {
  validateCreateIncident,
  ALLOWED_INCIDENT_TYPES,
  ALLOWED_SEVERITIES,
};

