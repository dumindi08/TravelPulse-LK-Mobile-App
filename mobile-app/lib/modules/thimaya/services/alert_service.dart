import 'dart:async';
import '../../../core/models/api_response.dart';
import '../models/road_incident_model.dart';
import '../models/travel_alert_model.dart';

/// TravelPulse LK — Travel Alert & Road Hazard Service (Thimaya)
/// ---------------------------------------------------------------------------
/// [TEMPORARY MOCK REPOSITORY — FOR OFFLINE DEVELOPMENT & TESTING]
/// Provides authentic road hazards and active travel advisories in Colombo.
/// ---------------------------------------------------------------------------
class AlertService {
  static final List<TravelAlertModel> _alerts = [
    TravelAlertModel(
      id: 301,
      title: 'Flash Flood Warning — Thunmulla Junction',
      message: 'Severe waterlogging at Bauddhaloka Mawatha near Thunmulla roundabout. Routes 138 and 120 are operating with heavy delays. Light vehicles advised to use Havelock Road.',
      alertType: 'road_condition',
      severity: 'critical',
      targetRouteId: 1,
      targetRouteNumber: '138',
      targetLatitude: 6.8920,
      targetLongitude: 79.8580,
      targetRadiusKm: 2.5,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
    ),
    TravelAlertModel(
      id: 302,
      title: 'Main Line Railway Signal Interruption',
      message: 'Signal failures between Ragama and Gampaha. Up-country trains from Colombo Fort experiencing 25-30 minute delays.',
      alertType: 'transport_disruption',
      severity: 'warning',
      targetRouteId: 3,
      targetRouteNumber: 'MAIN-RLY',
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    TravelAlertModel(
      id: 303,
      title: 'Route 138 Centre-Lane Obstruction at Town Hall',
      message: 'Broken down SLTB bus near Town Hall roundabout. Single lane traffic moving slowly towards Maradana.',
      alertType: 'transport_disruption',
      severity: 'info',
      targetRouteId: 1,
      targetRouteNumber: '138',
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  static final List<RoadIncidentModel> _incidents = [
    RoadIncidentModel(
      id: 401,
      sourceReportId: 102,
      incidentType: 'flooding',
      latitude: 6.8920,
      longitude: 79.8580,
      addressText: 'Bauddhaloka Mawatha, Thunmulla Junction',
      severity: 'high',
      radiusMeters: 250,
      isActive: true,
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoadIncidentModel(
      id: 402,
      sourceReportId: 101,
      incidentType: 'road_closure',
      latitude: 6.9147,
      longitude: 79.8653,
      addressText: 'Town Hall Roundabout, Colombo 07',
      severity: 'medium',
      radiusMeters: 100,
      isActive: true,
      startTime: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    RoadIncidentModel(
      id: 403,
      incidentType: 'pothole',
      latitude: 6.8724,
      longitude: 79.8898,
      addressText: 'High Level Road near Nugegoda Flyover',
      severity: 'medium',
      radiusMeters: 50,
      isActive: true,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Get active travel alerts
  Future<ApiResponse<List<TravelAlertModel>>> getAlerts({
    String? severityFilter,
    int? routeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    var list = List<TravelAlertModel>.from(_alerts);

    if (severityFilter != null && severityFilter.isNotEmpty && severityFilter != 'All') {
      list = list.where((a) => a.severity.toLowerCase() == severityFilter.toLowerCase()).toList();
    }

    if (routeId != null) {
      list = list.where((a) => a.targetRouteId == routeId).toList();
    }

    return ApiResponse.success(
      message: 'Alerts retrieved',
      data: list,
    );
  }

  /// Get road condition hazards for map display
  Future<ApiResponse<List<RoadIncidentModel>>> getRoadIncidents() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ApiResponse.success(
      message: 'Incidents retrieved',
      data: List<RoadIncidentModel>.from(_incidents),
    );
  }
}
