/// TravelPulse LK — Road Condition Incident Model (Thimaya)
class RoadIncidentModel {
  final int id;
  final int? sourceReportId;
  final String incidentType; // 'pothole', 'flooding', 'landslide', 'road_closure', 'accident', 'congestion'
  final double latitude;
  final double longitude;
  final String addressText;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final int radiusMeters;
  final bool isActive;
  final int? verifiedByUserId;
  final DateTime startTime;
  final DateTime? endTime;

  RoadIncidentModel({
    required this.id,
    this.sourceReportId,
    required this.incidentType,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    this.severity = 'medium',
    this.radiusMeters = 100,
    this.isActive = true,
    this.verifiedByUserId,
    required this.startTime,
    this.endTime,
  });

  bool get isCritical => severity == 'critical' || severity == 'high';

  factory RoadIncidentModel.fromJson(Map<String, dynamic> json) {
    return RoadIncidentModel(
      id: json['id'] as int? ?? 0,
      sourceReportId: json['sourceReportId'] as int?,
      incidentType: json['incidentType'] as String? ?? 'congestion',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      addressText: json['addressText'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
      radiusMeters: json['radiusMeters'] as int? ?? 100,
      isActive: json['isActive'] as bool? ?? true,
      verifiedByUserId: json['verifiedByUserId'] as int?,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceReportId': sourceReportId,
      'incidentType': incidentType,
      'latitude': latitude,
      'longitude': longitude,
      'addressText': addressText,
      'severity': severity,
      'radiusMeters': radiusMeters,
      'isActive': isActive,
      'verifiedByUserId': verifiedByUserId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}

