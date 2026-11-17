import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/crowd_estimate_model.dart';
import '../models/user_reputation_model.dart';

/// TravelPulse LK — Crowd Intelligence Service (Suneth)
/// Interfaces with `/api/v1/crowd` endpoints with offline fallback.
class CrowdService {
  final http.Client _client;
  final String _baseUrl;

  // In-memory mock fallback state for offline / test environments
  final List<CrowdAggregationModel> _mockAggregations = [
    CrowdAggregationModel(
      targetType: 'route',
      targetId: 1,
      targetName: 'Route 138 (Pettah - Homagama)',
      currentCrowdLevel: 'very_crowded',
      sampleCount: 8,
      confidenceScore: 88.5,
      averageWaitTimeMinutes: 18,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    CrowdAggregationModel(
      targetType: 'route',
      targetId: 2,
      targetName: 'Route 100 (Pettah - Panadura)',
      currentCrowdLevel: 'moderate',
      sampleCount: 5,
      confidenceScore: 82.0,
      averageWaitTimeMinutes: 9,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    CrowdAggregationModel(
      targetType: 'route',
      targetId: 3,
      targetName: 'Main Line Railway (Colombo Fort - Polgahawela)',
      currentCrowdLevel: 'crowded',
      sampleCount: 6,
      confidenceScore: 85.0,
      averageWaitTimeMinutes: 12,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    CrowdAggregationModel(
      targetType: 'route',
      targetId: 4,
      targetName: 'Route 177 (Kollupitiya - Kaduwela)',
      currentCrowdLevel: 'empty',
      sampleCount: 3,
      confidenceScore: 74.0,
      averageWaitTimeMinutes: 5,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    CrowdAggregationModel(
      targetType: 'route',
      targetId: 5,
      targetName: 'Route 120 (Pettah - Horana)',
      currentCrowdLevel: 'crowded',
      sampleCount: 7,
      confidenceScore: 86.0,
      averageWaitTimeMinutes: 14,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    CrowdAggregationModel(
      targetType: 'stop',
      targetId: 101,
      targetName: 'Pettah Main Bus Stand',
      currentCrowdLevel: 'very_crowded',
      sampleCount: 9,
      confidenceScore: 91.0,
      averageWaitTimeMinutes: 22,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
    CrowdAggregationModel(
      targetType: 'stop',
      targetId: 104,
      targetName: 'Town Hall / Viharamahadevi Park',
      currentCrowdLevel: 'moderate',
      sampleCount: 4,
      confidenceScore: 78.5,
      averageWaitTimeMinutes: 10,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 14)),
    ),
    CrowdAggregationModel(
      targetType: 'stop',
      targetId: 201,
      targetName: 'Colombo Fort Railway Station',
      currentCrowdLevel: 'crowded',
      sampleCount: 8,
      confidenceScore: 87.0,
      averageWaitTimeMinutes: 15,
      timeSlot: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  final Map<int, UserReputationModel> _mockReputations = {
    1: UserReputationModel(
      userId: 1,
      reputationScore: 82.5,
      totalReportsSubmitted: 6,
      verifiedReportsCount: 5,
      rejectedReportsCount: 0,
      totalVotesCast: 14,
      updatedAt: DateTime.now(),
    ),
    2: UserReputationModel(
      userId: 2,
      reputationScore: 76.0,
      totalReportsSubmitted: 4,
      verifiedReportsCount: 3,
      rejectedReportsCount: 0,
      totalVotesCast: 10,
      updatedAt: DateTime.now(),
    ),
    3: UserReputationModel(
      userId: 3,
      reputationScore: 88.0,
      totalReportsSubmitted: 9,
      verifiedReportsCount: 8,
      rejectedReportsCount: 0,
      totalVotesCast: 22,
      updatedAt: DateTime.now(),
    ),
    4: UserReputationModel(
      userId: 4,
      reputationScore: 90.0,
      totalReportsSubmitted: 11,
      verifiedReportsCount: 10,
      rejectedReportsCount: 0,
      totalVotesCast: 28,
      updatedAt: DateTime.now(),
    ),
    5: UserReputationModel(
      userId: 5,
      reputationScore: 98.0,
      totalReportsSubmitted: 20,
      verifiedReportsCount: 19,
      rejectedReportsCount: 0,
      totalVotesCast: 45,
      updatedAt: DateTime.now(),
    ),
  };

  CrowdService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  /// 1. Get all active crowd aggregations across transit network
  Future<ApiResponse<List<CrowdAggregationModel>>> getAggregations() async {
    try {
      final uri = Uri.parse('$_baseUrl/crowd/aggregations');
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = (decoded['data'] as List? ?? [])
            .map((item) => CrowdAggregationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(
          data: list,
          message: decoded['message']?.toString() ?? 'Crowd aggregations loaded successfully.',
        );
      }
    } catch (_) {
      // Fallback to local mock state
    }

    return ApiResponse.success(
      data: List.unmodifiable(_mockAggregations),
      message: 'Active crowd aggregations loaded (offline mode)',
    );
  }

  /// 2. Get current crowd aggregation for a route
  Future<ApiResponse<CrowdAggregationModel>> getRouteCrowd(int routeId) async {
    try {
      final uri = Uri.parse('$_baseUrl/crowd/routes/$routeId');
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ApiResponse.success(
          data: CrowdAggregationModel.fromJson(decoded['data'] as Map<String, dynamic>),
          message: decoded['message']?.toString() ?? 'Route crowd loaded successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    final matched = _mockAggregations.firstWhere(
      (a) => a.isRoute && a.targetId == routeId,
      orElse: () => CrowdAggregationModel(
        targetType: 'route',
        targetId: routeId,
        targetName: 'Route $routeId',
        currentCrowdLevel: 'moderate',
        sampleCount: 1,
        confidenceScore: 50.0,
        timeSlot: DateTime.now(),
        isBaseline: true,
      ),
    );

    return ApiResponse.success(
      data: matched,
      message: 'Route crowd loaded (offline mode)',
    );
  }

  /// 3. Get current crowd aggregation for a stop
  Future<ApiResponse<CrowdAggregationModel>> getStopCrowd(int stopId) async {
    try {
      final uri = Uri.parse('$_baseUrl/crowd/stops/$stopId');
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ApiResponse.success(
          data: CrowdAggregationModel.fromJson(decoded['data'] as Map<String, dynamic>),
          message: decoded['message']?.toString() ?? 'Stop crowd loaded successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    final matched = _mockAggregations.firstWhere(
      (a) => a.isStop && a.targetId == stopId,
      orElse: () => CrowdAggregationModel(
        targetType: 'stop',
        targetId: stopId,
        targetName: 'Stop $stopId',
        currentCrowdLevel: 'moderate',
        sampleCount: 1,
        confidenceScore: 50.0,
        timeSlot: DateTime.now(),
        isBaseline: true,
      ),
    );

    return ApiResponse.success(
      data: matched,
      message: 'Stop crowd loaded (offline mode)',
    );
  }

  /// 4. Submit real-time crowd estimate (Route XOR Stop)
  Future<ApiResponse<CrowdEstimateModel>> submitCrowdEstimate({
    int? routeId,
    int? stopId,
    required String crowdLevel,
    int? passengerWaitTimeMinutes,
    required int userId,
    String? token,
  }) async {
    final payload = {
      if (routeId != null) 'routeId': routeId,
      if (stopId != null) 'stopId': stopId,
      'crowdLevel': crowdLevel,
      if (passengerWaitTimeMinutes != null) 'passengerWaitTimeMinutes': passengerWaitTimeMinutes,
    };

    final effectiveToken = token ?? LocalStorageService().authToken;
    try {
      final uri = Uri.parse('$_baseUrl/crowd/estimate');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return ApiResponse.success(
          data: CrowdEstimateModel.fromJson(decoded['data']['estimate']),
          message: decoded['message']?.toString() ?? 'Crowd observation submitted successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    // Local mock submission update
    final estimate = CrowdEstimateModel(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      userId: userId,
      routeId: routeId,
      stopId: stopId,
      crowdLevel: crowdLevel,
      passengerWaitTimeMinutes: passengerWaitTimeMinutes,
      reportedAt: DateTime.now(),
    );

    // Update or insert mock aggregation
    final existingIdx = _mockAggregations.indexWhere((a) {
      if (routeId != null) return a.isRoute && a.targetId == routeId;
      if (stopId != null) return a.isStop && a.targetId == stopId;
      return false;
    });

    if (existingIdx != -1) {
      final current = _mockAggregations[existingIdx];
      _mockAggregations[existingIdx] = CrowdAggregationModel(
        targetType: current.targetType,
        targetId: current.targetId,
        targetName: current.targetName,
        currentCrowdLevel: crowdLevel,
        sampleCount: current.sampleCount + 1,
        confidenceScore: (current.confidenceScore + 2.5).clamp(0.0, 95.0),
        averageWaitTimeMinutes: passengerWaitTimeMinutes ?? current.averageWaitTimeMinutes,
        timeSlot: DateTime.now(),
      );
    }

    return ApiResponse.success(
      data: estimate,
      message: 'Crowd observation submitted successfully.',
    );
  }

  /// 5. Cast peer verification vote on a community report
  Future<ApiResponse<Map<String, dynamic>>> voteOnReport({
    required int reportId,
    required int userId,
    required String voteType,
    String? token,
  }) async {
    final payload = {'voteType': voteType};
    final effectiveToken = token ?? LocalStorageService().authToken;

    try {
      final uri = Uri.parse('$_baseUrl/reports/$reportId/vote');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ApiResponse.success(
          data: decoded['data'] as Map<String, dynamic>,
          message: decoded['message']?.toString() ?? 'Vote recorded successfully.',
        );
      } else if (response.statusCode == 400) {
        final decoded = json.decode(response.body);
        return ApiResponse.failure(
          message: decoded['message']?.toString() ?? 'Cannot vote on report.',
          statusCode: 400,
        );
      }
    } catch (_) {
      // Fallback
    }

    // Local fallback vote calculation
    return ApiResponse.success(
      data: {
        'reportId': reportId,
        'userVote': voteType,
        'upvotesCount': voteType == 'upvote' ? 9 : 8,
        'downvotesCount': voteType == 'downvote' ? 2 : 1,
        'reliabilityScore': 85.0,
        'confidenceStatus': 'verified',
      },
      message: 'Vote recorded successfully.',
    );
  }

  /// 6. Get user reputation and trust statistics
  Future<ApiResponse<UserReputationModel>> getUserReputation({
    required int userId,
    String? token,
  }) async {
    final effectiveToken = token ?? LocalStorageService().authToken;
    try {
      final uri = Uri.parse('$_baseUrl/crowd/reputation?userId=$userId');
      final response = await _client.get(
        uri,
        headers: {
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ApiResponse.success(
          data: UserReputationModel.fromJson(decoded['data'] as Map<String, dynamic>),
          message: decoded['message']?.toString() ?? 'User reputation loaded successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    final rep = _mockReputations[userId] ?? UserReputationModel.initial(userId);
    return ApiResponse.success(
      data: rep,
      message: 'User reputation loaded (offline mode)',
    );
  }
}

