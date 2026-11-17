import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/models/api_response.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/road_incident_model.dart';
import '../models/travel_alert_model.dart';
import '../models/alert_subscription_model.dart';

/// TravelPulse LK — Travel Alert & Road Hazard Service (Thimaya)
/// Interfaces with `/api/v1/alerts` and `/api/v1/incidents` endpoints with offline fallback.
class AlertService {
  final http.Client _client;
  final String _baseUrl;

  // In-memory mock fallback state for offline / test environments
  static final List<TravelAlertModel> _mockAlerts = [
    TravelAlertModel(
      id: 301,
      title: 'Flash Flood Warning — Thunmulla Junction',
      message: 'Severe waterlogging at Bauddhaloka Mawatha near Thunmulla roundabout. Routes 138 and 100 are operating with heavy delays. Light vehicles advised to divert via Havelock Road.',
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
      message: 'Signal failures between Ragama and Gampaha. Up-country commuter trains from Colombo Fort experiencing 25-30 minute delays.',
      alertType: 'transport_disruption',
      severity: 'warning',
      targetRouteId: 3,
      targetRouteNumber: 'MAIN-RLY',
      targetLatitude: 7.0270,
      targetLongitude: 79.9230,
      targetRadiusKm: 5.0,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      expiresAt: DateTime.now().add(const Duration(hours: 2)),
    ),
    TravelAlertModel(
      id: 303,
      title: 'Route 138 Centre-Lane Obstruction at Town Hall',
      message: 'Broken down SLTB bus near Town Hall roundabout. Single lane traffic moving slowly towards Maradana.',
      alertType: 'transport_disruption',
      severity: 'info',
      targetRouteId: 1,
      targetRouteNumber: '138',
      targetLatitude: 6.9147,
      targetLongitude: 79.8653,
      targetRadiusKm: 1.0,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    ),
  ];

