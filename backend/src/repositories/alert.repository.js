/**
 * TravelPulse LK — Travel Alert Repository (Module 4: Thimaya)
 * Handles database operations for travel alerts, alert subscriptions, device tokens, and deliveries.
 */

const db = require('../config/db');

class AlertRepository {
  /**
   * Get travel alerts with optional filtering
   */
  async getAlerts({ status, severity, routeId } = {}) {
    if (db.isLiveDb) {
      let sql = `
        SELECT a.id, a.title, a.message, a.alert_type AS alertType, a.severity,
               a.related_disruption_id AS relatedDisruptionId, a.related_incident_id AS relatedIncidentId,
               a.target_route_id AS targetRouteId, a.target_latitude AS targetLatitude,
               a.target_longitude AS targetLongitude, a.target_radius_km AS targetRadiusKm,
               a.status, a.created_by AS createdBy, a.created_at AS createdAt, a.expires_at AS expiresAt,
               tr.route_number AS routeNumber, tr.name AS routeName
        FROM travel_alerts a
        LEFT JOIN transport_routes tr ON a.target_route_id = tr.id
        WHERE 1=1
      `;
      const params = [];

      if (status) {
        sql += ' AND a.status = ?';
        params.push(status);
      }
      if (severity) {
        sql += ' AND a.severity = ?';
        params.push(severity);
      }
      if (routeId) {
        sql += ' AND a.target_route_id = ?';
        params.push(routeId);
      }

      sql += ' ORDER BY a.created_at DESC';

      const [rows] = await db.query(sql, params);
      return rows.map((r) => ({
        ...r,
        targetLatitude: r.targetLatitude ? parseFloat(r.targetLatitude) : null,
        targetLongitude: r.targetLongitude ? parseFloat(r.targetLongitude) : null,
        targetRadiusKm: r.targetRadiusKm ? parseFloat(r.targetRadiusKm) : null,
      }));
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getAlerts({ status, severity, routeId });
  }

  /**
   * Find single travel alert by ID
   */
  async findAlertById(id) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        `SELECT a.id, a.title, a.message, a.alert_type AS alertType, a.severity,
                a.related_disruption_id AS relatedDisruptionId, a.related_incident_id AS relatedIncidentId,
                a.target_route_id AS targetRouteId, a.target_latitude AS targetLatitude,
                a.target_longitude AS targetLongitude, a.target_radius_km AS targetRadiusKm,
                a.status, a.created_by AS createdBy, a.created_at AS createdAt, a.expires_at AS expiresAt,
                tr.route_number AS routeNumber, tr.name AS routeName
         FROM travel_alerts a
         LEFT JOIN transport_routes tr ON a.target_route_id = tr.id
         WHERE a.id = ?`,
        [id]
      );
      if (!rows || rows.length === 0) return null;
      const r = rows[0];
      return {
        ...r,
        targetLatitude: r.targetLatitude ? parseFloat(r.targetLatitude) : null,
        targetLongitude: r.targetLongitude ? parseFloat(r.targetLongitude) : null,
        targetRadiusKm: r.targetRadiusKm ? parseFloat(r.targetRadiusKm) : null,
      };
    }

    db.assertFallbackAllowed();
    return db.memoryStore.findAlertById(id);
  }

  /**
   * Create and broadcast travel alert
   */
  async createAlert({
    title,
    message,
    alertType = 'road_condition',
    severity = 'info',
    relatedDisruptionId,
    relatedIncidentId,
    targetRouteId,
    targetLatitude,
    targetLongitude,
    targetRadiusKm,
    createdBy,
    expiresAt,
  }) {
    if (db.isLiveDb) {
      const defaultExpires = new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString().slice(0, 19).replace('T', ' ');
      const [result] = await db.query(
        `INSERT INTO travel_alerts (
          title, message, alert_type, severity, related_disruption_id,
          related_incident_id, target_route_id, target_latitude, target_longitude,
          target_radius_km, status, created_by, created_at, expires_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', ?, NOW(), ?)`,
        [
          title,
          message,
          alertType,
          severity,
          relatedDisruptionId || null,
          relatedIncidentId || null,
          targetRouteId || null,
          targetLatitude || null,
          targetLongitude || null,
          targetRadiusKm || null,
          createdBy,
          expiresAt || defaultExpires,
        ]
      );
      return this.findAlertById(result.insertId);
    }

    db.assertFallbackAllowed();
    return db.memoryStore.createAlert({
      title,
      message,
      alertType,
      severity,
      relatedDisruptionId,
      relatedIncidentId,
      targetRouteId,
      targetLatitude,
      targetLongitude,
      targetRadiusKm,
      createdBy,
      expiresAt,
    });
  }

  /**
   * Get alert notification preferences for commuter
   */
  async getSubscriptions(userId) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        `SELECT id, user_id AS userId, subscription_type AS subscriptionType,
                route_id AS routeId, center_latitude AS centerLatitude,
                center_longitude AS centerLongitude, radius_km AS radiusKm,
                is_active AS isActive, created_at AS createdAt
         FROM alert_subscriptions
         WHERE user_id = ? AND is_active = TRUE`,
        [userId]
      );
      return rows.map((r) => ({
        ...r,
        centerLatitude: r.centerLatitude ? parseFloat(r.centerLatitude) : null,
        centerLongitude: r.centerLongitude ? parseFloat(r.centerLongitude) : null,
        radiusKm: r.radiusKm ? parseFloat(r.radiusKm) : null,
        isActive: Boolean(r.isActive),
      }));
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getSubscriptions(userId);
  }

  /**
   * Update or create alert subscription
   */
  async updateSubscription(userId, { subscriptionType = 'route', routeId, centerLatitude, centerLongitude, radiusKm }) {
    if (db.isLiveDb) {
      const [result] = await db.query(
        `INSERT INTO alert_subscriptions (
          user_id, subscription_type, route_id, center_latitude, center_longitude, radius_km, is_active, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, TRUE, NOW())`,
        [
          userId,
          subscriptionType,
          routeId || null,
          centerLatitude || null,
          centerLongitude || null,
          radiusKm || null,
        ]
      );
      return {
        id: result.insertId,
        userId,
        subscriptionType,
        routeId: routeId || null,
        centerLatitude: centerLatitude || null,
        centerLongitude: centerLongitude || null,
        radiusKm: radiusKm || null,
        isActive: true,
        createdAt: new Date().toISOString(),
      };
    }

    db.assertFallbackAllowed();
    return db.memoryStore.updateSubscription(userId, { subscriptionType, routeId, centerLatitude, centerLongitude, radiusKm });
  }

  /**
   * Register or refresh FCM device push token
   */
  async registerDeviceToken(userId, fcmToken, deviceType = 'android') {
    if (db.isLiveDb) {
      await db.query(
        `INSERT INTO device_tokens (user_id, fcm_token, device_type, last_active_at)
         VALUES (?, ?, ?, NOW())
         ON DUPLICATE KEY UPDATE user_id = VALUES(user_id), device_type = VALUES(device_type), last_active_at = NOW()`,
        [userId, fcmToken, deviceType]
      );
      return {
        userId,
        fcmToken,
        deviceType,
        lastActiveAt: new Date().toISOString(),
      };
    }

    db.assertFallbackAllowed();
    return db.memoryStore.registerDeviceToken(userId, fcmToken, deviceType);
  }

  /**
   * Record delivery audit entry
   */
  async createAlertDelivery({ alertId, userId, deviceTokenId, deliveryStatus = 'sent', fcmMessageId }) {
    if (db.isLiveDb) {
      const [result] = await db.query(
        `INSERT INTO alert_deliveries (
          alert_id, user_id, device_token_id, delivery_status, fcm_message_id, delivered_at, created_at
        ) VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
        [alertId, userId, deviceTokenId || null, deliveryStatus, fcmMessageId || null]
      );
      return {
        id: result.insertId,
        alertId,
        userId,
        deliveryStatus,
        fcmMessageId,
        deliveredAt: new Date().toISOString(),
      };
    }

    db.assertFallbackAllowed();
    const delivery = {
      id: db.memoryStore.nextDeliveryId++,
      alert_id: alertId,
      user_id: userId,
      device_token_id: deviceTokenId || null,
      delivery_status: deliveryStatus,
      fcm_message_id: fcmMessageId,
      delivered_at: new Date().toISOString(),
      created_at: new Date().toISOString(),
    };
    db.memoryStore.alertDeliveries.push(delivery);
    return delivery;
  }

  /**
   * Get alert deliveries audit log
   */
  async getAlertDeliveries({ alertId, userId } = {}) {
    if (db.isLiveDb) {
      let sql = 'SELECT * FROM alert_deliveries WHERE 1=1';
      const params = [];
      if (alertId) {
        sql += ' AND alert_id = ?';
        params.push(alertId);
      }
      if (userId) {
        sql += ' AND user_id = ?';
        params.push(userId);
      }
      sql += ' ORDER BY created_at DESC';

      const [rows] = await db.query(sql, params);
      return rows;
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getAlertDeliveries({ alertId, userId });
  }
}

module.exports = new AlertRepository();

