/**
 * TravelPulse LK — Route Repository (Module 1: Nisal)
 * Handles database operations for transit routes, stops, stop sequences, and schedules.
 */

const db = require('../config/db');

class RouteRepository {
  /**
   * Get all active transit routes with optional transport type and city filtering
   */
  async getAllRoutes({ transportType, origin, destination, activeOnly = true } = {}) {
    if (db.isLiveDb) {
      let sql = `
        SELECT r.id, r.route_number AS routeNumber, r.name, r.transport_type AS transportType,
               r.operator, r.origin_city AS originCity, r.destination_city AS destinationCity,
               r.is_active AS isActive, r.created_at AS createdAt,
               ca.aggregated_crowd_level AS currentCrowdLevel
        FROM transport_routes r
        LEFT JOIN (
          SELECT route_id, aggregated_crowd_level
          FROM crowd_aggregations
          WHERE route_id IS NOT NULL
          ORDER BY last_updated_at DESC
        ) ca ON r.id = ca.route_id
        WHERE 1=1
      `;
      const params = [];

      if (transportType && transportType.toLowerCase() !== 'all') {
        sql += ' AND r.transport_type = ?';
        params.push(transportType);
      }
      if (origin) {
        sql += ' AND (r.origin_city LIKE ? OR r.name LIKE ?)';
        params.push(`%${origin}%`, `%${origin}%`);
      }
      if (destination) {
        sql += ' AND (r.destination_city LIKE ? OR r.name LIKE ?)';
        params.push(`%${destination}%`, `%${destination}%`);
      }
      if (activeOnly) {
        sql += ' AND r.is_active = TRUE';
      }
      sql += ' GROUP BY r.id ORDER BY r.id ASC';

      const [routes] = await db.query(sql, params);

      return routes.map((r) => ({
        ...r,
        isActive: Boolean(r.isActive),
        currentCrowdLevel: r.currentCrowdLevel || 'moderate',
      }));
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getRoutes({ transportType, origin, destination });
  }

  /**
   * Get single route detail with full ordered stop sequence and timetables
   */
  async getRouteById(id) {
    if (db.isLiveDb) {
      const [routes] = await db.query(
        'SELECT id, route_number AS routeNumber, name, transport_type AS transportType, operator, origin_city AS originCity, destination_city AS destinationCity, is_active AS isActive, created_at AS createdAt FROM transport_routes WHERE id = ?',
        [id]
      );
      if (!routes || routes.length === 0) return null;
      const r = routes[0];

      // Ordered stops sequence
      const [stops] = await db.query(
        `SELECT rss.stop_order AS stopOrder, rss.distance_from_prev_km AS distanceFromPrevKm, rss.est_minutes_from_prev AS estMinutesFromPrev,
                s.id, s.name, s.name AS stopName, s.stop_code AS stopCode, s.latitude, s.longitude, s.city, s.is_active AS isActive
         FROM route_stop_sequences rss
         JOIN route_stops s ON rss.stop_id = s.id
         WHERE rss.route_id = ?
         ORDER BY rss.stop_order ASC`,
        [id]
      );

      // Timetables / Schedules
      const [schedules] = await db.query(
        'SELECT id, departure_time AS departureTime, arrival_time AS arrivalTime, day_of_week AS dayOfWeek, trip_direction AS tripDirection, is_active AS isActive FROM route_schedules WHERE route_id = ? AND is_active = TRUE ORDER BY departure_time ASC',
        [id]
      );

      // Latest crowd aggregation
      const [crowdAgg] = await db.query(
        'SELECT aggregated_crowd_level FROM crowd_aggregations WHERE route_id = ? ORDER BY last_updated_at DESC LIMIT 1',
        [id]
      );

      return {
        ...r,
        isActive: Boolean(r.isActive),
        stops: stops.map((s) => ({
          ...s,
          latitude: parseFloat(s.latitude),
          longitude: parseFloat(s.longitude),
        })),
        schedules,
        currentCrowdLevel: crowdAgg && crowdAgg.length > 0 ? crowdAgg[0].aggregated_crowd_level : 'moderate',
      };
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getRouteById(id);
  }

  /**
   * Get master stops catalog
   */
  async getStops() {
    if (db.isLiveDb) {
      const [stops] = await db.query(
        'SELECT id, name, stop_code AS stopCode, latitude, longitude, city, is_active AS isActive FROM route_stops WHERE is_active = TRUE ORDER BY name ASC'
      );
      return stops.map((s) => ({
        ...s,
        latitude: parseFloat(s.latitude),
        longitude: parseFloat(s.longitude),
      }));
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getStops ? db.memoryStore.getStops() : db.memoryStore.stops;
  }

  /**
   * Get schedules for a specific route
   */
  async getSchedulesByRoute(routeId, { direction = 'outbound', dayOfWeek = 'all' } = {}) {
    if (db.isLiveDb) {
      let sql = 'SELECT id, route_id AS routeId, departure_time AS departureTime, arrival_time AS arrivalTime, day_of_week AS dayOfWeek, trip_direction AS tripDirection, is_active AS isActive FROM route_schedules WHERE route_id = ? AND is_active = TRUE';
      const params = [routeId];

      if (direction && direction !== 'all') {
        sql += ' AND trip_direction = ?';
        params.push(direction);
      }
      if (dayOfWeek && dayOfWeek !== 'all') {
        sql += ' AND (day_of_week = ? OR day_of_week = "all")';
        params.push(dayOfWeek);
      }
      sql += ' ORDER BY departure_time ASC';

      const [rows] = await db.query(sql, params);
      return rows;
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getRouteSchedules ? db.memoryStore.getRouteSchedules(routeId, { direction, dayOfWeek }) : db.memoryStore.getSchedulesByRoute(routeId);
  }
}

module.exports = new RouteRepository();
