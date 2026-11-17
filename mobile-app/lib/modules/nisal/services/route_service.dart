import 'dart:async';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../models/schedule_model.dart';

/// TravelPulse LK — Transit Route & Schedule Service (Nisal)
/// Connects to Express backend (/api/v1/routes) with authentic offline fallback.
class RouteService {
  final ApiService _api;

  RouteService({ApiService? api}) : _api = api ?? ApiService();
  // Preloaded authentic Sri Lankan public transit routes
  static final List<RouteModel> _routes = [
    RouteModel(
      id: 1,
      routeNumber: '138',
      name: 'Colombo Fort - Maharagama / Homagama',
      transportType: 'bus',
      operator: 'SLTB',
      originCity: 'Colombo Fort',
      destinationCity: 'Maharagama',
      isActive: true,
      estTotalMinutes: 48,
      currentCrowdLevel: 'crowded',
      activeDisruptionSummary: 'Traffic obstruction near Town Hall roundabout due to vehicle breakdown',
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
      originCity: 'Colombo Fort',
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
        RouteStopSequenceModel(
          id: 3006,
          routeId: 3,
          stopId: 121,
          stopName: 'Polgahawela Junction',
          stopOrder: 6,
          latitude: 7.3320,
          longitude: 80.3010,
          distanceFromPrevKm: 42.0,
          estMinutesFromPrev: 45,
        ),
        RouteStopSequenceModel(
          id: 3007,
          routeId: 3,
          stopId: 122,
          stopName: 'Kandy Railway Station',
          stopOrder: 7,
          latitude: 7.2906,
          longitude: 80.6337,
          distanceFromPrevKm: 51.0,
          estMinutesFromPrev: 60,
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
    RouteModel(
      id: 5,
      routeNumber: '120',
      name: 'Colombo Fort - Horana (via Piliyandala)',
      transportType: 'bus',
      operator: 'Private',
      originCity: 'Colombo Fort',
      destinationCity: 'Horana',
      isActive: true,
      estTotalMinutes: 70,
      currentCrowdLevel: 'moderate',
      stops: [
        RouteStopSequenceModel(
          id: 5001,
          routeId: 5,
          stopId: 101,
          stopName: 'Pettah Main Bus Stand',
          stopOrder: 1,
          latitude: 6.9355,
          longitude: 79.8530,
          distanceFromPrevKm: 0.0,
          estMinutesFromPrev: 0,
        ),
        RouteStopSequenceModel(
          id: 5002,
          routeId: 5,
          stopId: 104,
          stopName: 'Town Hall / Viharamahadevi Park',
          stopOrder: 2,
          latitude: 6.9147,
          longitude: 79.8653,
          distanceFromPrevKm: 3.2,
          estMinutesFromPrev: 12,
        ),
        RouteStopSequenceModel(
          id: 5003,
          routeId: 5,
          stopId: 106,
          stopName: 'Nugegoda Supermarket Stop',
          stopOrder: 3,
          latitude: 6.8724,
          longitude: 79.8898,
          distanceFromPrevKm: 4.5,
          estMinutesFromPrev: 15,
        ),
        RouteStopSequenceModel(
          id: 5004,
          routeId: 5,
          stopId: 123,
          stopName: 'Piliyandala Clock Tower',
          stopOrder: 4,
          latitude: 6.8016,
          longitude: 79.9227,
          distanceFromPrevKm: 8.5,
          estMinutesFromPrev: 24,
        ),
        RouteStopSequenceModel(
          id: 5005,
          routeId: 5,
          stopId: 124,
          stopName: 'Horana Bus Terminal',
          stopOrder: 5,
          latitude: 6.7167,
          longitude: 80.0633,
          distanceFromPrevKm: 14.8,
          estMinutesFromPrev: 32,
        ),
      ],
    ),
    RouteModel(
      id: 6,
      routeNumber: 'COAST-RLY',
      name: 'Coastal Line: Colombo Fort - Galle / Matara',
      transportType: 'train',
      operator: 'Sri Lanka Railways',
      originCity: 'Colombo Fort',
      destinationCity: 'Galle',
      isActive: true,
      estTotalMinutes: 125,
      currentCrowdLevel: 'moderate',
      stops: [
        RouteStopSequenceModel(
          id: 6001,
          routeId: 6,
          stopId: 102,
          stopName: 'Colombo Fort Railway Station',
          stopOrder: 1,
          latitude: 6.9344,
          longitude: 79.8540,
          distanceFromPrevKm: 0.0,
          estMinutesFromPrev: 0,
        ),
        RouteStopSequenceModel(
          id: 6002,
          routeId: 6,
          stopId: 108,
          stopName: 'Kollupitiya Station',
          stopOrder: 2,
          latitude: 6.9050,
          longitude: 79.8510,
          distanceFromPrevKm: 3.5,
          estMinutesFromPrev: 6,
        ),
        RouteStopSequenceModel(
          id: 6003,
          routeId: 6,
          stopId: 110,
          stopName: 'Mount Lavinia Station',
          stopOrder: 3,
          latitude: 6.8378,
          longitude: 79.8642,
          distanceFromPrevKm: 8.0,
          estMinutesFromPrev: 14,
        ),
        RouteStopSequenceModel(
          id: 6004,
          routeId: 6,
          stopId: 112,
          stopName: 'Panadura Station',
          stopOrder: 4,
          latitude: 6.7135,
          longitude: 79.9074,
          distanceFromPrevKm: 16.5,
          estMinutesFromPrev: 24,
        ),
        RouteStopSequenceModel(
          id: 6005,
          routeId: 6,
          stopId: 125,
          stopName: 'Galle Railway Station',
          stopOrder: 5,
          latitude: 6.0367,
          longitude: 80.2170,
          distanceFromPrevKm: 88.0,
          estMinutesFromPrev: 85,
        ),
      ],
    ),
  ];

  // Preloaded authentic Sri Lankan transit schedules
  static final List<RouteScheduleModel> _schedules = [
    // Route 1 (138) - Outbound (Colombo Fort -> Maharagama)
    RouteScheduleModel(id: 101, routeId: 1, departureTime: '06:00 AM', arrivalTime: '06:48 AM', dayOfWeek: 'weekday', tripDirection: 'outbound', vehiclePlate: 'NB-4512'),
    RouteScheduleModel(id: 102, routeId: 1, departureTime: '06:30 AM', arrivalTime: '07:18 AM', dayOfWeek: 'weekday', tripDirection: 'outbound', vehiclePlate: 'NB-7821'),
    RouteScheduleModel(id: 103, routeId: 1, departureTime: '07:00 AM', arrivalTime: '07:50 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'NC-1044'),
    RouteScheduleModel(id: 104, routeId: 1, departureTime: '07:30 AM', arrivalTime: '08:22 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'NA-9932'),
    RouteScheduleModel(id: 105, routeId: 1, departureTime: '08:15 AM', arrivalTime: '09:05 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'NB-5021'),
    RouteScheduleModel(id: 106, routeId: 1, departureTime: '05:15 PM', arrivalTime: '06:08 PM', dayOfWeek: 'weekday', tripDirection: 'outbound', vehiclePlate: 'NB-3389'),

    // Route 1 (138) - Inbound (Maharagama -> Colombo Fort)
    RouteScheduleModel(id: 111, routeId: 1, departureTime: '06:00 AM', arrivalTime: '06:48 AM', dayOfWeek: 'all', tripDirection: 'inbound', vehiclePlate: 'NB-6211'),
    RouteScheduleModel(id: 112, routeId: 1, departureTime: '06:45 AM', arrivalTime: '07:35 AM', dayOfWeek: 'weekday', tripDirection: 'inbound', vehiclePlate: 'NB-4512'),
    RouteScheduleModel(id: 113, routeId: 1, departureTime: '07:20 AM', arrivalTime: '08:12 AM', dayOfWeek: 'weekday', tripDirection: 'inbound', vehiclePlate: 'NC-2133'),
    RouteScheduleModel(id: 114, routeId: 1, departureTime: '08:00 AM', arrivalTime: '08:50 AM', dayOfWeek: 'all', tripDirection: 'inbound', vehiclePlate: 'NA-9932'),

    // Route 2 (100) - Outbound (Colombo Fort -> Panadura)
    RouteScheduleModel(id: 201, routeId: 2, departureTime: '06:15 AM', arrivalTime: '07:20 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'WP-ND-4412'),
    RouteScheduleModel(id: 202, routeId: 2, departureTime: '07:00 AM', arrivalTime: '08:05 AM', dayOfWeek: 'weekday', tripDirection: 'outbound', vehiclePlate: 'WP-ND-6789'),
    RouteScheduleModel(id: 203, routeId: 2, departureTime: '08:00 AM', arrivalTime: '09:05 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'WP-NE-1022'),

    // Route 2 (100) - Inbound (Panadura -> Colombo Fort)
    RouteScheduleModel(id: 211, routeId: 2, departureTime: '06:00 AM', arrivalTime: '07:05 AM', dayOfWeek: 'all', tripDirection: 'inbound', vehiclePlate: 'WP-ND-6789'),
    RouteScheduleModel(id: 212, routeId: 2, departureTime: '07:15 AM', arrivalTime: '08:20 AM', dayOfWeek: 'weekday', tripDirection: 'inbound', vehiclePlate: 'WP-NE-1022'),

    // Route 3 (MAIN-RLY) - Colombo Fort to Kandy (Trains)
    RouteScheduleModel(id: 301, routeId: 3, departureTime: '05:55 AM', arrivalTime: '08:25 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'Express 1005 (Podi Menike)'),
    RouteScheduleModel(id: 302, routeId: 3, departureTime: '07:00 AM', arrivalTime: '09:30 AM', dayOfWeek: 'weekday', tripDirection: 'outbound', vehiclePlate: 'Intercity 1029'),
    RouteScheduleModel(id: 303, routeId: 3, departureTime: '08:30 AM', arrivalTime: '11:15 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'Udarata Menike 1015'),
    RouteScheduleModel(id: 304, routeId: 3, departureTime: '03:35 PM', arrivalTime: '06:15 PM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'Express 1007'),

    // Route 3 (MAIN-RLY) - Inbound (Kandy to Colombo Fort)
    RouteScheduleModel(id: 311, routeId: 3, departureTime: '06:15 AM', arrivalTime: '08:45 AM', dayOfWeek: 'all', tripDirection: 'inbound', vehiclePlate: 'Intercity 1030'),
    RouteScheduleModel(id: 312, routeId: 3, departureTime: '10:30 AM', arrivalTime: '01:10 PM', dayOfWeek: 'all', tripDirection: 'inbound', vehiclePlate: 'Udarata Menike 1016'),

    // Route 4 (177) - Outbound & Inbound
    RouteScheduleModel(id: 401, routeId: 4, departureTime: '06:30 AM', arrivalTime: '07:22 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'NA-5521'),
    RouteScheduleModel(id: 402, routeId: 4, departureTime: '07:15 AM', arrivalTime: '08:07 AM', dayOfWeek: 'weekday', tripDirection: 'outbound', vehiclePlate: 'NA-8812'),
    RouteScheduleModel(id: 411, routeId: 4, departureTime: '06:45 AM', arrivalTime: '07:37 AM', dayOfWeek: 'all', tripDirection: 'inbound', vehiclePlate: 'NA-5521'),

    // Route 5 (120) - Outbound & Inbound
    RouteScheduleModel(id: 501, routeId: 5, departureTime: '06:20 AM', arrivalTime: '07:30 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'WP-ND-8901'),
    RouteScheduleModel(id: 502, routeId: 5, departureTime: '07:30 AM', arrivalTime: '08:40 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'WP-ND-9012'),

    // Route 6 (COAST-RLY) - Coastal Express
    RouteScheduleModel(id: 601, routeId: 6, departureTime: '06:50 AM', arrivalTime: '08:55 AM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'Ruhunu Kumari 8058'),
    RouteScheduleModel(id: 602, routeId: 6, departureTime: '02:25 PM', arrivalTime: '04:30 PM', dayOfWeek: 'all', tripDirection: 'outbound', vehiclePlate: 'Galu Kumari 8056'),
  ];

  /// Get list of transit routes with optional search and transport type filter
  Future<ApiResponse<List<RouteModel>>> getRoutes({
    String? searchQuery,
    String? transportType,
  }) async {
    // 1. Attempt live HTTP query against backend (/api/v1/routes)
    final query = <String, String>{};
    if (transportType != null && transportType.isNotEmpty && transportType.toLowerCase() != 'all') {
      query['transportType'] = transportType;
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query['origin'] = searchQuery.trim();
    }

    final apiRes = await _api.get<List<RouteModel>>(
      '/routes',
      queryParams: query.isNotEmpty ? query : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => RouteModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
        }
        return <RouteModel>[];
      },
    );

    if (apiRes.isSuccess && apiRes.data != null && apiRes.data!.isNotEmpty) {
      return apiRes;
    }

    // 2. Offline fallback simulation
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
      message: 'Routes retrieved successfully (Offline mode)',
      data: filtered,
    );
  }

  /// Advanced search for routes connecting origin and destination
  Future<ApiResponse<List<RouteModel>>> searchRoutesByOriginDestination({
    required String origin,
    required String destination,
    String? transportType,
  }) async {
    // 1. Attempt live HTTP query against backend (/api/v1/routes)
    final query = <String, String>{
      'origin': origin.trim(),
      'destination': destination.trim(),
    };
    if (transportType != null && transportType.isNotEmpty && transportType.toLowerCase() != 'all') {
      query['transportType'] = transportType;
    }

    final apiRes = await _api.get<List<RouteModel>>(
      '/routes',
      queryParams: query,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => RouteModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
        }
        return <RouteModel>[];
      },
    );

    if (apiRes.isSuccess && apiRes.data != null && apiRes.data!.isNotEmpty) {
      return apiRes;
    }

    // 2. Offline fallback simulation
    final orig = origin.trim().toLowerCase();
    final dest = destination.trim().toLowerCase();

    var candidates = List<RouteModel>.from(_routes);

    if (transportType != null && transportType.isNotEmpty && transportType.toLowerCase() != 'all') {
      candidates = candidates.where((r) => r.transportType.toLowerCase() == transportType.toLowerCase()).toList();
    }

    final List<RouteModel> matched = [];

    for (var route in candidates) {
      // 1. Check endpoints match
      final matchEndpoint = (route.originCity.toLowerCase().contains(orig) || orig.isEmpty) &&
          (route.destinationCity.toLowerCase().contains(dest) || dest.isEmpty);

      // 2. Check stops sequence: origin stop must appear before destination stop
      int origIdx = -1;
      int destIdx = -1;

      for (int i = 0; i < route.stops.length; i++) {
        final stopName = route.stops[i].stopName.toLowerCase();
        if (orig.isNotEmpty && origIdx == -1 && stopName.contains(orig)) {
          origIdx = i;
        }
        if (dest.isNotEmpty && stopName.contains(dest)) {
          destIdx = i;
        }
      }

      final matchStops = (orig.isEmpty || origIdx != -1) &&
          (dest.isEmpty || destIdx != -1) &&
          (orig.isEmpty || dest.isEmpty || origIdx <= destIdx);

      if (matchEndpoint || matchStops) {
        matched.add(route);
      }
    }

    return ApiResponse.success(
      message: 'Found ${matched.length} routes matching query (Offline mode)',
      data: matched,
    );
  }

  /// Get detailed route by ID including ordered stops and timetable
  Future<ApiResponse<RouteModel>> getRouteById(int id) async {
    // 1. Attempt live HTTP query
    final apiRes = await _api.get<RouteModel>(
      '/routes/$id',
      fromJsonT: (json) => RouteModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    if (apiRes.isSuccess && apiRes.data != null) {
      return apiRes;
    }

    // 2. Offline fallback simulation
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
      message: 'Route details loaded (Offline mode)',
      data: route,
    );
  }

  /// Get scheduled timetables for a specific route
  Future<ApiResponse<List<RouteScheduleModel>>> getRouteSchedules(
    int routeId, {
    String? direction,
    String? dayOfWeek,
  }) async {
    // 1. Attempt live HTTP query
    final query = <String, String>{};
    if (direction != null && direction.isNotEmpty) query['direction'] = direction;
    if (dayOfWeek != null && dayOfWeek.isNotEmpty) query['dayOfWeek'] = dayOfWeek;

    final apiRes = await _api.get<List<RouteScheduleModel>>(
      '/routes/$routeId/schedules',
      queryParams: query.isNotEmpty ? query : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => RouteScheduleModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
        }
        return <RouteScheduleModel>[];
      },
    );

    if (apiRes.isSuccess && apiRes.data != null && apiRes.data!.isNotEmpty) {
      return apiRes;
    }

    // 2. Offline fallback simulation
    var list = _schedules.where((s) => s.routeId == routeId && s.isActive).toList();

    if (direction != null && direction.isNotEmpty && direction != 'all') {
      list = list.where((s) => s.tripDirection.toLowerCase() == direction.toLowerCase()).toList();
    }

    if (dayOfWeek != null && dayOfWeek.isNotEmpty && dayOfWeek != 'all') {
      list = list.where((s) => s.dayOfWeek == 'all' || s.dayOfWeek.toLowerCase() == dayOfWeek.toLowerCase()).toList();
    }

    return ApiResponse.success(
      message: 'Schedules loaded (Offline mode)',
      data: list,
    );
  }

  /// Get all master stops across routes
  Future<ApiResponse<List<StopModel>>> getAllStops() async {
    // 1. Attempt live HTTP query against backend (/api/v1/routes/stops)
    final apiRes = await _api.get<List<StopModel>>(
      '/routes/stops',
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => StopModel.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        return <StopModel>[];
      },
    );

    if (apiRes.isSuccess && apiRes.data != null && apiRes.data!.isNotEmpty) {
      return apiRes;
    }

    // 2. Offline fallback simulation
    final Map<int, StopModel> uniqueStops = {};
    for (var route in _routes) {
      for (var s in route.stops) {
        if (!uniqueStops.containsKey(s.stopId)) {
          uniqueStops[s.stopId] = StopModel(
            id: s.stopId,
            name: s.stopName,
            latitude: s.latitude,
            longitude: s.longitude,
            city: 'Western Province',
          );
        }
      }
    }

    return ApiResponse.success(
      message: 'Stops loaded (Offline mode)',
      data: uniqueStops.values.toList(),
    );
  }
}
