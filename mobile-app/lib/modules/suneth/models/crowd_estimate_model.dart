/// TravelPulse LK — Crowd Estimate & Aggregation Model (Suneth)
class CrowdEstimateModel {
  final int id;
  final int userId;
  final int? routeId;
  final String? routeNumber;
  final int? stopId;
  final String? stopName;
  final String crowdLevel; // 'empty', 'moderate', 'crowded', 'very_crowded'
  final int? passengerWaitTimeMinutes;
  final DateTime reportedAt;

  CrowdEstimateModel({
    required this.id,
    required this.userId,
    this.routeId,
    this.routeNumber,
    this.stopId,
    this.stopName,
    required this.crowdLevel,
    this.passengerWaitTimeMinutes,
    required this.reportedAt,
  });

  factory CrowdEstimateModel.fromJson(Map<String, dynamic> json) {
    return CrowdEstimateModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? json['user_id'] as int? ?? 0,
      routeId: json['routeId'] as int? ?? json['route_id'] as int?,
      routeNumber: json['routeNumber'] as String? ?? json['route_number'] as String?,
      stopId: json['stopId'] as int? ?? json['stop_id'] as int?,
      stopName: json['stopName'] as String? ?? json['stop_name'] as String?,
      crowdLevel: json['crowdLevel'] as String? ?? json['crowd_level'] as String? ?? 'moderate',
      passengerWaitTimeMinutes: json['passengerWaitTimeMinutes'] as int? ?? json['passenger_wait_time_minutes'] as int?,
      reportedAt: json['reportedAt'] != null
          ? DateTime.tryParse(json['reportedAt'].toString()) ?? DateTime.now()
          : (json['reported_at'] != null
              ? DateTime.tryParse(json['reported_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'routeId': routeId,
      'routeNumber': routeNumber,
      'stopId': stopId,
      'stopName': stopName,
      'crowdLevel': crowdLevel,
      'passengerWaitTimeMinutes': passengerWaitTimeMinutes,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }
}

class CrowdAggregationModel {
  final String targetType; // 'stop', 'route'
  final int targetId;
  final String targetName;
  final String currentCrowdLevel; // 'empty', 'moderate', 'crowded', 'very_crowded'
  final int sampleCount;
  final double confidenceScore;
  final int? averageWaitTimeMinutes;
  final DateTime timeSlot;
  final bool isBaseline;

  CrowdAggregationModel({
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.currentCrowdLevel,
    required this.sampleCount,
    required this.confidenceScore,
    this.averageWaitTimeMinutes,
    required this.timeSlot,
    this.isBaseline = false,
  });

  bool get isRoute => targetType.toLowerCase() == 'route';
  bool get isStop => targetType.toLowerCase() == 'stop';

  factory CrowdAggregationModel.fromJson(Map<String, dynamic> json) {
    final hasRoute = json['routeId'] != null || json['route_id'] != null;
    final rId = json['routeId'] as int? ?? json['route_id'] as int?;
    final sId = json['stopId'] as int? ?? json['stop_id'] as int?;
    final targetId = json['targetId'] as int? ?? (hasRoute ? rId : sId) ?? 0;
    final targetType = json['targetType'] as String? ?? (hasRoute ? 'route' : 'stop');

    return CrowdAggregationModel(
      targetType: targetType,
      targetId: targetId,
      targetName: json['targetName'] as String? ?? (hasRoute ? 'Route $targetId' : 'Stop $targetId'),
      currentCrowdLevel: json['currentCrowdLevel'] as String? ??
          json['aggregated_crowd_level'] as String? ??
          json['aggregatedCrowdLevel'] as String? ??
          'moderate',
      sampleCount: json['sampleCount'] as int? ?? json['sample_count'] as int? ?? 1,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ??
          (json['confidence_score'] as num?)?.toDouble() ??
          50.0,
      averageWaitTimeMinutes: json['averageWaitTimeMinutes'] as int? ??
          json['average_wait_time_minutes'] as int?,
      timeSlot: json['timeSlot'] != null
          ? DateTime.tryParse(json['timeSlot'].toString()) ?? DateTime.now()
          : (json['time_slot'] != null
              ? DateTime.tryParse(json['time_slot'].toString()) ?? DateTime.now()
              : DateTime.now()),
      isBaseline: json['isBaseline'] as bool? ?? json['is_baseline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType,
      'targetId': targetId,
      'targetName': targetName,
      'currentCrowdLevel': currentCrowdLevel,
      'sampleCount': sampleCount,
      'confidenceScore': confidenceScore,
      'averageWaitTimeMinutes': averageWaitTimeMinutes,
      'timeSlot': timeSlot.toIso8601String(),
      'isBaseline': isBaseline,
    };
  }
}
