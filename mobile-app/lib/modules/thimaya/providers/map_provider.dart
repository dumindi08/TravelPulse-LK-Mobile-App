import 'package:flutter/material.dart';
import '../models/road_incident_model.dart';
import '../services/alert_service.dart';
import '../services/location_service.dart';

/// TravelPulse LK — Interactive Map & Road Hazard Provider (Thimaya)
class MapProvider extends ChangeNotifier {
  final AlertService _alertService;
  final LocationService _locationService;

  List<RoadIncidentModel> _incidents = [];
  RoadIncidentModel? _selectedIncident;
  String _typeFilter = 'All';
  String _severityFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _showSafetyBanner = true;
  bool _showCrowdOverlay = true;
  bool _showDisruptionsOverlay = true;
  String? _errorMessage;

  MapProvider({
    AlertService? alertService,
    LocationService? locationService,
  })  : _alertService = alertService ?? AlertService(),
        _locationService = locationService ?? LocationService() {
    loadMapData();
  }

  // Getters
  List<RoadIncidentModel> get incidents => List.unmodifiable(_incidents);
  RoadIncidentModel? get selectedIncident => _selectedIncident;
  String get typeFilter => _typeFilter;
  String get severityFilter => _severityFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get showSafetyBanner => _showSafetyBanner;
  bool get showCrowdOverlay => _showCrowdOverlay;
  bool get showDisruptionsOverlay => _showDisruptionsOverlay;
  String? get errorMessage => _errorMessage;

  LocationService get locationService => _locationService;
  CommuterLocation get currentLocation => _locationService.currentLocation;
  LocationPermissionState get permissionState => _locationService.permissionState;
  bool get hasLocationPermission => _locationService.hasLocationPermission;

  /// Returns incidents matching current type filter, severity, and search term
  List<RoadIncidentModel> get filteredIncidents {
    return _incidents.where((i) {
      // Type filter
      if (_typeFilter != 'All' && i.incidentType.toLowerCase() != _typeFilter.toLowerCase()) {
        return false;
      }
      // Severity filter
      if (_severityFilter != 'All' && i.severity.toLowerCase() != _severityFilter.toLowerCase()) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchAddress = i.addressText.toLowerCase().contains(query);
        final matchType = i.displayName.toLowerCase().contains(query);
        if (!matchAddress && !matchType) return false;
      }
      return true;
    }).toList();
  }

  List<RoadIncidentModel> get criticalHazards =>
      _incidents.where((i) => i.isCritical && i.isActive).toList();

  bool get hasCriticalHazards => criticalHazards.isNotEmpty;

  /// Load road incidents for map visualization
  Future<void> loadMapData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _alertService.getRoadIncidents(
      incidentTypeFilter: _typeFilter != 'All' ? _typeFilter : null,
      severityFilter: _severityFilter != 'All' ? _severityFilter : null,
    );

    _isLoading = false;

    if (response.isSuccess && response.data != null) {
      _incidents = response.data!;
    } else {
      _errorMessage = response.message ?? 'Failed to load map incidents.';
    }

    notifyListeners();
  }

  void selectIncident(RoadIncidentModel? incident) {
    _selectedIncident = incident;
    notifyListeners();
  }

  void setTypeFilter(String type) {
    if (_typeFilter == type) return;
    _typeFilter = type;
    notifyListeners();
  }

  void setSeverityFilter(String severity) {
    if (_severityFilter == severity) return;
    _severityFilter = severity;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void dismissSafetyBanner() {
    _showSafetyBanner = false;
    notifyListeners();
  }

  void toggleCrowdOverlay() {
    _showCrowdOverlay = !_showCrowdOverlay;
    notifyListeners();
  }

  void toggleDisruptionsOverlay() {
    _showDisruptionsOverlay = !_showDisruptionsOverlay;
    notifyListeners();
  }

  Future<void> requestLocationPermission() async {
    await _locationService.requestPermission();
    notifyListeners();
  }

  void setManualLocation({
    required double latitude,
    required double longitude,
    String label = 'Selected Location',
  }) {
    _locationService.setManualLocation(
      latitude: latitude,
      longitude: longitude,
      label: label,
    );
    notifyListeners();
  }

  void resetToGpsLocation() {
    _locationService.resetToGps();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

