/**
 * TravelPulse LK — Incident Repository (Module 4: Thimaya)
 * Handles database operations for road hazards, incidents, and report promotions.
 */

const db = require('../config/db');

class IncidentRepository {
  /**
   * Get active road incidents with optional filtering
   */
  async getIncidents({ incidentType, severity, activeOnly = true } = {}) {
    if (db.isLiveDb) {
      let sql = `
        SELECT id, source_report_id AS sourceReportId, incident_type AS incidentType,
               latitude, longitude, address_text AS addressText, severity,
               radius_meters AS radiusMeters, is_active AS isActive,
               verified_by_user_id AS verifiedByUserId, start_time AS startTime,
               end_time AS endTime, created_at AS createdAt
        FROM road_incidents
        WHERE 1=1
      `;
      const params = [];

      if (incidentType) {
        sql += ' AND incident_type = ?';
        params.push(incidentType);
      }
      if (severity) {
        sql += ' AND severity = ?';
        params.push(severity);
      }
      if (activeOnly) {
        sql += ' AND is_active = TRUE';
      }

      sql += ' ORDER BY created_at DESC';

      const [rows] = await db.query(sql, params);
      return rows.map((r) => ({
        id: r.id,
        sourceReportId: r.sourceReportId || r.source_report_id,
        incidentType: r.incidentType || r.incident_type,
        latitude: parseFloat(r.latitude),
        longitude: parseFloat(r.longitude),
        addressText: r.addressText || r.address_text,
        severity: r.severity,
        radiusMeters: r.radiusMeters || r.radius_meters,
        isActive: Boolean(r.isActive !== undefined ? r.isActive : r.is_active),
        verifiedByUserId: r.verifiedByUserId || r.verified_by_user_id,
        startTime: r.startTime || r.start_time,
        endTime: r.endTime || r.end_time,
        createdAt: r.createdAt || r.created_at,
      }));
    }

    db.assertFallbackAllowed();
    return db.memoryStore.getIncidents({ incidentType, severity, activeOnly });
  }

  /**
   * Find single road incident by ID
   */
  async findIncidentById(id) {
    if (db.isLiveDb) {
      const [rows] = await db.query(
        `SELECT id, source_report_id AS sourceReportId, incident_type AS incidentType,
                latitude, longitude, address_text AS addressText, severity,
                radius_meters AS radiusMeters, is_active AS isActive,
                verified_by_user_id AS verifiedByUserId, start_time AS startTime,
                end_time AS endTime, created_at AS createdAt
         FROM road_incidents
         WHERE id = ?`,
        [id]
      );
      if (!rows || rows.length === 0) return null;
      const r = rows[0];
      return {
        id: r.id,
        sourceReportId: r.sourceReportId || r.source_report_id,
        incidentType: r.incidentType || r.incident_type,
        latitude: parseFloat(r.latitude),
        longitude: parseFloat(r.longitude),
        addressText: r.addressText || r.address_text,
        severity: r.severity,
        radiusMeters: r.radiusMeters || r.radius_meters,
        isActive: Boolean(r.isActive !== undefined ? r.isActive : r.is_active),
        verifiedByUserId: r.verifiedByUserId || r.verified_by_user_id,
        startTime: r.startTime || r.start_time,
        endTime: r.endTime || r.end_time,
        createdAt: r.createdAt || r.created_at,
      };
    }

    db.assertFallbackAllowed();
    return db.memoryStore.findIncidentById(id);
  }

  /**
   * Directly create a road incident
   */
  async createIncident({
    sourceReportId,
    incidentType,
    latitude,
    longitude,
    addressText,
    severity = 'medium',
    radiusMeters = 100,
    verifiedByUserId,
  }) {
    if (db.isLiveDb) {
      const [result] = await db.query(
        `INSERT INTO road_incidents (
          source_report_id, incident_type, latitude, longitude, address_text,
          severity, radius_meters, is_active, verified_by_user_id, start_time, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, TRUE, ?, NOW(), NOW())`,
        [
          sourceReportId || null,
          incidentType,
          latitude,
          longitude,
          addressText || null,
          severity,
          radiusMeters,
          verifiedByUserId || null,
        ]
      );
      return this.findIncidentById(result.insertId);
    }

    db.assertFallbackAllowed();
    return db.memoryStore.createIncident({
      sourceReportId,
      incidentType,
      latitude,
      longitude,
      addressText,
      severity,
      radiusMeters,
      verifiedByUserId,
    });
  }

  /**
   * Promote verified community report into confirmed road incident within a transaction
   */
  async promoteReportToIncident(reportId, userId, overrideData = {}) {
    if (db.isLiveDb) {
      const connection = await db.getConnection();
      try {
        await connection.beginTransaction();

        // 1. Fetch source report
        const [reportRows] = await connection.query(
          'SELECT * FROM community_reports WHERE id = ?',
          [reportId]
        );
        if (!reportRows || reportRows.length === 0) {
          await connection.rollback();
          return { error: 'REPORT_NOT_FOUND', statusCode: 404 };
        }
        const report = reportRows[0];

        // 2. Map category code to incident_type
        let mappedType = 'congestion';
        if (overrideData.incidentType) {
          mappedType = overrideData.incidentType;
        } else if (report.category_id === 2) {
          mappedType = 'flooding';
        } else if (report.category_id === 5) {
          mappedType = 'accident';
        } else if (report.category_id === 4) {
          mappedType = 'road_closure';
        }

        // 3. Mark report as verified if not yet
        await connection.query(
          "UPDATE community_reports SET status = 'verified' WHERE id = ?",
          [reportId]
        );

        // 4. Insert into road_incidents
        const [insertResult] = await connection.query(
          `INSERT INTO road_incidents (
            source_report_id, incident_type, latitude, longitude, address_text,
            severity, radius_meters, is_active, verified_by_user_id, start_time, created_at
          ) VALUES (?, ?, ?, ?, ?, ?, ?, TRUE, ?, NOW(), NOW())`,
          [
            reportId,
            mappedType,
            overrideData.latitude || report.latitude,
            overrideData.longitude || report.longitude,
            overrideData.addressText || report.location_description,
            overrideData.severity || 'high',
            overrideData.radiusMeters || 150,
            userId,
          ]
        );

        await connection.commit();

        return this.findIncidentById(insertResult.insertId);
      } catch (err) {
        await connection.rollback();
        throw err;
      } finally {
        connection.release();
      }
    }

    db.assertFallbackAllowed();
    return db.memoryStore.promoteReportToIncident(reportId, userId, overrideData);
  }
}

module.exports = new IncidentRepository();

