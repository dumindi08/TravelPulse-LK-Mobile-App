import 'dart:async';
import '../../../core/models/api_response.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';

/// TravelPulse LK — Transit Route & Schedule Service (Nisal)
/// ---------------------------------------------------------------------------
/// [TEMPORARY MOCK REPOSITORY — FOR OFFLINE DEVELOPMENT & TESTING]
/// Provides authentic Sri Lankan transit master data matching the MySQL database seeds.
/// Will connect to GET /api/v1/routes and GET /api/v1/routes/:id when backend is online.
/// ---------------------------------------------------------------------------
class RouteService {
  // Preloaded authentic Sri Lankan public transit routes
  static final List<RouteModel> _routes = [
    RouteModel(
      id: 1,
      routeNumber: '138',
      name: 'Colombo Fort - Maharagama / Homagama',
      transportType: 'bus',
      operator: 'SLTB',
      originCity: 'Pettah / Colombo Fort',
      destinationCity: 'Maharagama',
      isActive: true,
      estTotalMinutes: 48,
      currentCrowdLevel: 'crowded',
      activeDisruptionSummary: 'Traffic obstruction near Town Hall roundabout due to breakdown',
      stops: [
        RouteStopSequenceModel(
          id: 1001,
          routeId: 1,
          stopId: 101,
          stopName: 'Pettah Main Bus Terminal',
          stopOrder: 1,
          latitude: 6.9355,
          longitude: 79.8530,
          distanceFromPrevKm: 0.0,
          estMinutesFromPrev: 0,
        ),
        RouteStopSequenceModel(
          id: 1002,
          routeId: 1,
          stopId: 102,
          stopName: 'Colombo Fort Railway Station',
          stopOrder: 2,
          latitude: 6.9344,
          longitude: 79.8540,
          distanceFromPrevKm: 0.8,
          estMinutesFromPrev: 4,
        ),
        RouteStopSequenceModel(
          id: 1003,
          routeId: 1,
          stopId: 103,
          stopName: 'Technical Junction (Maradana)',
          stopOrder: 3,
          latitude: 6.9272,
          longitude: 79.8615,
          distanceFromPrevKm: 1.4,
          estMinutesFromPrev: 6,
        ),
        RouteStopSequenceModel(
          id: 1004,
          routeId: 1,
          stopId: 104,
          stopName: 'Town Hall / Viharamahadevi Park',
          stopOrder: 4,
          latitude: 6.9147,
          longitude: 79.8653,
          distanceFromPrevKm: 2.1,
          estMinutesFromPrev: 9,
        ),
        RouteStopSequenceModel(
          id: 1005,
          routeId: 1,
          stopId: 105,
          stopName: 'Bambalapitiya Junction',
          stopOrder: 5,
          latitude: 6.8920,
          longitude: 79.8580,
          distanceFromPrevKm: 3.5,
          estMinutesFromPrev: 12,
        ),
        RouteStopSequenceModel(
          id: 1006,
          routeId: 1,
          stopId: 106,
          stopName: 'Nugegoda Supermarket Stop',
          stopOrder: 6,
          latitude: 6.8724,
          longitude: 79.8898,
          distanceFromPrevKm: 4.8,
          estMinutesFromPrev: 16,
        ),
        RouteStopSequenceModel(
          id: 1007,
          routeId: 1,
          stopId: 107,
          stopName: 'Maharagama Central Bus Stand',
          stopOrder: 7,
          latitude: 6.8485,
          longitude: 79.9268,
          distanceFromPrevKm: 5.2,
          estMinutesFromPrev: 18,
        ),
      ],
    ),
    RouteModel(
      id: 2,
      routeNumber: '100',
      name: 'Colombo Fort - Panadura (Galle Road)',
      transportType: 'bus',
      operator: 'Private',
      originCity: 'Pettah',
      destinationCity: 'Panadura',
      isActive: true,
      estTotalMinutes: 65,
      currentCrowdLevel: 'moderate',
      stops: [
        RouteStopSequenceModel(
          id: 2001,
          routeId: 2,
          stopId: 101,
          stopName: 'Pettah Central Bus Stand',
          stopOrder: 1,
          latitude: 6.9355,
          longitude: 79.8530,
          distanceFromPrevKm: 0.0,
          estMinutesFromPrev: 0,
        ),
        RouteStopSequenceModel(
          id: 2002,
          routeId: 2,
          stopId: 108,
          stopName: 'Kollupitiya Junction',
          stopOrder: 2,
          latitude: 6.9050,
          longitude: 79.8510,
          distanceFromPrevKm: 3.2,
          estMinutesFromPrev: 11,
        ),
        RouteStopSequenceModel(
          id: 2003,
          routeId: 2,
          stopId: 105,
          stopName: 'Bambalapitiya Junction',
          stopOrder: 3,
          latitude: 6.8920,
          longitude: 79.8580,
          distanceFromPrevKm: 1.8,
          estMinutesFromPrev: 7,
        ),
        RouteStopSequenceModel(
          id: 2004,
          routeId: 2,
          stopId: 109,
          stopName: 'Wellawatte Station Stop',
          stopOrder: 4,
          latitude: 6.8745,
          longitude: 79.8605,
          distanceFromPrevKm: 2.0,
          estMinutesFromPrev: 8,
        ),
        RouteStopSequenceModel(
          id: 2005,
          routeId: 2,
          stopId: 110,
          stopName: 'Mount Lavinia Hotel Road',
          stopOrder: 5,
          latitude: 6.8378,
          longitude: 79.8642,
          distanceFromPrevKm: 4.5,
          estMinutesFromPrev: 15,
        ),
        RouteStopSequenceModel(
          id: 2006,
          routeId: 2,
          stopId: 111,
          stopName: 'Moratuwa Town Stop',
          stopOrder: 6,
          latitude: 6.7730,
          longitude: 79.8816,
          distanceFromPrevKm: 6.5,
          estMinutesFromPrev: 22,
        ),
        RouteStopSequenceModel(
          id: 2007,
          routeId: 2,
          stopId: 112,
          stopName: 'Panadura Bus Stand',
          stopOrder: 7,
          latitude: 6.7135,
          longitude: 79.9074,
          distanceFromPrevKm: 7.2,
          estMinutesFromPrev: 25,
        ),
      ],
    ),
    RouteModel(
      id: 3,
      routeNumber: 'MAIN-RLY',
      name: 'Main Line: Colombo Fort - Polgahawela / Kandy',
      transportType: 'train',
      operator: 'Sri Lanka Railways',
      originCity: 'Colombo Fort',
      destinationCity: 'Kandy',
      isActive: true,
      estTotalMinutes: 150,
      currentCrowdLevel: 'very_crowded',
      activeDisruptionSummary: 'Signal failure between Ragama and Gampaha causing 15 min delay',
      stops: [
        RouteStopSequenceModel(
          id: 3001,
          routeId: 3,
          stopId: 102,
          stopName: 'Colombo Fort Railway Station',
          stopOrder: 1,
          latitude: 6.9344,
          longitude: 79.8540,
          distanceFromPrevKm: 0.0,
          estMinutesFromPrev: 0,
        ),
        RouteStopSequenceModel(
          id: 3002,
          routeId: 3,
          stopId: 113,
          stopName: 'Maradana Railway Station',
          stopOrder: 2,
          latitude: 6.9272,
          longitude: 79.8648,
          distanceFromPrevKm: 2.3,
          estMinutesFromPrev: 5,
        ),
        RouteStopSequenceModel(
          id: 3003,
          routeId: 3,
          stopId: 114,
          stopName: 'Dematagoda Station',
          stopOrder: 3,
          latitude: 6.9340,
          longitude: 79.8790,
          distanceFromPrevKm: 2.1,
          estMinutesFromPrev: 4,
        ),
        RouteStopSequenceModel(
          id: 3004,
          routeId: 3,
          stopId: 115,
          stopName: 'Ragama Junction Railway Station',
          stopOrder: 4,
          latitude: 7.0270,
          longitude: 79.9230,
          distanceFromPrevKm: 14.5,
          estMinutesFromPrev: 20,
        ),
        RouteStopSequenceModel(
          id: 3005,
          routeId: 3,
          stopId: 116,
          stopName: 'Gampaha Railway Station',
          stopOrder: 5,
          latitude: 7.0910,
          longitude: 79.9960,
          distanceFromPrevKm: 12.0,
          estMinutesFromPrev: 18,
        ),
      ],
    ),
    RouteModel(
      id: 4,
      routeNumber: '177',
      name: 'Kaduwela - Kollupitiya (via Malabe & Battaramulla)',
      transportType: 'bus',
      operator: 'SLTB',
      originCity: 'Kaduwela',
      destinationCity: 'Kollupitiya',
      isActive: true,
      estTotalMinutes: 52,
      currentCrowdLevel: 'empty',
      stops: [
        RouteStopSequenceModel(
          id: 4001,
          routeId: 4,
          stopId: 117,
          stopName: 'Kaduwela Bus Stand',
          stopOrder: 1,
          latitude: 6.9328,
          longitude: 79.9830,
          distanceFromPrevKm: 0.0,
          estMinutesFromPrev: 0,
        ),
        RouteStopSequenceModel(
          id: 4002,
          routeId: 4,
          stopId: 118,
          stopName: 'Malabe Junction',
          stopOrder: 2,
          latitude: 6.9042,
          longitude: 79.9548,
          distanceFromPrevKm: 4.8,
          estMinutesFromPrev: 14,
        ),
        RouteStopSequenceModel(
          id: 4003,
          routeId: 4,
          stopId: 119,
          stopName: 'Battaramulla Town Stop',
          stopOrder: 3,
          latitude: 6.8980,
          longitude: 79.9210,
          distanceFromPrevKm: 3.6,
          estMinutesFromPrev: 10,
        ),
        RouteStopSequenceModel(
          id: 4004,
          routeId: 4,
          stopId: 108,
          stopName: 'Kollupitiya Junction',
          stopOrder: 4,
          latitude: 6.9050,
          longitude: 79.8510,
          distanceFromPrevKm: 8.2,
          estMinutesFromPrev: 28,
        ),
      ],
    ),
  ];

