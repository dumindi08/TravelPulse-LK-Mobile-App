/// TravelPulse LK — Route Stop / Station Model (Nisal)
class StopModel {
  final int id;
  final String name;
  final String? stopCode;
  final double latitude;
  final double longitude;
  final String city;
  final bool isActive;

  StopModel({
    required this.id,
    required this.name,
    this.stopCode,
    required this.latitude,
    required this.longitude,
    required this.city,
    this.isActive = true,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      stopCode: json['stopCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stopCode': stopCode,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'isActive': isActive,
    };
  }
}

class RouteStopSequenceModel {
  final int id;
  final int routeId;
  final int stopId;
  final String stopName;
  final int stopOrder;
  final double latitude;
  final double longitude;
  final double distanceFromPrevKm;
  final int estMinutesFromPrev;

  RouteStopSequenceModel({
    required this.id,
    required this.routeId,
    required this.stopId,
    required this.stopName,
    required this.stopOrder,
    required this.latitude,
    required this.longitude,
    this.distanceFromPrevKm = 0.0,
    this.estMinutesFromPrev = 0,
  });

  factory RouteStopSequenceModel.fromJson(Map<String, dynamic> json) {
    return RouteStopSequenceModel(
      id: json['id'] as int? ?? 0,
      routeId: json['routeId'] as int? ?? 0,
      stopId: json['stopId'] as int? ?? 0,
      stopName: json['name'] as String? ?? json['stopName'] as String? ?? '',
      stopOrder: json['stopOrder'] as int? ?? 1,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceFromPrevKm: (json['distanceFromPrevKm'] as num?)?.toDouble() ?? 0.0,
      estMinutesFromPrev: json['estMinutesFromPrev'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'stopId': stopId,
      'stopName': stopName,
      'stopOrder': stopOrder,
      'latitude': latitude,
      'longitude': longitude,
      'distanceFromPrevKm': distanceFromPrevKm,
      'estMinutesFromPrev': estMinutesFromPrev,
    };
  }
}

