import 'package:flutter/material.dart';
import '../models/journey_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../services/journey_service.dart';

/// TravelPulse LK — Commuter Journey State Provider (Nisal)
/// Manages user journeys, active transit trip tracking, and travel history.
class JourneyProvider extends ChangeNotifier {
  final JourneyService _journeyService = JourneyService();

  List<JourneyModel> _journeys = [];
  JourneyModel? _activeJourney;
  bool _isLoading = false;
  String? _errorMessage;

  List<JourneyModel> get journeys => _journeys;
  JourneyModel? get activeJourney => _activeJourney;
  bool get hasActiveJourney => _activeJourney != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  JourneyProvider() {
    loadJourneys();
  }

  Future<void> loadJourneys({int? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _journeyService.getJourneys(userId: userId);
      final activeResponse = await _journeyService.getActiveJourney(userId: userId);

      _isLoading = false;

      if (response.success && response.data != null) {
        _journeys = response.data!;
      } else {
        _errorMessage = response.message;
      }

      if (activeResponse.success) {
        _activeJourney = activeResponse.data;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load journey history.';
    }

    notifyListeners();
  }

  Future<bool> startJourney({
    required int userId,
    required RouteModel route,
    required RouteStopSequenceModel originStop,
    required RouteStopSequenceModel destinationStop,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _journeyService.createJourney(
        userId: userId,
        route: route,
        originStop: originStop,
        destinationStop: destinationStop,
        startImmediately: true,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        _activeJourney = response.data;
        // Reload list to update history
        await loadJourneys(userId: userId);
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not start journey. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeJourney(int journeyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _journeyService.updateJourneyStatus(journeyId, 'completed');
      _isLoading = false;

      if (response.success) {
        if (_activeJourney?.id == journeyId) {
          _activeJourney = null;
        }
        await loadJourneys();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not complete journey.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelJourney(int journeyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _journeyService.updateJourneyStatus(journeyId, 'cancelled');
      _isLoading = false;

      if (response.success) {
        if (_activeJourney?.id == journeyId) {
          _activeJourney = null;
        }
        await loadJourneys();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Could not cancel journey.';
      notifyListeners();
      return false;
    }
  }
}

