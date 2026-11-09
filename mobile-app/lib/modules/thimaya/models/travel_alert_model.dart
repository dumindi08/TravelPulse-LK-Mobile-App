/// TravelPulse LK — Travel Alert Model (Thimaya)
class TravelAlertModel {
  final int id;
  final String title;
  final String message;
  final String alertType; // 'transport_disruption', 'road_condition', 'weather_emergency'
  final String severity; // 'info', 'warning', 'critical'
  final int? targetRouteId;
  final String? targetRouteNumber;
  final double? targetLatitude;
  final double? targetLongitude;
  final double? targetRadiusKm;
  final String status; // 'active', 'expired', 'cancelled'
  final DateTime createdAt;
  final DateTime? expiresAt;

  TravelAlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.alertType,
    this.severity = 'info',
    this.targetRouteId,
    this.targetRouteNumber,
    this.targetLatitude,
    this.targetLongitude,
    this.targetRadiusKm,
    this.status = 'active',
    required this.createdAt,
    this.expiresAt,
  });

  bool get isActive => status == 'active';
  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';

  factory TravelAlertModel.fromJson(Map<String, dynamic> json) {
    return TravelAlertModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      alertType: json['alertType'] as String? ?? 'transport_disruption',
      severity: json['severity'] as String? ?? 'info',
      targetRouteId: json['targetRouteId'] as int?,
      targetRouteNumber: json['targetRouteNumber'] as String?,
      targetLatitude: (json['targetLatitude'] as num?)?.toDouble(),
      targetLongitude: (json['targetLongitude'] as num?)?.toDouble(),
      targetRadiusKm: (json['targetRadiusKm'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'alertType': alertType,
      'severity': severity,
      'targetRouteId': targetRouteId,
      'targetRouteNumber': targetRouteNumber,
      'targetLatitude': targetLatitude,
      'targetLongitude': targetLongitude,
      'targetRadiusKm': targetRadiusKm,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}

