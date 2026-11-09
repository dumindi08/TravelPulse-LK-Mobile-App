/**
 * TravelPulse LK — Shared Database Configuration & Data Store
 * Owning Member: Suneth (Database Architecture, Reliability & Crowd Engine)
 * ---------------------------------------------------------------------------
 * Connects to MySQL 8.0+ when available, or provides a structured in-memory
 * relational store matching MySQL 8.0 schema for offline development & testing.
 *
 * Fully supports:
 *  - Module 1 (Nisal): Users, Routes, Stops, Schedules
 *  - Module 2 (Dumindi): Report categories, Community reports
 *  - Module 3 (Suneth): User reputations, Report votes, Reliability scores,
 *                       Crowd estimates, and Sliding-window crowd aggregations
 */

const { calculateReliability } = require('../engine/confidenceScorer');
const { findDuplicates } = require('../engine/duplicateDetector');
const { aggregateCrowdEstimates } = require('../engine/crowdEngine');

const categoriesSeed = [
  { id: 1, code: 'CROWD', name: 'Crowd Report', description: 'Real-time transit crowd density and wait times', default_severity: 'low', is_active: true },
  { id: 2, code: 'ROAD_CONDITION', name: 'Road Condition', description: 'Potholes, flooding, road closures, and hazards', default_severity: 'medium', is_active: true },
  { id: 3, code: 'TRANSPORT_TRACKING', name: 'Transport/Route Tracking', description: 'Bus and train operational movement and tracking', default_severity: 'low', is_active: true },
  { id: 4, code: 'SERVICE_DISRUPTION', name: 'Service Disruption', description: 'Cancellations, breakdowns, delays, and service interruptions', default_severity: 'high', is_active: true },
  { id: 5, code: 'ACCIDENT_INCIDENT', name: 'Accident/Incident', description: 'Traffic collisions, emergencies, and safety incidents', default_severity: 'critical', is_active: true },
  { id: 6, code: 'OTHER', name: 'Other', description: 'General commuter notices, lost & found, and feedback', default_severity: 'low', is_active: true },
];

const initialUserReputationsSeed = [
  { user_id: 1, reputation_score: 82.50, total_reports_submitted: 6, verified_reports_count: 5, rejected_reports_count: 0, total_votes_cast: 14 },
  { user_id: 2, reputation_score: 76.00, total_reports_submitted: 4, verified_reports_count: 3, rejected_reports_count: 0, total_votes_cast: 10 },
  { user_id: 3, reputation_score: 88.00, total_reports_submitted: 9, verified_reports_count: 8, rejected_reports_count: 0, total_votes_cast: 22 },
  { user_id: 4, reputation_score: 90.00, total_reports_submitted: 11, verified_reports_count: 10, rejected_reports_count: 0, total_votes_cast: 28 },
  { user_id: 5, reputation_score: 98.00, total_reports_submitted: 20, verified_reports_count: 19, rejected_reports_count: 0, total_votes_cast: 45 },
];

