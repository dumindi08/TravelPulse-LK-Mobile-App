import 'package:flutter/material.dart';
import '../models/crowd_estimate_model.dart';
import '../models/user_reputation_model.dart';
import '../services/crowd_service.dart';

/// TravelPulse LK — Crowd Intelligence Provider (Suneth)
/// Manages state for real-time crowd aggregations, peer voting,
/// and commuter reputation metrics.
class CrowdProvider extends ChangeNotifier {
  final CrowdService _service;

  List<CrowdAggregationModel> _aggregations = [];
  final Map<int, CrowdAggregationModel> _routeCrowdMap = {};
  final Map<int, CrowdAggregationModel> _stopCrowdMap = {};
  UserReputationModel? _userReputation;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  CrowdProvider({CrowdService? service}) : _service = service ?? CrowdService() {
    loadAggregations();
  }

  // Getters
  List<CrowdAggregationModel> get aggregations => List.unmodifiable(_aggregations);
  UserReputationModel? get userReputation => _userReputation;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<CrowdAggregationModel> get routeAggregations =>
      _aggregations.where((a) => a.isRoute).toList();

  List<CrowdAggregationModel> get stopAggregations =>
      _aggregations.where((a) => a.isStop).toList();

  /// Resolves crowd level for a given route (e.g. 'moderate', 'crowded', 'very_crowded')
  String getCrowdLevelForRoute(int routeId) {
    return _routeCrowdMap[routeId]?.currentCrowdLevel ?? 'moderate';
  }

  /// Resolves crowd level for a given stop
  String getCrowdLevelForStop(int stopId) {
    return _stopCrowdMap[stopId]?.currentCrowdLevel ?? 'moderate';
  }

  /// Gets aggregation for a route
  CrowdAggregationModel? getRouteAggregation(int routeId) => _routeCrowdMap[routeId];

  /// Gets aggregation for a stop
  CrowdAggregationModel? getStopAggregation(int stopId) => _stopCrowdMap[stopId];

  /// 1. Load all active crowd aggregations
  Future<void> loadAggregations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getAggregations();

    if (response.isSuccess && response.data != null) {
      _aggregations = response.data!;
      _routeCrowdMap.clear();
      _stopCrowdMap.clear();

      for (final agg in _aggregations) {
        if (agg.isRoute) {
          _routeCrowdMap[agg.targetId] = agg;
        } else if (agg.isStop) {
          _stopCrowdMap[agg.targetId] = agg;
        }
      }
    } else {
      _errorMessage = response.message ?? 'Failed to load crowd aggregations.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 2. Fetch specific route crowd aggregation
  Future<CrowdAggregationModel?> fetchRouteCrowd(int routeId) async {
    final response = await _service.getRouteCrowd(routeId);
    if (response.isSuccess && response.data != null) {
      _routeCrowdMap[routeId] = response.data!;
      notifyListeners();
      return response.data;
    }
    return _routeCrowdMap[routeId];
  }

  /// 3. Fetch specific stop crowd aggregation
  Future<CrowdAggregationModel?> fetchStopCrowd(int stopId) async {
    final response = await _service.getStopCrowd(stopId);
    if (response.isSuccess && response.data != null) {
      _stopCrowdMap[stopId] = response.data!;
      notifyListeners();
      return response.data;
    }
    return _stopCrowdMap[stopId];
  }

  /// 4. Submit real-time crowd estimate
  Future<bool> submitCrowdEstimate({
    int? routeId,
    int? stopId,
    required String crowdLevel,
    int? passengerWaitTimeMinutes,
    required int userId,
    String? token,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.submitCrowdEstimate(
      routeId: routeId,
      stopId: stopId,
      crowdLevel: crowdLevel,
      passengerWaitTimeMinutes: passengerWaitTimeMinutes,
      userId: userId,
      token: token,
    );

    _isSubmitting = false;

    if (response.isSuccess) {
      // Reload aggregations to reflect updated real-time score
      await loadAggregations();
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to submit crowd estimate.';
      notifyListeners();
      return false;
    }
  }

  /// 5. Cast peer verification vote on a community report
  Future<Map<String, dynamic>?> voteOnReport({
    required int reportId,
    required int userId,
    required String voteType,
    String? token,
  }) async {
    final response = await _service.voteOnReport(
      reportId: reportId,
      userId: userId,
      voteType: voteType,
      token: token,
    );

    if (response.isSuccess && response.data != null) {
      notifyListeners();
      return response.data;
    } else {
      _errorMessage = response.message ?? 'Failed to record vote.';
      notifyListeners();
      return null;
    }
  }

  /// 6. Load user reputation & credibility score
  Future<void> loadUserReputation(int userId, {String? token}) async {
    final response = await _service.getUserReputation(userId: userId, token: token);
    if (response.isSuccess && response.data != null) {
      _userReputation = response.data;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

