import 'dart:math';

enum LocationPermissionState {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class CommuterLocation {
  final double latitude;
  final double longitude;
  final String label;
  final bool isManual;

  const CommuterLocation({
    required this.latitude,
    required this.longitude,
    this.label = 'Colombo Fort',
    this.isManual = false,
  });

  // Default Colombo Central Business District
  static const CommuterLocation defaultColombo = CommuterLocation(
    latitude: 6.9355,
    longitude: 79.8530,
    label: 'Colombo Fort (Default)',
    isManual: false,
  );
}

/// TravelPulse LK — GPS Location & Geolocation Service (Thimaya)
/// Manages device GPS permissions, manual location selection,
/// and fallback coordinates for Colombo transit navigation.
class LocationService {
  LocationPermissionState _permissionState = LocationPermissionState.granted;
  CommuterLocation _currentLocation = CommuterLocation.defaultColombo;

  LocationPermissionState get permissionState => _permissionState;
  CommuterLocation get currentLocation => _currentLocation;
  bool get hasLocationPermission => _permissionState == LocationPermissionState.granted;

  /// Request device location permissions
  Future<LocationPermissionState> requestPermission() async {
    // In production Flutter with Geolocator/Location package:
    // PermissionStatus status = await Geolocator.requestPermission();
    _permissionState = LocationPermissionState.granted;
    return _permissionState;
  }

  /// Deny permission (for testing fallback manual flow)
  void simulatePermissionDenied({bool permanently = false}) {
    _permissionState = permanently
        ? LocationPermissionState.permanentlyDenied
        : LocationPermissionState.denied;
  }

  /// Set current location manually (fallback or user selection)
  void setManualLocation({
    required double latitude,
    required double longitude,
    String label = 'Selected Location',
  }) {
    _currentLocation = CommuterLocation(
      latitude: latitude,
      longitude: longitude,
      label: label,
      isManual: true,
    );
  }

  /// Reset to GPS location
  void resetToGps({
    double latitude = 6.9355,
    double longitude = 79.8530,
    String label = 'Current GPS Location',
  }) {
    _permissionState = LocationPermissionState.granted;
    _currentLocation = CommuterLocation(
      latitude: latitude,
      longitude: longitude,
      label: label,
      isManual: false,
    );
  }

  /// Calculates straight-line distance in kilometers using the Haversine formula
  double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * pi / 180.0;
}

