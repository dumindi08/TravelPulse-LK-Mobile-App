import 'package:flutter/foundation.dart';

/// TravelPulse LK — Global Application Constants
class AppConstants {
  AppConstants._();

  static const String appName = 'TravelPulse LK';
  static const String appTagline = 'Smart Community Transit & Road Conditions';
  static const String appVersion = '1.0.0';

  // API Networking
  // Android emulator connects to host loopback via 10.0.2.2
  // Web, iOS simulator, and desktop platforms connect via localhost
  static const String androidApiBaseUrl = 'http://10.0.2.2:5000/api/v1';
  static const String localApiBaseUrl = 'http://localhost:5000/api/v1';

  static String get defaultApiBaseUrl {
    if (kIsWeb) {
      return localApiBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidApiBaseUrl;
    }
    return localApiBaseUrl;
  }

  static String get apiBaseUrl => defaultApiBaseUrl;
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Sri Lanka Geographic Defaults (Colombo Fort)
  static const double colomboLatitude = 6.9344;
  static const double colomboLongitude = 79.8540;
  static const String defaultCity = 'Colombo';

  // Master Transit Operators
  static const String operatorSltb = 'SLTB';
  static const String operatorPrivate = 'Private';
  static const String operatorRailways = 'Sri Lanka Railways';

  // Disruption Reasons (Captures specific reason, not an invented severity field)
  static const List<String> disruptionReasons = [
    'Vehicle Breakdown',
    'Accident Obstruction',
    'Strike / Union Action',
    'Track Maintenance / Signal Failure',
    'Road Inundation / Flooding',
    'Severe Traffic Congestion',
    'Route Diverted',
    'Other Operational Delay',
  ];

  // Report Categories
  static const List<String> reportCategories = [
    'Crowd Report',
    'Road Condition',
    'Transport / Route Tracking',
    'Service Disruption',
    'Accident / Incident',
    'Other',
  ];

  // Crowd Density Levels
  static const String crowdEmpty = 'empty';
  static const String crowdModerate = 'moderate';
  static const String crowdCrowded = 'crowded';
  static const String crowdPacked = 'very_crowded';
}

