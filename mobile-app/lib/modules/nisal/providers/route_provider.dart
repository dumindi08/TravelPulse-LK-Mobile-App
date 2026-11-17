import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../models/schedule_model.dart';
import '../services/route_service.dart';

/// TravelPulse LK — Route, Stop & Schedule State Provider (Nisal)
/// Manages transport route discovery, origin-destination route search,
/// stop sequence viewing, and timetable schedules.
class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();
  final LocalStorageService _storage = LocalStorageService();

  List<RouteModel> _routes = [];
  List<RouteModel> _searchResults = [];
  List<StopModel> _allStops = [];
  List<RouteScheduleModel> _schedules = [];
  RouteModel? _selectedRoute;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isSchedulesLoading = false;
  String? _errorMessage;

  String _selectedTransportType = 'all'; // 'all', 'bus', 'train'
  String _searchQuery = '';
  String _originQuery = '';
  String _destinationQuery = '';
  String _selectedScheduleDirection = 'outbound'; // 'outbound', 'inbound'
  String _selectedScheduleDay = 'all'; // 'all', 'weekday', 'weekend'

  List<RouteModel> get routes => _routes;
  List<RouteModel> get searchResults => _searchResults;
  List<StopModel> get allStops => _allStops;
  List<RouteScheduleModel> get schedules => _schedules;
  RouteModel? get selectedRoute => _selectedRoute;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isSchedulesLoading => _isSchedulesLoading;
  String? get errorMessage => _errorMessage;

  String get selectedTransportType => _selectedTransportType;
  String get searchQuery => _searchQuery;
  String get originQuery => _originQuery;
  String get destinationQuery => _destinationQuery;
  String get selectedScheduleDirection => _selectedScheduleDirection;
  String get selectedScheduleDay => _selectedScheduleDay;

  RouteProvider() {
    loadRoutes();
    _loadAllStops();
  }

  Future<void> loadRoutes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _routeService.getRoutes(
        searchQuery: _searchQuery,
        transportType: _selectedTransportType,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        _routes = response.data!;
        // If not actively searching origin-dest, keep searchResults in sync
        if (_originQuery.isEmpty && _destinationQuery.isEmpty) {
          _searchResults = _routes;
        }
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load transit routes. Please try again.';
    }

    notifyListeners();
  }

  Future<void> _loadAllStops() async {
    try {
      final response = await _routeService.getAllStops();
      if (response.success && response.data != null) {
        _allStops = response.data!;
      }
    } catch (_) {}
  }

  /// Search routes using Origin and Destination cities/stops
  Future<void> searchByOriginDestination({
    String? origin,
    String? destination,
    String? transportType,
  }) async {
    if (origin != null) _originQuery = origin;
    if (destination != null) _destinationQuery = destination;
    if (transportType != null) _selectedTransportType = transportType;

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_originQuery.trim().isEmpty && _destinationQuery.trim().isEmpty) {
        // Fall back to standard route search
        final response = await _routeService.getRoutes(
          searchQuery: _searchQuery,
          transportType: _selectedTransportType,
        );
        _searchResults = response.data ?? [];
      } else {
        final response = await _routeService.searchRoutesByOriginDestination(
          origin: _originQuery,
          destination: _destinationQuery,
          transportType: _selectedTransportType,
        );
        _searchResults = response.data ?? [];
      }
      _isSearching = false;
    } catch (e) {
      _isSearching = false;
      _errorMessage = 'Error finding routes. Please try again.';
    }

    notifyListeners();
  }

  /// Swap origin and destination
  void swapOriginDestination() {
    final temp = _originQuery;
    _originQuery = _destinationQuery;
    _destinationQuery = temp;
    searchByOriginDestination();
  }

  /// Select a route to view its full details and ordered stops
  Future<void> selectRoute(int routeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _routeService.getRouteById(routeId);
      _isLoading = false;

      if (response.success && response.data != null) {
        _selectedRoute = response.data;
        // Also fetch timetables for the selected route
        await loadSchedules(routeId);
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not load route details.';
    }

    notifyListeners();
  }

  /// Load timetables for a route with optional direction and day filters
  Future<void> loadSchedules(int routeId, {String? direction, String? day}) async {
    if (direction != null) _selectedScheduleDirection = direction;
    if (day != null) _selectedScheduleDay = day;

    _isSchedulesLoading = true;
    notifyListeners();

    try {
      final response = await _routeService.getRouteSchedules(
        routeId,
        direction: _selectedScheduleDirection,
        dayOfWeek: _selectedScheduleDay,
      );

      _isSchedulesLoading = false;
      if (response.success && response.data != null) {
        _schedules = response.data!;
      }
    } catch (_) {
      _isSchedulesLoading = false;
    }

    notifyListeners();
  }

  void setScheduleDirection(String direction) {
    if (_selectedScheduleDirection == direction) return;
    _selectedScheduleDirection = direction;
    if (_selectedRoute != null) {
      loadSchedules(_selectedRoute!.id, direction: direction);
    }
  }

  void setScheduleDay(String day) {
    if (_selectedScheduleDay == day) return;
    _selectedScheduleDay = day;
    if (_selectedRoute != null) {
      loadSchedules(_selectedRoute!.id, day: day);
    }
  }

  void setTransportTypeFilter(String type) {
    if (_selectedTransportType == type) return;
    _selectedTransportType = type;
    if (_originQuery.isNotEmpty || _destinationQuery.isNotEmpty) {
      searchByOriginDestination(transportType: type);
    } else {
      loadRoutes();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRoutes();
  }

  void setOrigin(String origin) {
    _originQuery = origin;
  }

  void setDestination(String destination) {
    _destinationQuery = destination;
  }

  void clearSearch() {
    _searchQuery = '';
    _originQuery = '';
    _destinationQuery = '';
    _selectedTransportType = 'all';
    _searchResults = _routes;
    loadRoutes();
  }

  bool isFavorite(int routeId) {
    return _storage.isFavoriteRoute(routeId);
  }

  void toggleFavorite(int routeId) {
    _storage.toggleFavoriteRoute(routeId);
    notifyListeners();
  }
}
