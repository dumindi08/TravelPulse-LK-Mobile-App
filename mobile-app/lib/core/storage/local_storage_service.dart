import 'dart:convert';

/// TravelPulse LK — Local State & Session Storage Service
/// Manages user authentication tokens, active commuter profile, and guest mode.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  String? _authToken;
  Map<String, dynamic>? _currentUser;
  bool _isGuest = false;
  final Set<int> _favoriteRouteIds = {};
  final Set<int> _subscribedRouteIds = {};

  // Auth Token
  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;
  bool get isGuest => _isGuest;

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null) {
      _isGuest = false;
    }
  }

  void setGuestMode(bool guest) {
    _isGuest = guest;
    if (guest) {
      _authToken = null;
      _currentUser = null;
    }
  }

  // Current User
  Map<String, dynamic>? get currentUser => _currentUser;
  int? get currentUserId => _currentUser != null ? _currentUser!['id'] as int? : null;
  String? get userRole => _currentUser != null ? _currentUser!['role'] as String? : null;
  bool get isModeratorOrAdmin => userRole == 'moderator' || userRole == 'admin';

  void setCurrentUser(Map<String, dynamic>? user) {
    _currentUser = user;
    if (user != null) {
      _isGuest = false;
    }
  }

  // Favorite Routes
  Set<int> get favoriteRouteIds => Set.unmodifiable(_favoriteRouteIds);

  void toggleFavoriteRoute(int routeId) {
    if (_favoriteRouteIds.contains(routeId)) {
      _favoriteRouteIds.remove(routeId);
    } else {
      _favoriteRouteIds.add(routeId);
    }
  }

  bool isFavoriteRoute(int routeId) => _favoriteRouteIds.contains(routeId);

  // Subscribed Routes for Alerts
  Set<int> get subscribedRouteIds => Set.unmodifiable(_subscribedRouteIds);

  void toggleRouteSubscription(int routeId) {
    if (_subscribedRouteIds.contains(routeId)) {
      _subscribedRouteIds.remove(routeId);
    } else {
      _subscribedRouteIds.add(routeId);
    }
  }

  bool isRouteSubscribed(int routeId) => _subscribedRouteIds.contains(routeId);

  // Clear Session (Logout)
  void clearSession() {
    _authToken = null;
    _currentUser = null;
    _isGuest = false;
    _favoriteRouteIds.clear();
    _subscribedRouteIds.clear();
  }
}

