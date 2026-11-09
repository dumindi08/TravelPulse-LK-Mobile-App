import 'stop_model.dart';

/// TravelPulse LK — Public Transport Route Model (Nisal)
class RouteModel {
  final int id;
  final String routeNumber;
  final String name;
  final String transportType; // 'bus', 'train'
  final String? operator;
  final String originCity;
  final String destinationCity;
  final bool isActive;
  final List<RouteStopSequenceModel> stops;
  final String? activeDisruptionSummary;
  final String? currentCrowdLevel;
  final int estTotalMinutes;

  RouteModel({
    required this.id,
    required this.routeNumber,
    required this.name,
    required this.transportType,
    this.operator,
    required this.originCity,
    required this.destinationCity,
    this.isActive = true,
    this.stops = const [],
    this.activeDisruptionSummary,
    this.currentCrowdLevel,
    this.estTotalMinutes = 45,
  });

  bool get isBus => transportType.toLowerCase() == 'bus';
  bool get isTrain => transportType.toLowerCase() == 'train';
  bool get hasDisruption => activeDisruptionSummary != null && activeDisruptionSummary!.isNotEmpty;

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as int? ?? 0,
      routeNumber: json['routeNumber'] as String? ?? '',
      name: json['name'] as String? ?? '',
      transportType: json['transportType'] as String? ?? 'bus',
      operator: json['operator'] as String?,
      originCity: json['originCity'] as String? ?? '',
      destinationCity: json['destinationCity'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      stops: (json['stops'] as List<dynamic>?)
              ?.map((e) => RouteStopSequenceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activeDisruptionSummary: json['activeDisruptionSummary'] as String?,
      currentCrowdLevel: json['currentCrowdLevel'] as String?,
      estTotalMinutes: json['estTotalMinutes'] as int? ?? 45,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeNumber': routeNumber,
      'name': name,
      'transportType': transportType,
      'operator': operator,
      'originCity': originCity,
      'destinationCity': destinationCity,
      'isActive': isActive,
      'stops': stops.map((s) => s.toJson()).toList(),
      'activeDisruptionSummary': activeDisruptionSummary,
      'currentCrowdLevel': currentCrowdLevel,
      'estTotalMinutes': estTotalMinutes,
    };
  }
}

