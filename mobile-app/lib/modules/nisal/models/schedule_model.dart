/// TravelPulse LK — Route Schedule / Timetable Model (Nisal)
/// Aligns with MySQL `route_schedules` table in 01_nisal_user_transport_schema.sql.
class RouteScheduleModel {
  final int id;
  final int routeId;
  final String departureTime; // e.g. "06:30 AM" or "06:30:00"
  final String arrivalTime;   // e.g. "07:18 AM" or "07:18:00"
  final String dayOfWeek;     // 'all', 'weekday', 'weekend', 'monday', etc.
  final String tripDirection; // 'outbound', 'inbound'
  final bool isActive;
  final String? vehiclePlate; // Optional vehicle identifier

  RouteScheduleModel({
    required this.id,
    required this.routeId,
    required this.departureTime,
    required this.arrivalTime,
    this.dayOfWeek = 'all',
    this.tripDirection = 'outbound',
    this.isActive = true,
    this.vehiclePlate,
  });

  bool get isOutbound => tripDirection.toLowerCase() == 'outbound';
  bool get isInbound => tripDirection.toLowerCase() == 'inbound';

  factory RouteScheduleModel.fromJson(Map<String, dynamic> json) {
    return RouteScheduleModel(
      id: json['id'] as int? ?? 0,
      routeId: json['routeId'] as int? ?? (json['route_id'] as int? ?? 0),
      departureTime: json['departureTime'] as String? ?? (json['departure_time'] as String? ?? ''),
      arrivalTime: json['arrivalTime'] as String? ?? (json['arrival_time'] as String? ?? ''),
      dayOfWeek: json['dayOfWeek'] as String? ?? (json['day_of_week'] as String? ?? 'all'),
      tripDirection: json['tripDirection'] as String? ?? (json['trip_direction'] as String? ?? 'outbound'),
      isActive: json['isActive'] as bool? ?? (json['is_active'] as bool? ?? true),
      vehiclePlate: json['vehiclePlate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'dayOfWeek': dayOfWeek,
      'tripDirection': tripDirection,
      'isActive': isActive,
      'vehiclePlate': vehiclePlate,
    };
  }
}