  static final List<RoadIncidentModel> _mockIncidents = [
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
      verifiedByUserId: 5,
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
      radiusMeters: 120,
      isActive: true,
      verifiedByUserId: 5,
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
      verifiedByUserId: 5,
      startTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RoadIncidentModel(
      id: 404,
      incidentType: 'traffic_lights_down',
      latitude: 6.9022,
      longitude: 79.8610,
      addressText: 'Thimbirigasyaya Junction traffic signal malfunction',
      severity: 'low',
      radiusMeters: 80,
      isActive: true,
      verifiedByUserId: 5,
      startTime: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  static final Map<int, AlertSubscriptionModel> _mockSubscriptions = {};

  AlertService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  /// 1. Get active travel alerts with optional filtering
  Future<ApiResponse<List<TravelAlertModel>>> getAlerts({
    String? severityFilter,
    String? alertTypeFilter,
    int? routeId,
  }) async {
    try {
      final queryParams = <String, String>{
        if (severityFilter != null && severityFilter != 'All') 'severity': severityFilter.toLowerCase(),
        if (alertTypeFilter != null && alertTypeFilter != 'All') 'alertType': alertTypeFilter.toLowerCase(),
        if (routeId != null) 'routeId': routeId.toString(),
      };
      final uri = Uri.parse('$_baseUrl/alerts').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = (decoded['data'] as List? ?? [])
            .map((item) => TravelAlertModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(
          data: list,
          message: decoded['message']?.toString() ?? 'Alerts retrieved successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    var list = List<TravelAlertModel>.from(_mockAlerts);
    if (severityFilter != null && severityFilter.isNotEmpty && severityFilter.toLowerCase() != 'all') {
      list = list.where((a) => a.severity.toLowerCase() == severityFilter.toLowerCase()).toList();
    }
    if (alertTypeFilter != null && alertTypeFilter.isNotEmpty && alertTypeFilter.toLowerCase() != 'all') {
      list = list.where((a) => a.alertType.toLowerCase() == alertTypeFilter.toLowerCase()).toList();
    }
    if (routeId != null) {
      list = list.where((a) => a.targetRouteId == routeId).toList();
    }

    return ApiResponse.success(
      message: 'Alerts retrieved (offline mode)',
      data: list,
    );
  }

  /// 2. Get active road incidents and hazards for map display
  Future<ApiResponse<List<RoadIncidentModel>>> getRoadIncidents({
    String? incidentTypeFilter,
    String? severityFilter,
  }) async {
    try {
      final queryParams = <String, String>{
        if (incidentTypeFilter != null && incidentTypeFilter != 'All') 'incidentType': incidentTypeFilter.toLowerCase(),
        if (severityFilter != null && severityFilter != 'All') 'severity': severityFilter.toLowerCase(),
      };
      final uri = Uri.parse('$_baseUrl/incidents').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await _client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = (decoded['data'] as List? ?? [])
            .map((item) => RoadIncidentModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(
          data: list,
          message: decoded['message']?.toString() ?? 'Incidents retrieved successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    var list = List<RoadIncidentModel>.from(_mockIncidents);
    if (incidentTypeFilter != null && incidentTypeFilter.isNotEmpty && incidentTypeFilter.toLowerCase() != 'all') {
      list = list.where((i) => i.incidentType.toLowerCase() == incidentTypeFilter.toLowerCase()).toList();
    }
    if (severityFilter != null && severityFilter.isNotEmpty && severityFilter.toLowerCase() != 'all') {
      list = list.where((i) => i.severity.toLowerCase() == severityFilter.toLowerCase()).toList();
    }

    return ApiResponse.success(
      message: 'Incidents retrieved (offline mode)',
      data: list,
    );
  }

  /// 3. Get commuter notification preferences
  Future<ApiResponse<AlertSubscriptionModel>> getSubscriptions(int userId, {String? token}) async {
    final effectiveToken = token ?? LocalStorageService().authToken;
    try {
      final uri = Uri.parse('$_baseUrl/alerts/subscriptions');
      final response = await _client.get(
        uri,
        headers: {
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['data'] as List? ?? [];
        if (list.isNotEmpty) {
          return ApiResponse.success(
            data: AlertSubscriptionModel.fromJson(list.first as Map<String, dynamic>),
            message: decoded['message']?.toString() ?? 'Subscription preferences retrieved successfully.',
          );
        }
      }
    } catch (_) {
      // Fallback
    }

    final sub = _mockSubscriptions[userId] ?? AlertSubscriptionModel.defaults(userId);
    return ApiResponse.success(
      data: sub,
      message: 'Subscription preferences retrieved (offline mode)',
    );
  }

  /// 4. Save/update notification preferences
  Future<ApiResponse<AlertSubscriptionModel>> updateSubscription(
    AlertSubscriptionModel subscription, {
    String? token,
  }) async {
    final effectiveToken = token ?? LocalStorageService().authToken;
    try {
      final uri = Uri.parse('$_baseUrl/alerts/subscriptions');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        },
        body: json.encode(subscription.toJson()),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ApiResponse.success(
          data: AlertSubscriptionModel.fromJson(decoded['data'] as Map<String, dynamic>),
          message: decoded['message']?.toString() ?? 'Notification preferences saved successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    _mockSubscriptions[subscription.userId] = subscription;
    return ApiResponse.success(
      data: subscription,
      message: 'Notification preferences saved (offline mode)',
    );
  }

  /// 5. Register device token for push notifications
  Future<ApiResponse<bool>> registerDeviceToken(int userId, String fcmToken, {String? platform, String? token}) async {
    final effectiveToken = token ?? LocalStorageService().authToken;
    try {
      final uri = Uri.parse('$_baseUrl/alerts/device-token');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (effectiveToken != null && effectiveToken.isNotEmpty) 'Authorization': 'Bearer $effectiveToken',
        },
        body: json.encode({'token': fcmToken, 'platform': platform ?? 'android'}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: true,
          message: 'Device token registered successfully.',
        );
      }
    } catch (_) {
      // Fallback
    }

    return ApiResponse.success(
      data: true,
      message: 'Device token registered (offline mode)',
    );
  }
}
