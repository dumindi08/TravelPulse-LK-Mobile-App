/**
 * TravelPulse LK — Crowd Intelligence & Report Reliability Controller
 * Owning Member: Suneth
 */

const { memoryStore } = require('../config/db');

/**
 * 1. POST /api/v1/crowd/estimate
 * Submit real-time commuter crowd observation
 */
function submitCrowdEstimate(req, res) {
  const userId = req.user.id;
  const { routeId, stopId, crowdLevel, passengerWaitTimeMinutes } = req.body;

  try {
    const estimate = memoryStore.addCrowdEstimate({
      user_id: userId,
      route_id: routeId ? Number(routeId) : null,
      stop_id: stopId ? Number(stopId) : null,
      crowd_level: crowdLevel.toLowerCase(),
      passenger_wait_time_minutes: passengerWaitTimeMinutes !== undefined ? Number(passengerWaitTimeMinutes) : null,
    });

    const aggregation = memoryStore.getCrowdAggregation({
      routeId: estimate.route_id,
      stopId: estimate.stop_id,
    });

    return res.status(201).json({
      success: true,
      statusCode: 201,
      message: 'Crowd observation recorded and aggregated successfully.',
      data: {
        estimate: {
          id: estimate.id,
          userId: estimate.user_id,
          routeId: estimate.route_id,
          stopId: estimate.stop_id,
          crowdLevel: estimate.crowd_level,
          passengerWaitTimeMinutes: estimate.passenger_wait_time_minutes,
          reportedAt: estimate.reported_at,
        },
        aggregation: aggregation
          ? {
              targetType: aggregation.route_id ? 'route' : 'stop',
              targetId: aggregation.route_id || aggregation.stop_id,
              currentCrowdLevel: aggregation.aggregated_crowd_level,
              sampleCount: aggregation.sample_count,
              confidenceScore: aggregation.confidence_score,
              lastUpdatedAt: aggregation.last_updated_at,
            }
          : null,
      },
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: error.message || 'Failed to record crowd observation.',
      error: { code: 'CROWD_ESTIMATE_ERROR' },
    });
  }
}

/**
 * 2. GET /api/v1/crowd/routes/:routeId
 * Get current aggregated crowd level for a transport route
 */
function getRouteCrowd(req, res) {
  const routeId = Number(req.params.routeId);

  if (isNaN(routeId)) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Invalid routeId parameter.',
      error: { code: 'INVALID_ROUTE_ID' },
    });
  }

  let aggregation = memoryStore.getCrowdAggregation({ routeId });

  if (!aggregation) {
    // Return baseline aggregation
    aggregation = {
      route_id: routeId,
      stop_id: null,
      time_slot: new Date().toISOString(),
      aggregated_crowd_level: 'moderate',
      sample_count: 0,
      confidence_score: 30.0,
      last_updated_at: new Date().toISOString(),
      is_baseline: true,
    };
  }

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Route crowd aggregation retrieved successfully.',
    data: {
      targetType: 'route',
      targetId: routeId,
      currentCrowdLevel: aggregation.aggregated_crowd_level,
      sampleCount: aggregation.sample_count,
      confidenceScore: aggregation.confidence_score,
      lastUpdatedAt: aggregation.last_updated_at || aggregation.time_slot,
      isBaseline: Boolean(aggregation.is_baseline),
    },
  });
}

/**
 * 3. GET /api/v1/crowd/stops/:stopId
 * Get current aggregated crowd level for a stop
 */
