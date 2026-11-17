/**
 * TravelPulse LK — Journey Repository (Module 1: Nisal)
 * Handles database operations for commuter active travel journeys.
 */

const db = require('../config/db');

class JourneyRepository {
  /**
   * Start a new active journey for commuter
   */
  async createJourney({ userId, routeId, originStopId, destinationStopId, startTime }) {
    if (db.isLiveDb) {
      const [result] = await db.query(
        'INSERT INTO user_journeys (user_id, route_id, origin_stop_id, destination_stop_id, start_time, status) VALUES (?, ?, ?, ?, COALESCE(?, NOW()), "in_progress")',
        [userId, routeId, originStopId, destinationStopId, startTime || null]
      );
      return this.findJourneyById(result.insertId);
    }

    db.assertFallbackAllowed();
    return db.memoryStore.createJourney({ userId, routeId, originStopId, destinationStopId, startTime });
  }

  /**
   * Get all journeys for a specific user
   */
  async getJourneys(userId) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        `SELECT j.id, j.user_id AS userId, j.route_id AS routeId, j.origin_stop_id AS originStopId,
                j.destination_stop_id AS destinationStopId, j.start_time AS startTime, j.end_time AS endTime,
                j.status, j.created_at AS createdAt,
                r.route_number AS routeNumber, r.name AS routeName, r.transport_type AS transportType,
                s1.name AS originStopName, s2.name AS destinationStopName
         FROM user_journeys j
         LEFT JOIN transport_routes r ON j.route_id = r.id
         LEFT JOIN route_stops s1 ON j.origin_stop_id = s1.id
         LEFT JOIN route_stops s2 ON j.destination_stop_id = s2.id
         WHERE j.user_id = ?
         ORDER BY j.created_at DESC`,
        [userId]
      );
      return rows;
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getJourneys ? db.memoryStore.getJourneys(userId) : db.memoryStore.journeys.filter((j) => Number(j.userId) === Number(userId));
  }

  /**
   * Find journey by ID with route and stops metadata
   */
  async findJourneyById(id) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        `SELECT j.id, j.user_id AS userId, j.route_id AS routeId, j.origin_stop_id AS originStopId,
                j.destination_stop_id AS destinationStopId, j.start_time AS startTime, j.end_time AS endTime,
                j.status, j.created_at AS createdAt,
                r.route_number AS routeNumber, r.name AS routeName, r.transport_type AS transportType,
                s1.name AS originStopName, s2.name AS destinationStopName
         FROM user_journeys j
         LEFT JOIN transport_routes r ON j.route_id = r.id
         LEFT JOIN route_stops s1 ON j.origin_stop_id = s1.id
         LEFT JOIN route_stops s2 ON j.destination_stop_id = s2.id
         WHERE j.id = ?`,
        [id]
      );
      return rows && rows.length > 0 ? rows[0] : null;
    }

    db.assertFallbackAllowed();
    return db.memoryStore.findJourneyById(id);
  }

  /**
   * Find currently active in-progress journey for a user
   */
  async getActiveJourney(userId) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        `SELECT j.id, j.user_id AS userId, j.route_id AS routeId, j.origin_stop_id AS originStopId,
                j.destination_stop_id AS destinationStopId, j.start_time AS startTime, j.end_time AS endTime,
                j.status, j.created_at AS createdAt,
                r.route_number AS routeNumber, r.name AS routeName, r.transport_type AS transportType,
                s1.name AS originStopName, s2.name AS destinationStopName
         FROM user_journeys j
         LEFT JOIN transport_routes r ON j.route_id = r.id
         LEFT JOIN route_stops s1 ON j.origin_stop_id = s1.id
         LEFT JOIN route_stops s2 ON j.destination_stop_id = s2.id
         WHERE j.user_id = ? AND j.status = 'in_progress'
         ORDER BY j.created_at DESC LIMIT 1`,
        [userId]
      );
      return rows && rows.length > 0 ? rows[0] : null;
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getActiveJourney(userId);
  }

  /**
   * Complete an in-progress journey
   */
  async completeJourney(id, userId) {
    if (db.isLiveDb) {
      const [result] = await db.query(
        'UPDATE user_journeys SET status = "completed", end_time = NOW() WHERE id = ? AND user_id = ? AND status = "in_progress"',
        [id, userId]
      );
      if (result.affectedRows === 0) return null;
      return this.findJourneyById(id);
    }

    db.assertFallbackAllowed();
    return db.memoryStore.completeJourney(id, userId);
  }

  /**
   * Update journey status (e.g. 'completed', 'cancelled')
   */
  async updateJourneyStatus(id, status) {
    if (db.isLiveDb) {
      const isTerminal = status === 'completed' || status === 'cancelled';
      await db.query(
        'UPDATE user_journeys SET status = ?, end_time = CASE WHEN ? THEN NOW() ELSE end_time END WHERE id = ?',
        [status, isTerminal, id]
      );
      return this.findJourneyById(id);
    }

    db.assertFallbackAllowed();
    return db.memoryStore.updateJourneyStatus(id, status);
  }

  /**
   * Cancel an in-progress journey for commuter
   */
  async cancelJourney(id, userId) {
    if (db.isLiveDb) {
      const [result] = await db.query(
        'UPDATE user_journeys SET status = "cancelled", end_time = NOW() WHERE id = ? AND user_id = ? AND status = "in_progress"',
        [id, userId]
      );
      if (result.affectedRows === 0) return null;
      return this.findJourneyById(id);
    }

    db.assertFallbackAllowed();
    return db.memoryStore.cancelJourney(id, userId);
  }
}

module.exports = new JourneyRepository();
