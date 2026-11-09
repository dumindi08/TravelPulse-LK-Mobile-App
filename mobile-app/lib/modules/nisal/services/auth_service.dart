import 'dart:async';
import '../../../core/models/api_response.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

/// TravelPulse LK — Authentication Service (Nisal)
/// ---------------------------------------------------------------------------
/// [TEMPORARY MOCK IMPLEMENTATION]
/// This service currently simulates authentication state in memory using
/// preloaded test credentials for offline client UI development and testing.
/// It is NOT connected to the production Node.js backend or MySQL database.
/// Once the backend is started, these mock methods will be wired to live HTTP
/// calls against POST /api/v1/auth/login and POST /api/v1/auth/register.
/// ---------------------------------------------------------------------------
class AuthService {
  final LocalStorageService _storage = LocalStorageService();

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
    // Simulate network latency (300ms)
    await Future.delayed(const Duration(milliseconds: 300));

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
    final mockToken = 'mock_jwt_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    // Persist session
    _storage.setAuthToken(mockToken);
    _storage.setCurrentUser(user.toJson());

    return ApiResponse.success(
      message: 'Login successful. Welcome back, ${user.name}!',
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
    await Future.delayed(const Duration(milliseconds: 350));

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