function getStopCrowd(req, res) {
  const stopId = Number(req.params.stopId);

  if (isNaN(stopId)) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Invalid stopId parameter.',
      error: { code: 'INVALID_STOP_ID' },
    });
  }

  let aggregation = memoryStore.getCrowdAggregation({ stopId });

  if (!aggregation) {
    aggregation = {
      route_id: null,
      stop_id: stopId,
      time_slot: new Date().toISOString(),
      aggregated_crowd_level: 'moderate',
      sample_count: 0,
      confidence_score: 30.0,
      last_updated_at: new Date().toISOString(),
      is_baseline: true,
    };
  }

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Stop crowd aggregation retrieved successfully.',
    data: {
      targetType: 'stop',
      targetId: stopId,
      currentCrowdLevel: aggregation.aggregated_crowd_level,
      sampleCount: aggregation.sample_count,
      confidenceScore: aggregation.confidence_score,
      lastUpdatedAt: aggregation.last_updated_at || aggregation.time_slot,
      isBaseline: Boolean(aggregation.is_baseline),
    },
  });
}

/**
 * 4. GET /api/v1/crowd/aggregations
 * Get all active crowd aggregations across transit network
 */
function getAggregations(req, res) {
  const rawList = memoryStore.getAllCrowdAggregations();

  const formatted = rawList.map((a) => ({
    id: a.id,
    targetType: a.route_id ? 'route' : 'stop',
    targetId: a.route_id || a.stop_id,
    currentCrowdLevel: a.aggregated_crowd_level,
    sampleCount: a.sample_count,
    confidenceScore: a.confidence_score,
    timeSlot: a.time_slot,
    lastUpdatedAt: a.last_updated_at,
  }));

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'Active transit crowd aggregations retrieved successfully.',
    data: formatted,
  });
}

/**
 * 5. POST /api/v1/reports/:id/vote or /api/v1/crowd/vote
 * Cast peer verification vote on a community report
 */
function voteOnReport(req, res) {
  const reportId = Number(req.params.id || req.body.reportId);
  const userId = req.user.id;
  const { voteType } = req.body;

  if (isNaN(reportId)) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Invalid report ID.',
      error: { code: 'INVALID_REPORT_ID' },
    });
  }

  const report = memoryStore.getReportById(reportId);
  if (!report) {
    return res.status(404).json({
      success: false,
      statusCode: 404,
      message: `Community report #${reportId} not found.`,
      error: { code: 'REPORT_NOT_FOUND' },
    });
  }

  // Prevent author from voting on their own report
  if (Number(report.user_id) === Number(userId)) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: 'Authors cannot vote on their own community reports.',
      error: { code: 'SELF_VOTING_DISALLOWED' },
    });
  }

  try {
    const result = memoryStore.castReportVote({
      reportId,
      userId,
      voteType: voteType.toLowerCase(),
    });

    return res.status(200).json({
      success: true,
      statusCode: 200,
      message: `Vote '${voteType}' recorded successfully.`,
      data: {
        reportId: result.report.id,
        userVote: result.userVote,
        upvotesCount: result.report.upvotes_count,
        downvotesCount: result.report.downvotes_count,
        reliabilityScore: result.report.reliability_score,
        confidenceStatus: result.report.confidence_status,
        status: result.report.status,
      },
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: error.message || 'Failed to record vote.',
      error: { code: 'VOTE_ERROR' },
    });
  }
}

/**
 * 6. GET /api/v1/crowd/reputation
 * Retrieve commuter credibility score and contribution stats
 */
function getUserReputation(req, res) {
  const targetUserId = req.query.userId ? Number(req.query.userId) : req.user.id;
  const reputation = memoryStore.getUserReputation(targetUserId);

  return res.status(200).json({
    success: true,
    statusCode: 200,
    message: 'User reputation retrieved successfully.',
    data: {
      userId: reputation.user_id,
      reputationScore: reputation.reputation_score,
      totalReportsSubmitted: reputation.total_reports_submitted,
      verifiedReportsCount: reputation.verified_reports_count,
      rejectedReportsCount: reputation.rejected_reports_count,
      totalVotesCast: reputation.total_votes_cast,
      updatedAt: reputation.updated_at,
    },
  });
}

module.exports = {
  submitCrowdEstimate,
  getRouteCrowd,
  getStopCrowd,
  getAggregations,
  voteOnReport,
  getUserReputation,
};

