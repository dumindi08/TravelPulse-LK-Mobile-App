/**
 * TravelPulse LK — Travel Alerts & Notifications Controller
 * Module 4: Road Conditions, Maps & Alerts (Thimaya)
 */

const { alertRepository } = require('../repositories');
const db = require('../config/db');
const { memoryStore } = require('../config/db');
const { notificationService } = require('../services/notification.service');

/**
 * 1. GET /api/v1/alerts
 * Retrieve active travel alerts
 */
async function getAlerts(req, res) {
  const { alertType, severity, status = 'active', routeId } = req.query;

  if (db.isLiveDb) {
    try {
      const alerts = await alertRepository.getAlerts({
        alertType,
        severity,
        status,
        routeId: routeId ? Number(routeId) : null,
      });
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'Travel alerts retrieved successfully.',
        data: alerts,
        meta: { count: alerts.length },
      });
    } catch (err) {
      console.error('[AlertController.getAlerts] Error:', err);
      return res.status(500).json({ success: false, statusCode: 500, message: 'Database error' });
    }
  }

  db.assertFallbackAllowed();
  const rawList = memoryStore.getTravelAlerts({
    alertType,
    severity,
    status,
    routeId: routeId ? Number(routeId) : null,
  });

  const formatted = rawList.map((a) => ({
    id: a.id,
    title: a.title,
    message: a.message,
    alertType: a.alert_type,
    severity: a.severity,
    relatedIncidentId: a.related_incident_id,
    targetRouteId: a.target_route_id,
    targetRouteNumber: a.target_route_number,
    targetLatitude: a.target_latitude,
    targetLongitude: a.target_longitude,
    targetRadiusKm: a.target_radius_km,
    status: a.status,
    createdAt: a.created_at,
    expiresAt: a.expires_at,
  }));

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Travel alerts retrieved successfully.',
    data: formatted,
    meta: { count: formatted.length },
  });
}

/**
 * 2. GET /api/v1/alerts/:id
 * Retrieve single alert details
 */
async function getAlertById(req, res) {
  const id = Number(req.params.id);

  if (db.isLiveDb) {
    try {
      const alert = await alertRepository.findAlertById(id);
      if (!alert) {
        return res.status(404).json({
          success: false,
          statusCode: 404,
          message: `Travel alert #${id} not found.`,
          error: { code: 'ALERT_NOT_FOUND' },
        });
      }
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'Travel alert loaded successfully.',
        data: alert,
      });
    } catch (err) {
      console.error('[AlertController.getAlertById] Error:', err);
      return res.status(500).json({ success: false, statusCode: 500, message: 'Database error' });
    }
  }

  db.assertFallbackAllowed();
  const alert = memoryStore.getTravelAlertById(id);
  if (!alert) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Travel alert #${id} not found.`,
      error: { code: 'ALERT_NOT_FOUND' },
    });
  }

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Travel alert loaded successfully.',
    data: {
      id: alert.id,
      title: alert.title,
      message: alert.message,
      alertType: alert.alert_type,
      severity: alert.severity,
      relatedIncidentId: alert.related_incident_id,
      targetRouteId: alert.target_route_id,
      targetRouteNumber: alert.target_route_number,
      targetLatitude: alert.target_latitude,
      targetLongitude: alert.target_longitude,
      targetRadiusKm: alert.target_radius_km,
      status: alert.status,
      createdAt: alert.created_at,
      expiresAt: alert.expires_at,
    },
  });
}

/**
 * 3. POST /api/v1/alerts
 * Broadcast a new travel alert (Staff / Moderator) and trigger push dispatch
 */
