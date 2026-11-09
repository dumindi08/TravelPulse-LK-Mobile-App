import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';

/// TravelPulse LK — Route & Schedule State Provider (Nisal)
class RouteProvider extends ChangeNotifier {
  final RouteService _routeService = RouteService();
  final LocalStorageService _storage = LocalStorageService();

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTransportType = 'all'; // 'all', 'bus', 'train'
  String _searchQuery = '';

  List<RouteModel> get routes => _routes;
  RouteModel? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTransportType => _selectedTransportType;
  String get searchQuery => _searchQuery;

  RouteProvider() {
    loadRoutes();
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
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load transit routes. Please try again.';
    }

    notifyListeners();
  }

  Future<void> selectRoute(int routeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _routeService.getRouteById(routeId);
      _isLoading = false;

      if (response.success && response.data != null) {
        _selectedRoute = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not load route details.';
    }

    notifyListeners();
  }

  void setTransportTypeFilter(String type) {
    if (_selectedTransportType == type) return;
    _selectedTransportType = type;
    loadRoutes();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRoutes();
  }

  void clearSearch() {
    _searchQuery = '';
    _selectedTransportType = 'all';
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

