/**
 * TravelPulse LK — Travel Alert & Notification Validators
 * Module 4: Road Conditions, Maps & Alerts (Thimaya)
 */

const ALLOWED_ALERT_TYPES = [
  'transport_disruption',
  'road_condition',
  'weather_emergency',
  'security',
];

const ALLOWED_ALERT_SEVERITIES = ['info', 'warning', 'critical'];
const ALLOWED_SUB_TYPES = ['route', 'geo_radius', 'all_critical'];

function validateCreateAlert(req, res, next) {
  const { title, message, alertType, severity } = req.body;
  const errors = [];

  if (!title || typeof title !== 'string' || title.trim().length < 5) {
    errors.push({ field: 'title', message: 'Alert title must be at least 5 characters.' });
  }

  if (!message || typeof message !== 'string' || message.trim().length < 10) {
    errors.push({ field: 'message', message: 'Alert message must be at least 10 characters.' });
  }

  if (!alertType || !ALLOWED_ALERT_TYPES.includes(String(alertType).toLowerCase())) {
    errors.push({
      field: 'alertType',
      message: `alertType must be one of: ${ALLOWED_ALERT_TYPES.join(', ')}.`,
    });
  }

  if (severity && !ALLOWED_ALERT_SEVERITIES.includes(String(severity).toLowerCase())) {
    errors.push({
      field: 'severity',
      message: `severity must be one of: ${ALLOWED_ALERT_SEVERITIES.join(', ')}.`,
    });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Validation failed for travel alert.',
      error: { code: 'VALIDATION_ERROR', details: errors },
    });
  }

  next();
}

function validateSubscription(req, res, next) {
  const { subscriptionType, routeId, centerLatitude, centerLongitude, radiusKm } = req.body;
  const errors = [];

  if (!subscriptionType || !ALLOWED_SUB_TYPES.includes(String(subscriptionType).toLowerCase())) {
    errors.push({
      field: 'subscriptionType',
      message: `subscriptionType must be one of: ${ALLOWED_SUB_TYPES.join(', ')}.`,
    });
  }

  if (subscriptionType === 'route' && !routeId) {
    errors.push({ field: 'routeId', message: 'routeId is required when subscriptionType is "route".' });
  }

  if (subscriptionType === 'geo_radius') {
    if (centerLatitude === undefined || isNaN(Number(centerLatitude))) {
      errors.push({ field: 'centerLatitude', message: 'Valid latitude is required for geo_radius.' });
    }
    if (centerLongitude === undefined || isNaN(Number(centerLongitude))) {
      errors.push({ field: 'centerLongitude', message: 'Valid longitude is required for geo_radius.' });
    }
    if (!radiusKm || Number(radiusKm) <= 0 || Number(radiusKm) > 50) {
      errors.push({ field: 'radiusKm', message: 'radiusKm must be between 0.5 and 50 km.' });
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Validation failed for alert subscription.',
      error: { code: 'VALIDATION_ERROR', details: errors },
    });
  }

  next();
}

function validateDeviceToken(req, res, next) {
  const { token, platform } = req.body;
  const errors = [];

  if (!token || typeof token !== 'string' || token.trim().length < 10) {
    errors.push({ field: 'token', message: 'Valid device FCM token is required.' });
  }

  if (platform && !['android', 'ios', 'web'].includes(String(platform).toLowerCase())) {
    errors.push({ field: 'platform', message: 'Platform must be android, ios, or web.' });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Validation failed for device token registration.',
      error: { code: 'VALIDATION_ERROR', details: errors },
    });
  }

  next();
}

module.exports = {
  validateCreateAlert,
  validateSubscription,
  validateDeviceToken,
  ALLOWED_ALERT_TYPES,
  ALLOWED_ALERT_SEVERITIES,
  ALLOWED_SUB_TYPES,
};