const initialReportsSeed = [
  {
    id: 101,
    user_id: 1,
    user_name: 'Kamal Perera',
    user_email: 'kamal@example.com',
    is_anonymous: false,
    category_id: 4,
    category_name: 'Service Disruption',
    route_id: 1,
    route_number: '138',
    stop_id: 104,
    stop_name: 'Town Hall / Viharamahadevi Park',
    latitude: 6.9147,
    longitude: 79.8653,
    location_description: 'Town Hall roundabout near Public Library',
    title: 'Bus Breakdown Blocking Center Lane',
    description: 'Route 138 SLTB bus broke down right after the roundabout. Traffic backing up towards Maradana and Borella.',
    disruption_reason: 'Vehicle Breakdown',
    media_url: null,
    status: 'verified',
    reliability_score: 84.0,
    confidence_status: 'verified',
    upvotes_count: 8,
    downvotes_count: 1,
    created_at: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
  {
    id: 102,
    user_id: 2,
    user_name: 'Dilshan Silva',
    user_email: 'dilshan@example.com',
    is_anonymous: true,
    category_id: 2,
    category_name: 'Road Condition',
    route_id: 2,
    route_number: '100',
    stop_id: null,
    stop_name: null,
    latitude: 6.8920,
    longitude: 79.8580,
    location_description: 'Bauddhaloka Mawatha near Thunmulla',
    title: 'Severe Waterlogging / Flash Flood',
    description: 'Heavy rain has flooded the junction with 1.5 feet of water. Low clearance three-wheelers and cars cannot pass. Buses moving slowly.',
    disruption_reason: 'Road Inundation / Flooding',
    media_url: null,
    status: 'verified',
    reliability_score: 92.0,
    confidence_status: 'verified',
    upvotes_count: 14,
    downvotes_count: 0,
    created_at: new Date(Date.now() - 70 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
  {
    id: 103,
    user_id: 1,
    user_name: 'Kamal Perera',
    user_email: 'kamal@example.com',
    is_anonymous: false,
    category_id: 1,
    category_name: 'Crowd Report',
    route_id: 1,
    route_number: '138',
    stop_id: 101,
    stop_name: 'Pettah Main Bus Stand',
    latitude: 6.9355,
    longitude: 79.8530,
    location_description: 'Route 138 bus bay',
    title: 'Heavy Evening Rush Hour Overcrowding',
    description: 'Huge queue extending over 50 meters. Buses arriving every 10 minutes but fill immediately.',
    disruption_reason: null,
    media_url: null,
    status: 'submitted',
    reliability_score: 60.0,
    confidence_status: 'plausible',
    upvotes_count: 3,
    downvotes_count: 0,
    created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    resolved_at: null,
  },
];

const initialReportVotesSeed = [
  { id: 1, report_id: 101, user_id: 2, vote_type: 'upvote', created_at: new Date(Date.now() - 20 * 60 * 1000).toISOString() },
  { id: 2, report_id: 101, user_id: 3, vote_type: 'upvote', created_at: new Date(Date.now() - 18 * 60 * 1000).toISOString() },
  { id: 3, report_id: 101, user_id: 4, vote_type: 'upvote', created_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() },
  { id: 4, report_id: 101, user_id: 5, vote_type: 'upvote', created_at: new Date(Date.now() - 12 * 60 * 1000).toISOString() },
  { id: 5, report_id: 102, user_id: 1, vote_type: 'upvote', created_at: new Date(Date.now() - 60 * 60 * 1000).toISOString() },
  { id: 6, report_id: 102, user_id: 3, vote_type: 'upvote', created_at: new Date(Date.now() - 55 * 60 * 1000).toISOString() },
  { id: 7, report_id: 102, user_id: 4, vote_type: 'upvote', created_at: new Date(Date.now() - 50 * 60 * 1000).toISOString() },
  { id: 8, report_id: 103, user_id: 2, vote_type: 'upvote', created_at: new Date(Date.now() - 10 * 60 * 1000).toISOString() },
  { id: 9, report_id: 103, user_id: 3, vote_type: 'upvote', created_at: new Date(Date.now() - 8 * 60 * 1000).toISOString() },
];

const initialCrowdEstimatesSeed = [
  { id: 1, user_id: 1, route_id: 1, stop_id: null, crowd_level: 'crowded', passenger_wait_time_minutes: 15, reported_at: new Date(Date.now() - 12 * 60 * 1000).toISOString() },
  { id: 2, user_id: 2, route_id: 1, stop_id: null, crowd_level: 'very_crowded', passenger_wait_time_minutes: 20, reported_at: new Date(Date.now() - 18 * 60 * 1000).toISOString() },
  { id: 3, user_id: 3, route_id: 1, stop_id: null, crowd_level: 'crowded', passenger_wait_time_minutes: 18, reported_at: new Date(Date.now() - 24 * 60 * 1000).toISOString() },
  { id: 4, user_id: 4, route_id: 2, stop_id: null, crowd_level: 'moderate', passenger_wait_time_minutes: 8, reported_at: new Date(Date.now() - 15 * 60 * 1000).toISOString() },
  { id: 5, user_id: 1, route_id: 2, stop_id: null, crowd_level: 'moderate', passenger_wait_time_minutes: 10, reported_at: new Date(Date.now() - 25 * 60 * 1000).toISOString() },
  { id: 6, user_id: 2, route_id: null, stop_id: 101, crowd_level: 'very_crowded', passenger_wait_time_minutes: 25, reported_at: new Date(Date.now() - 14 * 60 * 1000).toISOString() },
  { id: 7, user_id: 3, route_id: null, stop_id: 101, crowd_level: 'very_crowded', passenger_wait_time_minutes: 20, reported_at: new Date(Date.now() - 22 * 60 * 1000).toISOString() },
  { id: 8, user_id: 4, route_id: null, stop_id: 104, crowd_level: 'moderate', passenger_wait_time_minutes: 10, reported_at: new Date(Date.now() - 16 * 60 * 1000).toISOString() },
  { id: 9, user_id: 5, route_id: 3, stop_id: null, crowd_level: 'crowded', passenger_wait_time_minutes: 12, reported_at: new Date(Date.now() - 28 * 60 * 1000).toISOString() },
];

const initialCrowdAggregationsSeed = [
  { id: 1, route_id: 1, stop_id: null, time_slot: new Date().toISOString(), aggregated_crowd_level: 'very_crowded', sample_count: 8, confidence_score: 88.50, last_updated_at: new Date().toISOString() },
  { id: 2, route_id: 2, stop_id: null, time_slot: new Date().toISOString(), aggregated_crowd_level: 'moderate', sample_count: 5, confidence_score: 82.00, last_updated_at: new Date().toISOString() },
  { id: 3, route_id: 3, stop_id: null, time_slot: new Date().toISOString(), aggregated_crowd_level: 'crowded', sample_count: 6, confidence_score: 85.00, last_updated_at: new Date().toISOString() },
  { id: 4, route_id: null, stop_id: 101, time_slot: new Date().toISOString(), aggregated_crowd_level: 'very_crowded', sample_count: 9, confidence_score: 91.00, last_updated_at: new Date().toISOString() },
  { id: 5, route_id: null, stop_id: 104, time_slot: new Date().toISOString(), aggregated_crowd_level: 'moderate', sample_count: 4, confidence_score: 78.50, last_updated_at: new Date().toISOString() },
];

/**
 * In-Memory Database Store (active for fast, reliable unit testing & offline dev)
 */
class MemoryStore {
  constructor() {
    this.categories = [...categoriesSeed];
    this.reports = JSON.parse(JSON.stringify(initialReportsSeed));
    this.userReputations = JSON.parse(JSON.stringify(initialUserReputationsSeed));
    this.reportVotes = JSON.parse(JSON.stringify(initialReportVotesSeed));
    this.crowdEstimates = JSON.parse(JSON.stringify(initialCrowdEstimatesSeed));
    this.crowdAggregations = JSON.parse(JSON.stringify(initialCrowdAggregationsSeed));

    this.nextReportId = 104;
    this.nextVoteId = 10;
    this.nextEstimateId = 10;
    this.nextAggregationId = 6;
  }

  // ---------------------------------------------------------------------------
  // Categories (Dumindi Module)
  // ---------------------------------------------------------------------------
  getCategories() {
    return this.categories.filter((c) => c.is_active);
  }

  getCategoryById(id) {
    return this.categories.find((c) => c.id === Number(id));
  }

  // ---------------------------------------------------------------------------
  // Community Reports (Dumindi Module)
  // ---------------------------------------------------------------------------
  getReports({ categoryId, status, routeId }) {
    let result = [...this.reports];
    if (categoryId) {
      result = result.filter((r) => r.category_id === Number(categoryId));
    }
    if (status && status.toLowerCase() !== 'all') {
      result = result.filter((r) => r.status.toLowerCase() === status.toLowerCase());
    }
    if (routeId) {
      result = result.filter((r) => r.route_id === Number(routeId));
    }
    return result.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  getReportById(id) {
    return this.reports.find((r) => r.id === Number(id));
  }

  getReportsByUserId(userId) {
    return this.reports
      .filter((r) => r.user_id === Number(userId))
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  }

  createReport(data) {
    const category = this.getCategoryById(data.category_id);
    const categoryCode = category ? category.code : 'OTHER';

    // 1. Check for spatial-temporal duplicates and corroboration (Suneth's engine)
    const dupCheck = findDuplicates(
      {
        ...data,
        createdAt: new Date(),
      },
      this.reports
    );

    // 2. Fetch author reputation
    const authorRep = this.getUserReputation(data.user_id);
    const baseReputation = authorRep ? authorRep.reputation_score : 10.0;

    // 3. Compute initial reliability score
    const reliabilityResult = calculateReliability({
      baseReputation,
      upvotes: 1, // Author implicit initial confidence
      downvotes: 0,
      corroborations: dupCheck.corroborationCount,
      createdAt: new Date(),
      categoryCode,
    });

    const newReport = {
      id: this.nextReportId++,
      user_id: data.user_id,
      user_name: data.user_name || 'Commuter',
      user_email: data.user_email || 'commuter@travelpulse.lk',
      is_anonymous: Boolean(data.is_anonymous),
      category_id: data.category_id,
      category_name: category ? category.name : 'General Report',
      route_id: data.route_id ? Number(data.route_id) : null,
      route_number: data.route_number || null,
      stop_id: data.stop_id ? Number(data.stop_id) : null,
      stop_name: data.stop_name || null,
      latitude: Number(data.latitude),
      longitude: Number(data.longitude),
      location_description: data.location_description || '',
      title: data.title,
      description: data.description,
      disruption_reason: data.disruption_reason || null,
      media_url: data.media_url || null,
      status: reliabilityResult.confidenceStatus === 'verified' ? 'verified' : 'submitted',
      reliability_score: reliabilityResult.reliabilityScore,
      confidence_status: reliabilityResult.confidenceStatus,
      upvotes_count: 1,
      downvotes_count: 0,
      created_at: new Date().toISOString(),
      resolved_at: null,
    };

    this.reports.unshift(newReport);

    // Update author's report submission counter
    this.updateUserReputation(data.user_id, {
      total_reports_submitted: (authorRep?.total_reports_submitted || 0) + 1,
    });

    return newReport;
  }

  updateReport(id, updates) {
    const report = this.getReportById(id);
    if (!report) return null;
    Object.assign(report, updates);
    return report;
  }

  deleteReport(id) {
    const index = this.reports.findIndex((r) => r.id === Number(id));
    if (index === -1) return false;
    this.reports.splice(index, 1);
    // Remove associated votes
    this.reportVotes = this.reportVotes.filter((v) => v.report_id !== Number(id));
    return true;
  }

  // ---------------------------------------------------------------------------
  // Module 3: User Reputations (Suneth)
  // ---------------------------------------------------------------------------
  getUserReputation(userId) {
    const rep = this.userReputations.find((r) => r.user_id === Number(userId));
    if (!rep) {
      // Default initial reputation for newly registered commuters
      const defaultRep = {
        user_id: Number(userId),
        reputation_score: 10.00,
        total_reports_submitted: 0,
        verified_reports_count: 0,
        rejected_reports_count: 0,
        total_votes_cast: 0,
        updated_at: new Date().toISOString(),
      };
      this.userReputations.push(defaultRep);
      return defaultRep;
    }
    return rep;
  }

  updateUserReputation(userId, updates) {
    const rep = this.getUserReputation(userId);
    Object.assign(rep, updates, { updated_at: new Date().toISOString() });
    return rep;
  }

  // ---------------------------------------------------------------------------
  // Module 3: Report Peer Voting & Reliability (Suneth)
  // ---------------------------------------------------------------------------
  getUserVoteOnReport(reportId, userId) {
    return this.reportVotes.find(
      (v) => v.report_id === Number(reportId) && v.user_id === Number(userId)
    );
  }

  getVotesForReport(reportId) {
    return this.reportVotes.filter((v) => v.report_id === Number(reportId));
  }

  castReportVote({ reportId, userId, voteType }) {
    const report = this.getReportById(reportId);
    if (!report) {
      throw new Error('Report not found');
    }

    const existingVote = this.getUserVoteOnReport(reportId, userId);

    if (existingVote) {
      if (existingVote.vote_type === voteType) {
        // Toggle/remove vote if clicked again
        const voteIdx = this.reportVotes.indexOf(existingVote);
        this.reportVotes.splice(voteIdx, 1);

        if (voteType === 'upvote') {
          report.upvotes_count = Math.max(0, report.upvotes_count - 1);
        } else if (voteType === 'downvote') {
          report.downvotes_count = Math.max(0, report.downvotes_count - 1);
        }
      } else {
        // Switch vote
        if (existingVote.vote_type === 'upvote') {
          report.upvotes_count = Math.max(0, report.upvotes_count - 1);
        } else if (existingVote.vote_type === 'downvote') {
          report.downvotes_count = Math.max(0, report.downvotes_count - 1);
        }

        existingVote.vote_type = voteType;
        if (voteType === 'upvote') {
          report.upvotes_count += 1;
        } else if (voteType === 'downvote') {
          report.downvotes_count += 1;
        }
      }
    } else {
      // New vote
      const newVote = {
        id: this.nextVoteId++,
        report_id: Number(reportId),
        user_id: Number(userId),
        vote_type: voteType,
        created_at: new Date().toISOString(),
      };
      this.reportVotes.push(newVote);

      if (voteType === 'upvote') {
        report.upvotes_count += 1;
      } else if (voteType === 'downvote') {
        report.downvotes_count += 1;
      }

      // Update voter reputation metric
      const voterRep = this.getUserReputation(userId);
      this.updateUserReputation(userId, {
        total_votes_cast: voterRep.total_votes_cast + 1,
      });
    }

    // Recalculate report reliability score using Suneth's confidenceScorer
    const authorRep = this.getUserReputation(report.user_id);
    const category = this.getCategoryById(report.category_id);
    const categoryCode = category ? category.code : 'OTHER';

    // Find any corroborating reports in the system
    const dupCheck = findDuplicates(report, this.reports);

    const reliabilityResult = calculateReliability({
      baseReputation: authorRep ? authorRep.reputation_score : 10.0,
      upvotes: report.upvotes_count,
      downvotes: report.downvotes_count,
      corroborations: dupCheck.corroborationCount,
      createdAt: report.created_at,
      categoryCode,
    });

    report.reliability_score = reliabilityResult.reliabilityScore;
    report.confidence_status = reliabilityResult.confidenceStatus;

    if (reliabilityResult.confidenceStatus === 'verified' && report.status === 'submitted') {
      report.status = 'verified';
      // Reward author with positive reputation score
      this.updateUserReputation(report.user_id, {
        verified_reports_count: authorRep.verified_reports_count + 1,
        reputation_score: Math.min(100.0, authorRep.reputation_score + 2.5),
      });
    }

    return {
      report,
      userVote: this.getUserVoteOnReport(reportId, userId)?.vote_type || null,
      reliabilityResult,
    };
  }

  // ---------------------------------------------------------------------------
  // Module 3: Crowd Estimates & Aggregations (Suneth)
  // ---------------------------------------------------------------------------
  addCrowdEstimate(data) {
    const hasRoute = data.route_id !== null && data.route_id !== undefined;
    const hasStop = data.stop_id !== null && data.stop_id !== undefined;

    if ((hasRoute && hasStop) || (!hasRoute && !hasStop)) {
      throw new Error('Crowd estimate must specify either route_id OR stop_id, not both.');
    }

    const newEstimate = {
      id: this.nextEstimateId++,
      user_id: Number(data.user_id),
      route_id: hasRoute ? Number(data.route_id) : null,
      stop_id: hasStop ? Number(data.stop_id) : null,
      crowd_level: data.crowd_level,
      passenger_wait_time_minutes: data.passenger_wait_time_minutes ? Number(data.passenger_wait_time_minutes) : null,
      reported_at: new Date().toISOString(),
    };

    this.crowdEstimates.unshift(newEstimate);

    // Recompute real-time aggregation for the affected target
    this.recomputeCrowdAggregation({
      routeId: newEstimate.route_id,
      stopId: newEstimate.stop_id,
    });

    return newEstimate;
  }

  getCrowdEstimates({ routeId, stopId }) {
    return this.crowdEstimates.filter((e) => {
      if (routeId) return Number(e.route_id) === Number(routeId);
      if (stopId) return Number(e.stop_id) === Number(stopId);
      return true;
    });
  }

  recomputeCrowdAggregation({ routeId, stopId }) {
    const repsMap = {};
    for (const r of this.userReputations) {
      repsMap[r.user_id] = r.reputation_score;
    }

    const aggResult = aggregateCrowdEstimates({
      routeId,
      stopId,
      estimates: this.crowdEstimates,
      userReputations: repsMap,
      windowMinutes: 30,
    });

    // Check if aggregation record exists
    let existing = this.crowdAggregations.find((a) => {
      if (routeId) return Number(a.route_id) === Number(routeId);
      if (stopId) return Number(a.stop_id) === Number(stopId);
      return false;
    });

    if (existing) {
      Object.assign(existing, {
        aggregated_crowd_level: aggResult.aggregated_crowd_level,
        sample_count: aggResult.sample_count,
        confidence_score: aggResult.confidence_score,
        last_updated_at: new Date().toISOString(),
      });
      return existing;
    } else {
      const newAgg = {
        id: this.nextAggregationId++,
        route_id: aggResult.route_id,
        stop_id: aggResult.stop_id,
        time_slot: aggResult.time_slot,
        aggregated_crowd_level: aggResult.aggregated_crowd_level,
        sample_count: aggResult.sample_count,
        confidence_score: aggResult.confidence_score,
        last_updated_at: new Date().toISOString(),
      };
      this.crowdAggregations.push(newAgg);
      return newAgg;
    }
  }

  getCrowdAggregation({ routeId, stopId }) {
    return (
      this.crowdAggregations.find((a) => {
        if (routeId) return Number(a.route_id) === Number(routeId);
        if (stopId) return Number(a.stop_id) === Number(stopId);
        return false;
      }) || null
    );
  }

  getAllCrowdAggregations() {
    return [...this.crowdAggregations];
  }

  // ---------------------------------------------------------------------------
  // Reset store for unit tests
  // ---------------------------------------------------------------------------
  reset() {
    this.reports = JSON.parse(JSON.stringify(initialReportsSeed));
    this.userReputations = JSON.parse(JSON.stringify(initialUserReputationsSeed));
    this.reportVotes = JSON.parse(JSON.stringify(initialReportVotesSeed));
    this.crowdEstimates = JSON.parse(JSON.stringify(initialCrowdEstimatesSeed));
    this.crowdAggregations = JSON.parse(JSON.stringify(initialCrowdAggregationsSeed));
    this.nextReportId = 104;
    this.nextVoteId = 10;
    this.nextEstimateId = 10;
    this.nextAggregationId = 6;
  }
}

const memoryStore = new MemoryStore();

module.exports = {
  memoryStore,
  isLiveDb: false,
};
