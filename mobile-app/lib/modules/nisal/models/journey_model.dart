/// TravelPulse LK — Commuter Journey Model (Nisal)
class JourneyModel {
  final int id;
  final int userId;
  final int routeId;
  final String routeNumber;
  final String routeName;
  final int originStopId;
  final String originStopName;
  final int destinationStopId;
  final String destinationStopName;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // 'planned', 'in_progress', 'completed', 'cancelled'

  JourneyModel({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.routeNumber,
    required this.routeName,
    required this.originStopId,
    required this.originStopName,
    required this.destinationStopId,
    required this.destinationStopName,
    required this.startTime,
    this.endTime,
    this.status = 'planned',
  });

  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      routeId: json['routeId'] as int? ?? 0,
      routeNumber: json['routeNumber'] as String? ?? '',
      routeName: json['routeName'] as String? ?? '',
      originStopId: json['originStopId'] as int? ?? 0,
      originStopName: json['originStopName'] as String? ?? '',
      destinationStopId: json['destinationStopId'] as int? ?? 0,
      destinationStopName: json['destinationStopName'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : null,
      status: json['status'] as String? ?? 'planned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'routeId': routeId,
      'routeNumber': routeNumber,
      'routeName': routeName,
      'originStopId': originStopId,
      'originStopName': originStopName,
      'destinationStopId': destinationStopId,
      'destinationStopName': destinationStopName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
    };
  }
}

