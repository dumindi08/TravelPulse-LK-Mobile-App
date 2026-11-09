import 'dart:async';
import '../../../core/models/api_response.dart';
import '../models/journey_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';

/// TravelPulse LK — Commuter Journey Service (Nisal)
/// ---------------------------------------------------------------------------
/// [TEMPORARY MOCK REPOSITORY — FOR OFFLINE DEVELOPMENT & TESTING]
/// Aligns with MySQL `user_journeys` table in 01_nisal_user_transport_schema.sql.
/// Connects to POST /api/v1/journeys and GET /api/v1/journeys when backend is online.
/// ---------------------------------------------------------------------------
class JourneyService {
  // In-memory collection of commuter journeys
  static final List<JourneyModel> _journeys = [
    JourneyModel(
      id: 501,
      userId: 1, // Matches test commuter (Kamal Perera)
      routeId: 1,
      routeNumber: '138',
      routeName: 'Colombo Fort - Maharagama / Homagama',
      originStopId: 101,
      originStopName: 'Pettah Main Bus Terminal',
      destinationStopId: 107,
      destinationStopName: 'Maharagama Central Bus Stand',
      startTime: DateTime.now().subtract(const Duration(hours: 3)),
      endTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 12)),
      status: 'completed',
    ),
  ];

  static int _nextJourneyId = 502;

  /// Retrieve journeys for a specific user, or all active journeys
  Future<ApiResponse<List<JourneyModel>>> getJourneys({int? userId}) async {
    await Future.delayed(const Duration(milliseconds: 150));

    var results = List<JourneyModel>.from(_journeys);
    if (userId != null && userId > 0) {
      results = results.where((j) => j.userId == userId).toList();
    }

    // Sort newest first
    results.sort((a, b) => b.startTime.compareTo(a.startTime));

    return ApiResponse.success(
      message: 'Journeys retrieved successfully',
      data: results,
    );
  }

  /// Get the active in-progress journey for a user
  Future<ApiResponse<JourneyModel?>> getActiveJourney({int? userId}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final matches = _journeys.where((j) {
      final isUserMatch = (userId == null || userId == 0) || j.userId == userId;
      return isUserMatch && j.status == 'in_progress';
    }).toList();

    return ApiResponse.success(
      message: 'Active journey status checked',
      data: matches.isNotEmpty ? matches.first : null,
    );
  }

  /// Create and log a new journey (planned or started)
  Future<ApiResponse<JourneyModel>> createJourney({
    required int userId,
    required RouteModel route,
    required RouteStopSequenceModel originStop,
    required RouteStopSequenceModel destinationStop,
    bool startImmediately = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final newJourney = JourneyModel(
      id: _nextJourneyId++,
      userId: userId,
      routeId: route.id,
      routeNumber: route.routeNumber,
      routeName: route.name,
      originStopId: originStop.stopId,
      originStopName: originStop.stopName,
      destinationStopId: destinationStop.stopId,
      destinationStopName: destinationStop.stopName,
      startTime: DateTime.now(),
      status: startImmediately ? 'in_progress' : 'planned',
    );

    // If starting immediately, mark any other in-progress journey as completed
    if (startImmediately) {
      for (int i = 0; i < _journeys.length; i++) {
        if (_journeys[i].userId == userId && _journeys[i].status == 'in_progress') {
          _journeys[i] = JourneyModel(
            id: _journeys[i].id,
            userId: _journeys[i].userId,
            routeId: _journeys[i].routeId,
            routeNumber: _journeys[i].routeNumber,
            routeName: _journeys[i].routeName,
            originStopId: _journeys[i].originStopId,
            originStopName: _journeys[i].originStopName,
            destinationStopId: _journeys[i].destinationStopId,
            destinationStopName: _journeys[i].destinationStopName,
            startTime: _journeys[i].startTime,
            endTime: DateTime.now(),
            status: 'completed',
          );
        }
      }
    }

    _journeys.insert(0, newJourney);

    return ApiResponse.success(
      message: startImmediately ? 'Journey started' : 'Journey planned',
      data: newJourney,
    );
  }

  /// Update journey status ('in_progress', 'completed', 'cancelled')
  Future<ApiResponse<JourneyModel>> updateJourneyStatus(int journeyId, String status) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final index = _journeys.indexWhere((j) => j.id == journeyId);
    if (index == -1) {
      return ApiResponse.failure(
        message: 'Journey #$journeyId not found.',
        code: 'JOURNEY_NOT_FOUND',
        statusCode: 404,
      );
    }

    final existing = _journeys[index];
    final updated = JourneyModel(
      id: existing.id,
      userId: existing.userId,
      routeId: existing.routeId,
      routeNumber: existing.routeNumber,
      routeName: existing.routeName,
      originStopId: existing.originStopId,
      originStopName: existing.originStopName,
      destinationStopId: existing.destinationStopId,
      destinationStopName: existing.destinationStopName,
      startTime: existing.startTime,
      endTime: (status == 'completed' || status == 'cancelled') ? DateTime.now() : existing.endTime,
      status: status,
    );

    _journeys[index] = updated;

    return ApiResponse.success(
      message: 'Journey status updated to $status',
      data: updated,
    );
  }
}

