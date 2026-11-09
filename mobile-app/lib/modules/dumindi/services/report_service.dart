import 'dart:async';
import '../../../core/models/api_response.dart';
import '../models/community_report_model.dart';
import '../models/disruption_model.dart';

/// TravelPulse LK — Community Reporting Service (Dumindi)
/// ---------------------------------------------------------------------------
/// [TEMPORARY MOCK REPOSITORY — FOR OFFLINE DEVELOPMENT & TESTING]
/// Implements community incident reporting, disruption management,
/// anonymous submission handling, ownership verification for deletion,
/// and Suneth's peer voting & reliability recalculation hooks.
/// ---------------------------------------------------------------------------
class ReportService {
  // Seeded mock reports for Colombo transit network
  static final List<CommunityReportModel> _reports = [
    CommunityReportModel(
      id: 101,
      userId: 1, // Kamal Perera
      userName: 'Kamal Perera',
      isAnonymous: false,
      categoryId: 4,
      categoryName: 'Service Disruption',
      routeId: 1,
      routeNumber: '138',
      stopId: 104,
      stopName: 'Town Hall / Viharamahadevi Park',
      latitude: 6.9147,
      longitude: 79.8653,
      locationDescription: 'Town Hall roundabout near Public Library',
      title: 'Bus Breakdown Blocking Center Lane',
      description: 'Route 138 SLTB bus broke down right after the roundabout. Traffic backing up towards Maradana and Borella.',
      disruptionReason: 'Vehicle Breakdown',
      status: 'verified',
      reliabilityScore: 84.0,
      confidenceStatus: 'verified',
      upvotesCount: 8,
      downvotesCount: 1,
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    CommunityReportModel(
      id: 102,
      userId: 2, // Dilshan Silva
      userName: 'Dilshan Silva',
      isAnonymous: true, // Anonymous report demonstration
      categoryId: 2,
      categoryName: 'Road Condition',
      routeId: 2,
      routeNumber: '100',
      latitude: 6.8920,
      longitude: 79.8580,
      locationDescription: 'Bauddhaloka Mawatha near Thunmulla',
      title: 'Severe Waterlogging / Flash Flood',
      description: 'Heavy rain has flooded the junction with 1.5 feet of water. Low clearance three-wheelers and cars cannot pass. Buses moving slowly.',
      disruptionReason: 'Road Inundation / Flooding',
      status: 'verified',
      reliabilityScore: 92.0,
      confidenceStatus: 'verified',
      upvotesCount: 14,
      downvotesCount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    CommunityReportModel(
      id: 103,
      userId: 1, // Kamal Perera
      userName: 'Kamal Perera',
      isAnonymous: false,
      categoryId: 1,
      categoryName: 'Crowd Report',
      routeId: 1,
      routeNumber: '138',
      stopId: 101,
      stopName: 'Pettah Main Bus Terminal',
      latitude: 6.9355,
      longitude: 79.8530,
      locationDescription: 'Route 138 bus bay',
      title: 'Heavy Evening Rush Hour Overcrowding',
      description: 'Huge queue extending over 50 meters. Buses arriving every 10 minutes but fill immediately.',
      status: 'submitted',
      reliabilityScore: 60.0,
      confidenceStatus: 'plausible',
      upvotesCount: 3,
      downvotesCount: 0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  static final List<DisruptionModel> _disruptions = [
    DisruptionModel(
      id: 201,
      originatingReportId: 101,
      routeId: 1,
      routeNumber: '138',
      routeName: 'Colombo Fort - Maharagama',
      affectedStopId: 104,
      affectedStopName: 'Town Hall',
      disruptionType: 'Vehicle Breakdown',
      severity: 'medium',
      headline: 'Route 138 Delays Near Town Hall',
      details: 'SLTB bus mechanical failure has restricted traffic flow to a single lane. Estimated travel delay of 15-20 minutes.',
      status: 'active',
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      estimatedClearedAt: DateTime.now().add(const Duration(minutes: 45)),
    ),
    DisruptionModel(
      id: 202,
      routeId: 3,
      routeNumber: 'MAIN-RLY',
      routeName: 'Main Line Train (Colombo - Kandy)',
      disruptionType: 'Track Maintenance / Signal Failure',
      severity: 'high',
      headline: 'Main Line Railway Signal Failure',
      details: 'Automatic block signalling system down between Ragama and Gampaha. All up-country and commuter trains running at restricted speed with 25-30 min delays.',
      status: 'active',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedClearedAt: DateTime.now().add(const Duration(hours: 1)),
    ),
  ];

  /// Get active community reports with optional filtering
  Future<ApiResponse<List<CommunityReportModel>>> getReports({
    String? categoryFilter,
    String? statusFilter,
    int? routeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var list = List<CommunityReportModel>.from(_reports);

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'All') {
      list = list.where((r) => r.categoryName.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }

    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'All') {
      list = list.where((r) => r.status.toLowerCase() == statusFilter.toLowerCase()).toList();
    }

    if (routeId != null) {
      list = list.where((r) => r.routeId == routeId).toList();
    }

    // Sort by newest first
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ApiResponse.success(
      message: 'Reports retrieved successfully',
      data: list,
    );
  }

  /// Get reports authored by a specific commuter
  Future<ApiResponse<List<CommunityReportModel>>> getMyReports(int userId) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final myReports = _reports.where((r) => r.userId == userId).toList();
    myReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ApiResponse.success(
      message: 'My reports retrieved',
      data: myReports,
    );
  }

  /// Get report details by ID
  Future<ApiResponse<CommunityReportModel>> getReportById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final report = _reports.firstWhere(
      (r) => r.id == id,
      orElse: () => CommunityReportModel(
        id: 0,
        userId: 0,
        categoryId: 0,
        categoryName: '',
        latitude: 0,
        longitude: 0,
        locationDescription: '',
        title: '',
        description: '',
        createdAt: DateTime.now(),
      ),
    );

    if (report.id == 0) {
      return ApiResponse.failure(
        message: 'Report not found.',
        code: 'REPORT_NOT_FOUND',
        statusCode: 404,
      );
    }

    return ApiResponse.success(
      message: 'Report loaded',
      data: report,
    );
  }

  /// Submit a new community report
  Future<ApiResponse<CommunityReportModel>> submitReport({
    required int userId,
    required String userName,
    required bool isAnonymous,
    required int categoryId,
    required String categoryName,
    int? routeId,
    String? routeNumber,
    int? stopId,
    String? stopName,
    required double latitude,
    required double longitude,
    required String locationDescription,
    required String title,
    required String description,
    String? disruptionReason,
    String? mediaUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newId = 100 + _reports.length + 1;
    final newReport = CommunityReportModel(
      id: newId,
      userId: userId,
      userName: userName,
      isAnonymous: isAnonymous,
      categoryId: categoryId,
      categoryName: categoryName,
      routeId: routeId,
      routeNumber: routeNumber,
      stopId: stopId,
      stopName: stopName,
      latitude: latitude,
      longitude: longitude,
      locationDescription: locationDescription,
      title: title,
      description: description,
      disruptionReason: disruptionReason,
      mediaUrl: mediaUrl,
      status: 'submitted',
      reliabilityScore: 20.0,
      confidenceStatus: 'unverified',
      upvotesCount: 1, // Author's implicit upvote
      downvotesCount: 0,
      createdAt: DateTime.now(),
    );

    _reports.insert(0, newReport);

    return ApiResponse.success(
      message: 'Report submitted successfully!',
      data: newReport,
      statusCode: 201,
    );
  }

  /// Delete report (Strictly checks ownership!)
  Future<ApiResponse<bool>> deleteReport({
    required int reportId,
    required int userId,
    bool isModerator = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) {
      return ApiResponse.failure(
        message: 'Report not found.',
        code: 'REPORT_NOT_FOUND',
        statusCode: 404,
      );
    }

    final report = _reports[index];
    if (!report.isOwnedBy(userId) && !isModerator) {
      return ApiResponse.failure(
        message: 'Unauthorized. You can only delete reports that you have authored.',
        code: 'FORBIDDEN_DELETE',
        statusCode: 403,
      );
    }

    _reports.removeAt(index);

    return ApiResponse.success(
      message: 'Report deleted successfully.',
      data: true,
    );
  }

  /// Cast vote on report (Suneth's Peer Reliability Engine)
  Future<ApiResponse<CommunityReportModel>> voteOnReport({
    required int reportId,
    required int userId,
    required String voteType, // 'upvote', 'downvote', 'confirm_resolved'
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) {
      return ApiResponse.failure(
        message: 'Report not found.',
        code: 'REPORT_NOT_FOUND',
        statusCode: 404,
      );
    }

    final current = _reports[index];
    int upvotes = current.upvotesCount;
    int downvotes = current.downvotesCount;
    String status = current.status;
    String confidence = current.confidenceStatus;
    DateTime? resolvedAt = current.resolvedAt;

    if (voteType == 'upvote') {
      if (current.userVote == 'upvote') {
        upvotes = (upvotes > 0) ? upvotes - 1 : 0;
      } else {
        upvotes += 1;
        if (current.userVote == 'downvote') {
          downvotes = (downvotes > 0) ? downvotes - 1 : 0;
        }
      }
    } else if (voteType == 'downvote') {
      if (current.userVote == 'downvote') {
        downvotes = (downvotes > 0) ? downvotes - 1 : 0;
      } else {
        downvotes += 1;
        if (current.userVote == 'upvote') {
          upvotes = (upvotes > 0) ? upvotes - 1 : 0;
        }
      }
    } else if (voteType == 'confirm_resolved') {
      status = 'resolved';
      resolvedAt = DateTime.now();
    }

    // Reliability algorithm recalculation
    final totalVotes = upvotes + downvotes;
    double score = 50.0;
    if (totalVotes > 0) {
      score = ((upvotes / totalVotes) * 100.0).clamp(0.0, 100.0);
    }

    if (score >= 70.0 && upvotes >= 3) {
      confidence = 'verified';
      if (status != 'resolved') status = 'verified';
    } else if (score < 40.0 && downvotes >= 3) {
      confidence = 'disputed';
      if (status != 'resolved') status = 'disputed';
    } else {
      confidence = 'plausible';
    }

    final updated = current.copyWith(
      upvotesCount: upvotes,
      downvotesCount: downvotes,
      userVote: (current.userVote == voteType) ? null : voteType,
      reliabilityScore: score,
      confidenceStatus: confidence,
      status: status,
      resolvedAt: resolvedAt,
    );

    _reports[index] = updated;

    return ApiResponse.success(
      message: 'Vote recorded and reliability recalculated.',
      data: updated,
    );
  }

  /// Get official transit disruptions
  Future<ApiResponse<List<DisruptionModel>>> getDisruptions() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ApiResponse.success(
      message: 'Disruptions loaded',
      data: List<DisruptionModel>.from(_disruptions),
    );
  }
}