  /// Get list of transit routes with optional search and transport type filter
  Future<ApiResponse<List<RouteModel>>> getRoutes({
    String? searchQuery,
    String? transportType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var filtered = List<RouteModel>.from(_routes);

    if (transportType != null && transportType.isNotEmpty && transportType.toLowerCase() != 'all') {
      filtered = filtered.where((r) => r.transportType.toLowerCase() == transportType.toLowerCase()).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((r) =>
          r.routeNumber.toLowerCase().contains(q) ||
          r.name.toLowerCase().contains(q) ||
          r.originCity.toLowerCase().contains(q) ||
          r.destinationCity.toLowerCase().contains(q) ||
          r.stops.any((s) => s.stopName.toLowerCase().contains(q))).toList();
    }

    return ApiResponse.success(
      message: 'Routes retrieved successfully',
      data: filtered,
    );
  }

  /// Get detailed route by ID including ordered stops and timetable
  Future<ApiResponse<RouteModel>> getRouteById(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final route = _routes.firstWhere(
      (r) => r.id == id,
      orElse: () => RouteModel(
        id: 0,
        routeNumber: '',
        name: '',
        transportType: 'bus',
        originCity: '',
        destinationCity: '',
      ),
    );

    if (route.id == 0) {
      return ApiResponse.failure(
        message: 'Route with ID $id not found.',
        code: 'ROUTE_NOT_FOUND',
        statusCode: 404,
      );
    }

    return ApiResponse.success(
      message: 'Route details loaded',
      data: route,
    );
  }

  /// Get all master stops across routes
  Future<ApiResponse<List<StopModel>>> getAllStops() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final Map<int, StopModel> uniqueStops = {};
    for (var route in _routes) {
      for (var s in route.stops) {
        if (!uniqueStops.containsKey(s.stopId)) {
          uniqueStops[s.stopId] = StopModel(
            id: s.stopId,
            name: s.stopName,
            latitude: s.latitude,
            longitude: s.longitude,
            city: 'Colombo Zone',
          );
        }
      }
    }

    return ApiResponse.success(
      message: 'Stops loaded',
      data: uniqueStops.values.toList(),
    );
  }
}

