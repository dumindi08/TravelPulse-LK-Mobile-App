/**
 * TravelPulse LK — Community Report Controller
 * Module 2: Community Reporting & Transport Disruption Management (Dumindi)
 */

const { memoryStore } = require('../config/db');

/**
 * Helper to mask anonymous reporter details in public views
 */
function sanitizeReportForPublic(report, requestingUserId = null, isStaff = false) {
  const isAuthor = requestingUserId !== null && Number(requestingUserId) === Number(report.user_id);
  const canSeeIdentity = isAuthor || isStaff;

  const sanitized = {
    id: report.id,
    userId: canSeeIdentity ? report.user_id : null,
    userName: report.is_anonymous && !canSeeIdentity ? 'Anonymous Commuter' : report.user_name,
    isAnonymous: Boolean(report.is_anonymous),
    categoryId: report.category_id,
    categoryName: report.category_name,
    routeId: report.route_id,
    routeNumber: report.route_number,
    stopId: report.stop_id,
    stopName: report.stop_name,
    latitude: report.latitude,
    longitude: report.longitude,
    locationDescription: report.location_description,
    title: report.title,
    description: report.description,
    disruptionReason: report.disruption_reason,
    mediaUrl: report.media_url,
    status: report.status,
    reliabilityScore: report.reliability_score,
    confidenceStatus: report.confidence_status,
    upvotesCount: report.upvotes_count,
    downvotesCount: report.downvotes_count,
    isOwnReport: isAuthor,
    createdAt: report.created_at,
    resolvedAt: report.resolved_at,
  };

  return sanitized;
}

/**
 * 1. GET /api/v1/reports/categories
 * Retrieve master report taxonomy (6 categories)
 */
function getCategories(req, res) {
  const categories = memoryStore.getCategories();
  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Report categories retrieved successfully',
    data: categories.map((c) => ({
      id: c.id,
      code: c.code,
      name: c.name,
      description: c.description,
      defaultSeverity: c.default_severity,
    })),
  });
}

/**
 * 2. GET /api/v1/reports
 * Retrieve public community reports with optional filtering & anonymous masking
 */
function getPublicReports(req, res) {
  const { categoryId, status, routeId, page = 1, limit = 20 } = req.query;
  const currentUserId = req.user ? req.user.id : null;
  const isStaff = req.user ? (req.user.role === 'moderator' || req.user.role === 'admin') : false;

  const rawReports = memoryStore.getReports({
    categoryId: categoryId ? Number(categoryId) : null,
    status,
    routeId: routeId ? Number(routeId) : null,
  });

  const sanitized = rawReports.map((r) => sanitizeReportForPublic(r, currentUserId, isStaff));

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Community reports retrieved successfully',
    data: sanitized,
    meta: {
      page: Number(page),
      limit: Number(limit),
      total: sanitized.length,
    },
  });
}

/**
 * 3. GET /api/v1/reports/:id
 * Retrieve a single report by ID
 */
function getReportById(req, res) {
  const reportId = Number(req.params.id);
  const currentUserId = req.user ? req.user.id : null;
  const isStaff = req.user ? (req.user.role === 'moderator' || req.user.role === 'admin') : false;

  const report = memoryStore.getReportById(reportId);
  if (!report) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Community report #${reportId} not found.`,
      error: { code: 'RESOURCE_NOT_FOUND' },
    });
  }

  const sanitized = sanitizeReportForPublic(report, currentUserId, isStaff);
  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Report details retrieved successfully',
    data: sanitized,
  });
}

/**
 * 4. GET /api/v1/reports/my-reports
 * Retrieve all reports authored by the authenticated commuter
 */
function getMyReports(req, res) {
  const userId = req.user.id;
  const reports = memoryStore.getReportsByUserId(userId);

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Authored reports retrieved successfully',
    data: reports.map((r) => ({
      id: r.id,
      userId: r.user_id,
      userName: r.user_name,
      isAnonymous: Boolean(r.is_anonymous),
      categoryId: r.category_id,
      categoryName: r.category_name,
      routeId: r.route_id,
      routeNumber: r.route_number,
      stopId: r.stop_id,
      stopName: r.stop_name,
      latitude: r.latitude,
      longitude: r.longitude,
      locationDescription: r.location_description,
      title: r.title,
      description: r.description,
      disruptionReason: r.disruption_reason,
      mediaUrl: r.media_url,
      status: r.status,
      reliabilityScore: r.reliability_score,
      confidenceStatus: r.confidence_status,
      upvotesCount: r.upvotes_count,
      downvotesCount: r.downvotes_count,
      isOwnReport: true,
      createdAt: r.created_at,
      resolvedAt: r.resolved_at,
    })),
    meta: {
      total: reports.length,
    },
  });
}