async function createAlert(req, res) {
  const user = req.user;
  const isStaff = user && (user.role === 'moderator' || user.role === 'admin');

  if (!isStaff) {
    return res.status(403).json({
      success: false,
      statusCode: 403,
      message: 'Forbidden. Only transport moderators or administrators can broadcast travel alerts.',
      error: { code: 'FORBIDDEN_ALERT_BROADCAST' },
    });
  }

  if (db.isLiveDb) {
    try {
      const newAlert = await alertRepository.createAlert({
        ...req.body,
        createdBy: user.id,
      });

      const dispatchResult = await notificationService.dispatchAlert(newAlert);

      return res.status(201).json({
        success: true,
        statusCode: 201,
        message: 'Travel alert broadcasted successfully.',
        data: {
          alert: {
            id: newAlert.id,
            title: newAlert.title,
            message: newAlert.message,
            alertType: newAlert.alertType || newAlert.alert_type,
            severity: newAlert.severity,
            status: newAlert.status,
            createdAt: newAlert.createdAt || newAlert.created_at,
          },
          dispatch: dispatchResult,
        },
      });
    } catch (error) {
      console.error('[AlertController.createAlert] Error:', error);
      return res.status(400).json({
        success: false,
        statusCode: 400,
        message: error.message || 'Failed to broadcast travel alert.',
        error: { code: 'ALERT_CREATION_ERROR' },
      });
    }
  }

  db.assertFallbackAllowed();
  try {
    const newAlert = memoryStore.createTravelAlert({
      ...req.body,
      created_by: user.id,
    });

    const dispatchResult = await notificationService.dispatchAlert(newAlert);

    return res.status(201).json({
      success: true,
      statusCode: 201,
      message: 'Travel alert broadcasted successfully.',
      data: {
        alert: {
          id: newAlert.id,
          title: newAlert.title,
          message: newAlert.message,
          alertType: newAlert.alert_type,
          severity: newAlert.severity,
          status: newAlert.status,
          createdAt: newAlert.created_at,
        },
        dispatch: dispatchResult,
      },
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: error.message || 'Failed to broadcast travel alert.',
      error: { code: 'ALERT_CREATION_ERROR' },
    });
  }
}

/**
 * 4. GET /api/v1/alerts/subscriptions
 * Retrieve commuter's alert notification preferences
 */
async function getSubscriptions(req, res) {
  const userId = req.user.id;

  if (db.isLiveDb) {
    try {
      const subs = await alertRepository.getSubscriptions(userId);
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'User alert subscriptions retrieved.',
        data: subs,
      });
    } catch (err) {
      console.error('[AlertController.getSubscriptions] Error:', err);
      return res.status(500).json({ success: false, statusCode: 500, message: 'Database error' });
    }
  }

  db.assertFallbackAllowed();
  const subs = memoryStore.getUserAlertSubscriptions(userId);
  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'User alert subscriptions retrieved.',
    data: subs.map((s) => ({
      id: s.id,
      userId: s.user_id,
      subscriptionType: s.subscription_type,
      routeId: s.route_id,
      centerLatitude: s.center_latitude,
      centerLongitude: s.center_longitude,
      radiusKm: s.radius_km,
      isActive: s.is_active,
    })),
  });
}

/**
 * 5. POST /api/v1/alerts/subscriptions
 * Save / update alert notification preferences
 */
async function updateSubscription(req, res) {
  const userId = req.user.id;

  if (db.isLiveDb) {
    try {
      const saved = await alertRepository.updateSubscription(userId, req.body);
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'Alert subscription preferences saved successfully.',
        data: saved,
      });
    } catch (error) {
      console.error('[AlertController.updateSubscription] Error:', error);
      return res.status(400).json({
        success: false,
        statusCode: 400,
        message: error.message || 'Failed to update subscription.',
        error: { code: 'SUBSCRIPTION_ERROR' },
      });
    }
  }

  db.assertFallbackAllowed();
  try {
    const saved = memoryStore.saveUserAlertSubscription(userId, req.body);
    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: 'Alert subscription preferences saved successfully.',
      data: {
        id: saved.id,
        userId: saved.user_id,
        subscriptionType: saved.subscription_type,
        routeId: saved.route_id,
        centerLatitude: saved.center_latitude,
        centerLongitude: saved.center_longitude,
        radiusKm: saved.radius_km,
        isActive: saved.is_active,
      },
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: error.message || 'Failed to update subscription.',
      error: { code: 'SUBSCRIPTION_ERROR' },
    });
  }
}

/**
 * 6. POST /api/v1/alerts/device-token
 * Register FCM device token for push notifications
 */
async function registerDeviceToken(req, res) {
  const userId = req.user.id;
  const { token, platform = 'android' } = req.body;

  if (db.isLiveDb) {
    try {
      const record = await alertRepository.registerDeviceToken(userId, token, platform);
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'Device token registered successfully for push notifications.',
        data: {
          tokenId: record.id || 1,
          userId: record.userId,
          platform: record.deviceType,
        },
      });
    } catch (err) {
      console.error('[AlertController.registerDeviceToken] Error:', err);
      return res.status(500).json({ success: false, statusCode: 500, message: 'Database error' });
    }
  }

  db.assertFallbackAllowed();
  const record = memoryStore.saveDeviceToken({
    userId,
    token,
    platform,
  });

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Device token registered successfully for push notifications.',
    data: {
      tokenId: record.id,
      userId: record.user_id,
      platform: record.platform,
    },
  });
}

module.exports = {
  getAlerts,
  getAlertById,
  createAlert,
  getSubscriptions,
  updateSubscription,
  registerDeviceToken,
};
