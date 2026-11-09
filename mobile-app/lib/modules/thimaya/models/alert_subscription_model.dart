/// TravelPulse LK — Commuter Alert Subscription & Notification Preferences Model (Thimaya)
/// Matches Table 19: `alert_subscriptions`
class AlertSubscriptionModel {
  final int id;
  final int userId;
  final String subscriptionType; // 'route', 'geo_radius', 'all_critical'
  final int? routeId;
  final String? routeNumber;
  final double? centerLatitude;
  final double? centerLongitude;
  final double? radiusKm;
  final bool isActive;

  // Granular Commuter Preferences
  final bool pushNotificationsEnabled;
  final bool weatherAlerts;
  final bool roadHazards;
  final bool transitDisruptions;
  final bool soundAndVibrate;

  AlertSubscriptionModel({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    this.routeId,
    this.routeNumber,
    this.centerLatitude,
    this.centerLongitude,
    this.radiusKm = 5.0,
    this.isActive = true,
    this.pushNotificationsEnabled = true,
    this.weatherAlerts = true,
    this.roadHazards = true,
    this.transitDisruptions = true,
    this.soundAndVibrate = true,
  });

  factory AlertSubscriptionModel.defaults(int userId) {
    return AlertSubscriptionModel(
      id: 1,
      userId: userId,
      subscriptionType: 'all_critical',
      radiusKm: 5.0,
      isActive: true,
      pushNotificationsEnabled: true,
      weatherAlerts: true,
      roadHazards: true,
      transitDisruptions: true,
      soundAndVibrate: true,
    );
  }

  AlertSubscriptionModel copyWith({
    int? id,
    int? userId,
    String? subscriptionType,
    int? routeId,
    String? routeNumber,
    double? centerLatitude,
    double? centerLongitude,
    double? radiusKm,
    bool? isActive,
    bool? pushNotificationsEnabled,
    bool? weatherAlerts,
    bool? roadHazards,
    bool? transitDisruptions,
    bool? soundAndVibrate,
  }) {
    return AlertSubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      routeId: routeId ?? this.routeId,
      routeNumber: routeNumber ?? this.routeNumber,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
      radiusKm: radiusKm ?? this.radiusKm,
      isActive: isActive ?? this.isActive,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      weatherAlerts: weatherAlerts ?? this.weatherAlerts,
      roadHazards: roadHazards ?? this.roadHazards,
      transitDisruptions: transitDisruptions ?? this.transitDisruptions,
      soundAndVibrate: soundAndVibrate ?? this.soundAndVibrate,
    );
  }

  factory AlertSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return AlertSubscriptionModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? json['user_id'] as int? ?? 0,
      subscriptionType: json['subscriptionType'] as String? ?? json['subscription_type'] as String? ?? 'route',
      routeId: json['routeId'] as int? ?? json['route_id'] as int?,
      routeNumber: json['routeNumber'] as String? ?? json['route_number'] as String?,
      centerLatitude: (json['centerLatitude'] as num?)?.toDouble() ?? (json['center_latitude'] as num?)?.toDouble(),
      centerLongitude: (json['centerLongitude'] as num?)?.toDouble() ?? (json['center_longitude'] as num?)?.toDouble(),
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? (json['radius_km'] as num?)?.toDouble() ?? 5.0,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      weatherAlerts: json['weatherAlerts'] as bool? ?? true,
      roadHazards: json['roadHazards'] as bool? ?? true,
      transitDisruptions: json['transitDisruptions'] as bool? ?? true,
      soundAndVibrate: json['soundAndVibrate'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionType': subscriptionType,
      'routeId': routeId,
      'routeNumber': routeNumber,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'radiusKm': radiusKm,
      'isActive': isActive,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'weatherAlerts': weatherAlerts,
      'roadHazards': roadHazards,
      'transitDisruptions': transitDisruptions,
      'soundAndVibrate': soundAndVibrate,
    };
  }
}