/**
 * 5. POST /api/v1/reports
 * Create a new community report (Enforces req.user.id ownership!)
 */
function createReport(req, res) {
  const {
    categoryId,
    routeId,
    routeNumber,
    stopId,
    stopName,
    latitude,
    longitude,
    locationDescription,
    title,
    description,
    disruptionReason,
    isAnonymous,
    mediaUrl,
  } = req.body;

  // IMPORTANT: Obtain userId strictly from authenticated JWT, NEVER trust client body!
  const userId = req.user.id;
  const userName = req.user.name || 'Commuter';
  const userEmail = req.user.email || '';

  const newReport = memoryStore.createReport({
    user_id: userId,
    user_name: userName,
    user_email: userEmail,
    is_anonymous: Boolean(isAnonymous),
    category_id: Number(categoryId),
    route_id: routeId ? Number(routeId) : null,
    route_number: routeNumber || null,
    stop_id: stopId ? Number(stopId) : null,
    stop_name: stopName || null,
    latitude: Number(latitude),
    longitude: Number(longitude),
    location_description: locationDescription || '',
    title: title.trim(),
    description: description.trim(),
    disruption_reason: disruptionReason ? disruptionReason.trim() : null,
    media_url: mediaUrl || null,
  });

  return res.status(201).json({
    success: true,
    statusCode: 201,
    message: 'Community report created successfully',
    data: sanitizeReportForPublic(newReport, userId, false),
  });
}

/**
 * 6. PATCH /api/v1/reports/:id
 * Update an existing report (Requires ownership or moderator role)
 */
function updateReport(req, res) {
  const reportId = Number(req.params.id);
  const userId = req.user.id;
  const isStaff = req.user.role === 'moderator' || req.user.role === 'admin';

  const existing = memoryStore.getReportById(reportId);
  if (!existing) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Report #${reportId} not found.`,
      error: { code: 'RESOURCE_NOT_FOUND' },
    });
  }

  // Enforce ownership: only the author or moderator can update
  if (existing.user_id !== userId && !isStaff) {
    return res.status(403).json({
      success: false,
      statusCode: 403,
      message: 'Unauthorized. You can only update reports that you have authored.',
      error: { code: 'FORBIDDEN_RESOURCE' },
    });
  }

  const updates = {};
  if (req.body.title) updates.title = req.body.title.trim();
  if (req.body.description) updates.description = req.body.description.trim();
  if (req.body.status && isStaff) updates.status = req.body.status;
  if (req.body.locationDescription !== undefined) updates.location_description = req.body.locationDescription;

  const updated = memoryStore.updateReport(reportId, updates);
  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Report updated successfully',
    data: sanitizeReportForPublic(updated, userId, isStaff),
  });
}

/**
 * 7. DELETE /api/v1/reports/:id
 * Delete an owned report (Strictly checks req.user.id against report.user_id!)
 */
function deleteReport(req, res) {
  const reportId = Number(req.params.id);
  const userId = req.user.id;
  const isStaff = req.user.role === 'moderator' || req.user.role === 'admin';

  const existing = memoryStore.getReportById(reportId);
  if (!existing) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Report #${reportId} not found.`,
      error: { code: 'RESOURCE_NOT_FOUND' },
    });
  }

  // Strict ownership check: Must be report author, or moderator/admin
  if (existing.user_id !== userId && !isStaff) {
    return res.status(403).json({
      success: false,
      statusCode: 403,
      message: 'Unauthorized. You can only delete reports that you have authored.',
      error: { code: 'FORBIDDEN_RESOURCE' },
    });
  }

  memoryStore.deleteReport(reportId);

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Report deleted successfully',
    data: {
      deletedReportId: reportId,
    },
  });
}

module.exports = {
  getCategories,
  getPublicReports,
  getReportById,
  getMyReports,
  createReport,
  updateReport,
  deleteReport,
};

