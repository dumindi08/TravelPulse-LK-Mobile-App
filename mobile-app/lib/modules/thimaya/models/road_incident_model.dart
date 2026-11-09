import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// TravelPulse LK — Road Condition Incident Model (Thimaya)
class RoadIncidentModel {
  final int id;
  final int? sourceReportId;
  final String incidentType; // 'pothole', 'flooding', 'landslide', 'road_closure', 'accident', 'congestion', 'traffic_lights_down'
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

  String get displayName {
    switch (incidentType.toLowerCase()) {
      case 'flooding':
        return 'Flash Flood / Waterlogging';
      case 'pothole':
        return 'Severe Pothole Hazard';
      case 'road_closure':
        return 'Road Closure / Blockade';
      case 'accident':
        return 'Traffic Collision / Accident';
      case 'traffic_lights_down':
        return 'Traffic Signals Malfunction';
      case 'landslide':
        return 'Landslide / Earthslip';
      case 'congestion':
        return 'Severe Traffic Congestion';
      default:
        return 'Road Hazard';
    }
  }

  IconData get icon {
    switch (incidentType.toLowerCase()) {
      case 'flooding':
        return Icons.water_drop_rounded;
      case 'pothole':
        return Icons.report_problem_rounded;
      case 'road_closure':
        return Icons.block_rounded;
      case 'accident':
        return Icons.car_crash_rounded;
      case 'traffic_lights_down':
        return Icons.traffic_rounded;
      case 'landslide':
        return Icons.landslide_rounded;
      case 'congestion':
        return Icons.traffic_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color get markerColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return const Color(0xFFEA580C); // Deep orange
      case 'medium':
        return AppColors.warning;
      case 'low':
      default:
        return AppColors.info;
    }
  }

  factory RoadIncidentModel.fromJson(Map<String, dynamic> json) {
    return RoadIncidentModel(
      id: json['id'] as int? ?? 0,
      sourceReportId: json['sourceReportId'] as int? ?? json['source_report_id'] as int?,
      incidentType: json['incidentType'] as String? ?? json['incident_type'] as String? ?? 'congestion',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      addressText: json['addressText'] as String? ?? json['address_text'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
      radiusMeters: json['radiusMeters'] as int? ?? json['radius_meters'] as int? ?? 100,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      verifiedByUserId: json['verifiedByUserId'] as int? ?? json['verified_by_user_id'] as int?,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString()) ?? DateTime.now()
          : (json['start_time'] != null
              ? DateTime.tryParse(json['start_time'].toString()) ?? DateTime.now()
              : DateTime.now()),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : (json['end_time'] != null
              ? DateTime.tryParse(json['end_time'].toString())
              : null),
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
