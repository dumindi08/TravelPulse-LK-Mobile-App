import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/api_response.dart';
import '../storage/local_storage_service.dart';

/// TravelPulse LK — Central REST API Service
/// Handles HTTP communications with Express backend (/api/v1).
/// Injects Bearer tokens, serializes JSON, and parses standard ApiResponse envelopes.
class ApiService {
  final http.Client _client;
  final String baseUrl;
  final LocalStorageService _storage;

  ApiService({
    http.Client? client,
    String? baseUrl,
    LocalStorageService? storage,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.defaultApiBaseUrl,
        _storage = storage ?? LocalStorageService();

  Map<String, String> _buildHeaders({bool includeAuth = true, Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _storage.authToken != null && _storage.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${_storage.authToken}';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// Perform GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJsonT,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client
          .get(uri, headers: _buildHeaders(includeAuth: includeAuth))
          .timeout(AppConstants.connectTimeout);

      return _parseResponse<T>(response, fromJsonT);
    } on SocketException catch (_) {
      return ApiResponse.failure(
        message: 'Unable to reach TravelPulse LK server. Running in offline mode.',
        code: 'NETWORK_UNREACHABLE',
      );
    } on TimeoutException catch (_) {
      return ApiResponse.failure(
        message: 'Connection timed out. Please check your network connectivity.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return ApiResponse.failure(
        message: 'An unexpected network error occurred: $e',
        code: 'CLIENT_ERROR',
      );
    }
  }

  /// Perform POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic json)? fromJsonT,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectTimeout);

      return _parseResponse<T>(response, fromJsonT);
    } on SocketException catch (_) {
      return ApiResponse.failure(
        message: 'Unable to reach TravelPulse LK server. Running in offline mode.',
        code: 'NETWORK_UNREACHABLE',
      );
    } on TimeoutException catch (_) {
      return ApiResponse.failure(
        message: 'Connection timed out. Please check your network connectivity.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return ApiResponse.failure(
        message: 'An unexpected network error occurred: $e',
        code: 'CLIENT_ERROR',
      );
    }
  }

  /// Perform PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    T Function(dynamic json)? fromJsonT,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .patch(
            uri,
            headers: _buildHeaders(includeAuth: includeAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectTimeout);

      return _parseResponse<T>(response, fromJsonT);
    } on SocketException catch (_) {
      return ApiResponse.failure(
        message: 'Unable to reach TravelPulse LK server. Running in offline mode.',
        code: 'NETWORK_UNREACHABLE',
      );
    } on TimeoutException catch (_) {
      return ApiResponse.failure(
        message: 'Connection timed out. Please check your network connectivity.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return ApiResponse.failure(
        message: 'An unexpected network error occurred: $e',
        code: 'CLIENT_ERROR',
      );
    }
  }

  /// Perform DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic json)? fromJsonT,
    bool includeAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .delete(uri, headers: _buildHeaders(includeAuth: includeAuth))
          .timeout(AppConstants.connectTimeout);

      return _parseResponse<T>(response, fromJsonT);
    } on SocketException catch (_) {
      return ApiResponse.failure(
        message: 'Unable to reach TravelPulse LK server. Running in offline mode.',
        code: 'NETWORK_UNREACHABLE',
      );
    } on TimeoutException catch (_) {
      return ApiResponse.failure(
        message: 'Connection timed out. Please check your network connectivity.',
        code: 'TIMEOUT',
      );
    } catch (e) {
      return ApiResponse.failure(
        message: 'An unexpected network error occurred: $e',
        code: 'CLIENT_ERROR',
      );
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$baseUrl$cleanEndpoint';
    final parsed = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return parsed.replace(queryParameters: queryParams);
    }
    return parsed;
  }

  ApiResponse<T> _parseResponse<T>(http.Response response, T Function(dynamic json)? fromJsonT) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(decoded, fromJsonT);
      }
      return ApiResponse<T>.success(
        message: 'Success',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.success(
          message: 'Operation succeeded',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse<T>.failure(
        message: 'Server returned HTTP ${response.statusCode}',
        statusCode: response.statusCode,
        code: 'HTTP_${response.statusCode}',
      );
    }
  }
}

