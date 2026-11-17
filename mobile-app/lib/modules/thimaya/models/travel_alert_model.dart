import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// TravelPulse LK — Travel Alert Model (Thimaya)
class TravelAlertModel {
  final int id;
  final String title;
  final String message;
  final String alertType; // 'transport_disruption', 'road_condition', 'weather_emergency', 'security'
  final String severity; // 'info', 'warning', 'critical'
  final int? relatedIncidentId;
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
    this.relatedIncidentId,
    this.targetRouteId,
    this.targetRouteNumber,
    this.targetLatitude,
    this.targetLongitude,
    this.targetRadiusKm,
    this.status = 'active',
    required this.createdAt,
    this.expiresAt,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isCritical => severity.toLowerCase() == 'critical';
  bool get isWarning => severity.toLowerCase() == 'warning';

  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
      default:
        return AppColors.info;
    }
  }

  IconData get alertIcon {
    switch (alertType.toLowerCase()) {
      case 'weather_emergency':
        return Icons.thunderstorm_rounded;
      case 'road_condition':
        return Icons.add_road_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'transport_disruption':
      default:
        return Icons.warning_amber_rounded;
    }
  }

  String get displayAlertTypeName {
    switch (alertType.toLowerCase()) {
      case 'weather_emergency':
        return 'Weather Emergency';
      case 'road_condition':
        return 'Road Condition Hazard';
      case 'security':
        return 'Security Notice';
      case 'transport_disruption':
      default:
        return 'Transit Disruption';
    }
  }

  factory TravelAlertModel.fromJson(Map<String, dynamic> json) {
    return TravelAlertModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      alertType: json['alertType'] as String? ?? json['alert_type'] as String? ?? 'transport_disruption',
      severity: json['severity'] as String? ?? 'info',
      relatedIncidentId: json['relatedIncidentId'] as int? ?? json['related_incident_id'] as int?,
      targetRouteId: json['targetRouteId'] as int? ?? json['target_route_id'] as int?,
      targetRouteNumber: json['targetRouteNumber'] as String? ?? json['target_route_number'] as String?,
      targetLatitude: (json['targetLatitude'] as num?)?.toDouble() ?? (json['target_latitude'] as num?)?.toDouble(),
      targetLongitude: (json['targetLongitude'] as num?)?.toDouble() ?? (json['target_longitude'] as num?)?.toDouble(),
      targetRadiusKm: (json['targetRadiusKm'] as num?)?.toDouble() ?? (json['target_radius_km'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : (json['expires_at'] != null
              ? DateTime.tryParse(json['expires_at'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'alertType': alertType,
      'severity': severity,
      'relatedIncidentId': relatedIncidentId,
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
