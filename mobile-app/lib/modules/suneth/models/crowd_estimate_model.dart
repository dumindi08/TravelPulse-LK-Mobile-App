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
      userId: json['userId'] as int? ?? 0,
      routeId: json['routeId'] as int?,
      routeNumber: json['routeNumber'] as String?,
      stopId: json['stopId'] as int?,
      stopName: json['stopName'] as String?,
      crowdLevel: json['crowdLevel'] as String? ?? 'moderate',
      passengerWaitTimeMinutes: json['passengerWaitTimeMinutes'] as int?,
      reportedAt: json['reportedAt'] != null
          ? DateTime.tryParse(json['reportedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
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
  final String currentCrowdLevel;
  final int sampleCount;
  final double confidenceScore;
  final DateTime timeSlot;

  CrowdAggregationModel({
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.currentCrowdLevel,
    required this.sampleCount,
    required this.confidenceScore,
    required this.timeSlot,
  });

  factory CrowdAggregationModel.fromJson(Map<String, dynamic> json) {
    return CrowdAggregationModel(
      targetType: json['targetType'] as String? ?? 'route',
      targetId: json['targetId'] as int? ?? 0,
      targetName: json['targetName'] as String? ?? '',
      currentCrowdLevel: json['currentCrowdLevel'] as String? ?? 'moderate',
      sampleCount: json['sampleCount'] as int? ?? 1,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 50.0,
      timeSlot: json['timeSlot'] != null
          ? DateTime.tryParse(json['timeSlot'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

