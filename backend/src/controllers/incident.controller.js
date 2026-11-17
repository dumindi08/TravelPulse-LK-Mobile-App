/**
 * TravelPulse LK — Road Incident Controller
 * Module 4: Road Conditions, Maps & Alerts (Thimaya)
 */

const { incidentRepository } = require('../repositories');
const db = require('../config/db');
const { memoryStore } = require('../config/db');

/**
 * 1. GET /api/v1/incidents
 * Retrieve active road incidents and hazards for map visualization
 */
async function getIncidents(req, res) {
  const { incidentType, severity, isActive = 'true' } = req.query;

  if (db.isLiveDb) {
    try {
      const incidents = await incidentRepository.getIncidents({
        incidentType,
        severity,
        activeOnly: isActive === 'true',
      });
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'Road incidents retrieved successfully.',
        data: incidents,
        meta: { count: incidents.length },
      });
    } catch (err) {
      console.error('[IncidentController.getIncidents] Error:', err);
      return res.status(500).json({ success: false, statusCode: 500, message: 'Database error' });
    }
  }

  db.assertFallbackAllowed();
  const rawList = memoryStore.getRoadIncidents({
    incidentType,
    severity,
    isActive,
  });

  const formatted = rawList.map((i) => ({
    id: i.id,
    sourceReportId: i.source_report_id,
    incidentType: i.incident_type,
    latitude: i.latitude,
    longitude: i.longitude,
    addressText: i.address_text,
    severity: i.severity,
    radiusMeters: i.radius_meters,
    isActive: i.is_active,
    verifiedByUserId: i.verified_by_user_id,
    startTime: i.start_time,
    endTime: i.end_time,
    createdAt: i.created_at,
  }));

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Road incidents retrieved successfully.',
    data: formatted,
    meta: { count: formatted.length },
  });
}

/**
 * 2. GET /api/v1/incidents/:id
 * Retrieve single road incident
 */
async function getIncidentById(req, res) {
  const id = Number(req.params.id);

  if (db.isLiveDb) {
    try {
      const incident = await incidentRepository.findIncidentById(id);
      if (!incident) {
        return res.status(404).json({
          success: false,
          statusCode: 404,
          message: `Road incident #${id} not found.`,
          error: { code: 'INCIDENT_NOT_FOUND' },
        });
      }
      return res.status(200).json({
        success: true,
        statusCode: 200,
        message: 'Road incident loaded successfully.',
        data: incident,
      });
    } catch (err) {
      console.error('[IncidentController.getIncidentById] Error:', err);
      return res.status(500).json({ success: false, statusCode: 500, message: 'Database error' });
    }
  }

  db.assertFallbackAllowed();
  const incident = memoryStore.getRoadIncidentById(id);
  if (!incident) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Road incident #${id} not found.`,
      error: { code: 'INCIDENT_NOT_FOUND' },
    });
  }

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Road incident loaded successfully.',
    data: {
      id: incident.id,
      sourceReportId: incident.source_report_id,
      incidentType: incident.incident_type,
      latitude: incident.latitude,
      longitude: incident.longitude,
      addressText: incident.address_text,
      severity: incident.severity,
      radiusMeters: incident.radius_meters,
      isActive: incident.is_active,
      verifiedByUserId: incident.verified_by_user_id,
      startTime: incident.start_time,
      endTime: incident.end_time,
      createdAt: incident.created_at,
    },
  });
}

/**
 * 3. POST /api/v1/incidents/promote/:reportId
 * Promotes a community report to a confirmed road incident.
 */
async function promoteReport(req, res) {
  const reportId = Number(req.params.reportId);
  const user = req.user;

  if (db.isLiveDb) {
    try {
      // Check moderator authorization or high reliability
      const incident = await incidentRepository.promoteReportToIncident(reportId, user.id);
      if (incident.error === 'REPORT_NOT_FOUND') {
        return res.status(404).json({
          success: false,
          statusCode: 404,
          message: `Community report #${reportId} not found.`,
          error: { code: 'REPORT_NOT_FOUND' },
        });
      }

      return res.status(201).json({
        success: true,
        statusCode: 201,
        message: `Community report #${reportId} promoted to confirmed road incident #${incident.id}.`,
        data: incident,
      });
    } catch (error) {
      console.error('[IncidentController.promoteReport] Error:', error);
      return res.status(400).json({
        success: false,
        statusCode: 400,
        message: error.message || 'Failed to promote report.',
        error: { code: 'REPORT_PROMOTION_ERROR' },
      });
    }
  }

  db.assertFallbackAllowed();
  try {
    const incident = memoryStore.promoteReportToIncident(reportId, user);
    return res.status(201).json({
      success: true,
      statusCode: 201,
      message: `Community report #${reportId} promoted to confirmed road incident #${incident.id}.`,
      data: {
        id: incident.id,
        sourceReportId: incident.source_report_id,
        incidentType: incident.incident_type,
        latitude: incident.latitude,
        longitude: incident.longitude,
        addressText: incident.address_text,
        severity: incident.severity,
        radiusMeters: incident.radius_meters,
        isActive: incident.is_active,
        startTime: incident.start_time,
      },
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: error.message || 'Failed to promote report.',
      error: { code: 'REPORT_PROMOTION_ERROR' },
    });
  }
}

module.exports = {
  getIncidents,
  getIncidentById,
  promoteReport,
};
