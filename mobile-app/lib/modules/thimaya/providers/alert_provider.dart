import 'package:flutter/material.dart';
import '../models/travel_alert_model.dart';
import '../models/alert_subscription_model.dart';
import '../services/alert_service.dart';

/// TravelPulse LK — Travel Alerts & Notification Provider (Thimaya)
class AlertProvider extends ChangeNotifier {
  final AlertService _service;

  List<TravelAlertModel> _alerts = [];
  TravelAlertModel? _selectedAlert;
  AlertSubscriptionModel? _subscription;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _severityFilter = 'All';

  AlertProvider({AlertService? service}) : _service = service ?? AlertService() {
    loadAlerts();
  }

  // Getters
  List<TravelAlertModel> get alerts => List.unmodifiable(_alerts);
  TravelAlertModel? get selectedAlert => _selectedAlert;
  AlertSubscriptionModel? get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get severityFilter => _severityFilter;

  List<TravelAlertModel> get criticalAlerts =>
      _alerts.where((a) => a.isCritical && a.isActive).toList();

  bool get hasCriticalAlerts => criticalAlerts.isNotEmpty;

  /// Load travel alerts with optional severity filter
  Future<void> loadAlerts({String? severity, String? alertType, int? routeId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (severity != null) {
      _severityFilter = severity;
    }

    final response = await _service.getAlerts(
      severityFilter: _severityFilter,
      alertTypeFilter: alertType,
      routeId: routeId,
    );

    _isLoading = false;

    if (response.isSuccess && response.data != null) {
      _alerts = response.data!;
    } else {
      _errorMessage = response.message ?? 'Failed to load travel alerts.';
    }

    notifyListeners();
  }

  /// Select alert for inspection
  void selectAlert(TravelAlertModel? alert) {
    _selectedAlert = alert;
    notifyListeners();
  }

  /// Load commuter notification preferences
  Future<void> loadSubscriptions(int userId, {String? token}) async {
    final response = await _service.getSubscriptions(userId, token: token);
    if (response.isSuccess && response.data != null) {
      _subscription = response.data;
      notifyListeners();
    }
  }

  /// Update notification preferences
  Future<bool> updatePreferences(AlertSubscriptionModel updated, {String? token}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.updateSubscription(updated, token: token);
    _isSaving = false;

    if (response.isSuccess && response.data != null) {
      _subscription = response.data;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Failed to update preferences.';
      notifyListeners();
      return false;
    }
  }

  /// Register FCM device token
  Future<void> registerFcmToken(int userId, String token) async {
    await _service.registerDeviceToken(userId, token);
  }

  void setSeverityFilter(String severity) {
    if (_severityFilter == severity) return;
    _severityFilter = severity;
    loadAlerts(severity: severity);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

