import 'package:flutter/material.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// TravelPulse LK — Authentication & User State Provider (Nisal)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocalStorageService _storage = LocalStorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGuest = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _storage.isAuthenticated;
  bool get isGuest => _isGuest;
  bool get isModerator => _currentUser?.isModerator ?? false;
  int? get currentUserId => _currentUser?.id;
  String? get token => _storage.authToken;
  String? get authToken => _storage.authToken;

  AuthProvider() {
    _initializeSession();
  }

  void _initializeSession() {
    _currentUser = _authService.getCurrentUser();
    _isGuest = _storage.isGuest;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({
    required String emailOrUsername,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isGuest = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred during login. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      _isLoading = false;

      if (response.success && response.data != null) {
        _currentUser = response.data;
        _isGuest = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred during registration. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void continueAsGuest() {
    _authService.continueAsGuest();
    _currentUser = null;
    _isGuest = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _currentUser = null;
    _isGuest = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
