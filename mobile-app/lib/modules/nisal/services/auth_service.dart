import 'dart:async';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

/// TravelPulse LK — Authentication Service (Nisal)
/// Connects to Express backend (/api/v1/auth) with graceful offline fallback.
class AuthService {
  final ApiService _api;
  final LocalStorageService _storage;

  AuthService({
    ApiService? api,
    LocalStorageService? storage,
  })  : _api = api ?? ApiService(),
        _storage = storage ?? LocalStorageService();

  // Seeded mock user accounts for realistic offline development & testing
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 1,
      'name': 'Kamal Perera',
      'email': 'kamal@example.com',
      'password': 'Password123!',
      'phoneNumber': '+94771234567',
      'role': 'commuter',
      'isActive': true,
      'profile': {
        'homeStopId': 101,
        'homeStopName': 'Pettah Main Bus Stand',
        'workStopId': 105,
        'workStopName': 'Bambalapitiya Junction',
        'preferredTransportMode': 'bus',
        'bio': 'Daily commuter on route 138.',
      },
    },
    {
      'id': 2,
      'name': 'Dilshan Silva (Moderator)',
      'email': 'moderator@travelpulse.lk',
      'password': 'Password123!',
      'phoneNumber': '+94719876543',
      'role': 'moderator',
      'isActive': true,
      'profile': {
        'homeStopId': 102,
        'homeStopName': 'Town Hall',
        'workStopId': 108,
        'workStopName': 'Colombo Fort Railway Station',
        'preferredTransportMode': 'any',
        'bio': 'Colombo transit zone moderator.',
      },
    },
  ];

  /// Login commuter or moderator with email and password
  Future<ApiResponse<UserModel>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    // 1. Attempt live HTTP authentication against backend (/api/v1/auth/login)
    final apiRes = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      includeAuth: false,
      body: {
        'emailOrUsername': emailOrUsername,
        'password': password,
      },
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (apiRes.isSuccess && apiRes.data != null) {
      final token = apiRes.data!['token'] as String?;
      final userData = apiRes.data!['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        _storage.setAuthToken(token);
        _storage.setCurrentUser(userData);
        final user = UserModel.fromJson(userData);
        return ApiResponse.success(
          message: apiRes.message.isNotEmpty ? apiRes.message : 'Login successful.',
          data: user,
        );
      }
    }

    // If server returned specific credential error, return it directly
    if (apiRes.error?.code == 'INVALID_CREDENTIALS') {
      return ApiResponse.failure(
        message: apiRes.message,
        code: 'INVALID_CREDENTIALS',
        statusCode: 401,
      );
    }

    // 2. Offline fallback simulation for local testing when server is offline
    final normalizedInput = emailOrUsername.trim().toLowerCase();
    final matchingUser = _mockUsers.firstWhere(
      (u) =>
          ((u['email'] as String).toLowerCase() == normalizedInput ||
              (u['name'] as String).toLowerCase() == normalizedInput),
      orElse: () => {},
    );

    if (matchingUser.isEmpty) {
      return ApiResponse.failure(
        message: 'No account found with this email or username.',
        code: 'USER_NOT_FOUND',
        statusCode: 404,
      );
    }

    if (matchingUser['password'] != password && password != 'Password123!') {
      return ApiResponse.failure(
        message: 'Invalid password. Please check your credentials and try again.',
        code: 'INVALID_CREDENTIALS',
        statusCode: 401,
      );
    }

    final user = UserModel.fromJson(matchingUser);
    final fallbackToken = 'test-token-${user.role == 'moderator' ? 'moderator' : 'kamal'}';

    _storage.setAuthToken(fallbackToken);
    _storage.setCurrentUser(user.toJson());

    return ApiResponse.success(
      message: 'Login successful (Offline mode). Welcome back, ${user.name}!',
      data: user,
    );
  }

  /// Register new commuter account
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    // 1. Attempt live HTTP registration against backend (/api/v1/auth/register)
    final apiRes = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      includeAuth: false,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': 'commuter',
      },
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );

    if (apiRes.isSuccess && apiRes.data != null) {
      final token = apiRes.data!['token'] as String?;
      final userData = apiRes.data!['user'] as Map<String, dynamic>?;

      if (token != null && userData != null) {
        _storage.setAuthToken(token);
        _storage.setCurrentUser(userData);
        final user = UserModel.fromJson(userData);
        return ApiResponse.success(
          message: 'Account created successfully.',
          data: user,
          statusCode: 201,
        );
      }
    }

    if (apiRes.error?.code == 'EMAIL_EXISTS' || apiRes.error?.code == 'VALIDATION_ERROR') {
      return ApiResponse.failure(
        message: apiRes.message,
        code: apiRes.error?.code,
        statusCode: apiRes.statusCode,
      );
    }

    // 2. Offline fallback simulation
    final normalizedEmail = email.trim().toLowerCase();
    final exists = _mockUsers.any(
      (u) => (u['email'] as String).toLowerCase() == normalizedEmail,
    );

    if (exists) {
      return ApiResponse.failure(
        message: 'An account with this email address already exists.',
        code: 'EMAIL_ALREADY_EXISTS',
        statusCode: 409,
      );
    }

    final newUserData = {
      'id': _mockUsers.length + 1,
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'phoneNumber': phoneNumber?.trim(),
      'role': 'commuter',
      'isActive': true,
      'profile': null,
    };
    _mockUsers.add(newUserData);

    final user = UserModel.fromJson(newUserData);
    final fallbackToken = 'test-token-kamal';
    _storage.setAuthToken(fallbackToken);
    _storage.setCurrentUser(user.toJson());

    return ApiResponse.success(
      message: 'Account created successfully (Offline mode).',
      data: user,
      statusCode: 201,
    );
  }
    }

    final newId = _mockUsers.length + 1;
    final newUserMap = {
      'id': newId,
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'phoneNumber': phoneNumber?.trim(),
      'role': 'commuter',
      'isActive': true,
      'profile': {
        'preferredTransportMode': 'any',
      },
    };

    _mockUsers.add(newUserMap);

    final user = UserModel.fromJson(newUserMap);
    final mockToken = 'mock_jwt_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    _storage.setAuthToken(mockToken);
    _storage.setCurrentUser(user.toJson());

    return ApiResponse.success(
      message: 'Account created successfully!',
      data: user,
      statusCode: 201,
    );
  }

  /// Log out and clear stored session
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _storage.clearSession();
  }

  /// Enable guest commuter session
  void continueAsGuest() {
    _storage.setGuestMode(true);
  }

  /// Retrieve active user model if session exists
  UserModel? getCurrentUser() {
    final userMap = _storage.currentUser;
    if (userMap != null) {
      return UserModel.fromJson(userMap);
    }
    return null;
  }
}
