import 'dart:async';
import '../../../core/models/api_response.dart';
import '../../../core/services/api_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

/// TravelPulse LK — Authentication Service (Nisal)
/// Connects securely to Express backend (/api/v1/auth).
/// In accordance with Stage 8.2 security requirements, all authentication
/// is strictly validated by the server. Insecure offline fallback credentials
/// and mock tokens have been removed.
class AuthService {
  final ApiService _api;
  final LocalStorageService _storage;

  AuthService({
    ApiService? api,
    LocalStorageService? storage,
  })  : _api = api ?? ApiService(),
        _storage = storage ?? LocalStorageService();

  /// Login commuter or moderator with email and password
  Future<ApiResponse<UserModel>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final apiRes = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      includeAuth: false,
      body: {
        'emailOrUsername': emailOrUsername.trim(),
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

    // Insecure offline authentication removed: do NOT create fake sessions or mock tokens
    if (apiRes.error?.code == 'INVALID_CREDENTIALS') {
      return ApiResponse.failure(
        message: 'Invalid email or password. Please verify your credentials and try again.',
        code: 'INVALID_CREDENTIALS',
        statusCode: 401,
      );
    }

    if (apiRes.error?.code == 'NETWORK_UNREACHABLE' || apiRes.error?.code == 'TIMEOUT') {
      return ApiResponse.failure(
        message: 'Unable to connect to TravelPulse LK server. Please check your network connection.',
        code: apiRes.error?.code ?? 'NETWORK_ERROR',
        statusCode: 503,
      );
    }

    return ApiResponse.failure(
      message: apiRes.message.isNotEmpty ? apiRes.message : 'Authentication failed. Please try again.',
      code: apiRes.error?.code ?? 'AUTH_ERROR',
      statusCode: apiRes.statusCode,
    );
  }

  /// Register new commuter account
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final apiRes = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      includeAuth: false,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'phoneNumber': phoneNumber?.trim(),
        'role': 'commuter', // Server enforces commuter role strictly
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

    if (apiRes.error?.code == 'EMAIL_EXISTS' || apiRes.statusCode == 409) {
      return ApiResponse.failure(
        message: apiRes.message.isNotEmpty ? apiRes.message : 'An account with this email address already exists.',
        code: 'EMAIL_EXISTS',
        statusCode: 409,
      );
    }

    if (apiRes.error?.code == 'NETWORK_UNREACHABLE' || apiRes.error?.code == 'TIMEOUT') {
      return ApiResponse.failure(
        message: 'Unable to connect to TravelPulse LK server. Please check your network connection.',
        code: apiRes.error?.code ?? 'NETWORK_ERROR',
        statusCode: 503,
      );
    }

    return ApiResponse.failure(
      message: apiRes.message.isNotEmpty ? apiRes.message : 'Registration failed. Please try again.',
      code: apiRes.error?.code ?? 'REGISTRATION_ERROR',
      statusCode: apiRes.statusCode,
    );
  }

  /// Log out and clear stored session securely
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 50));
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
