/// TravelPulse LK — Standard API Response Envelope
/// Matches the global API specification defined in docs/api-contracts.md
class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final ApiError? error;

  bool get isSuccess => success;
  bool get isFailure => !success;
  String? get code => error?.code;

  ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      meta: json['meta'] as Map<String, dynamic>?,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  factory ApiResponse.success({
    required String message,
    T? data,
    int statusCode = 200,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      statusCode: statusCode,
      message: message,
      data: data,
      meta: meta,
    );
  }

  factory ApiResponse.failure({
    required String message,
    String? code,
    int statusCode = 400,
    List<Map<String, dynamic>>? details,
  }) {
    return ApiResponse<T>(
      success: false,
      statusCode: statusCode,
      message: message,
      error: ApiError(
        code: code ?? 'ERROR',
        details: details,
      ),
    );
  }
}

class ApiError {
  final String code;
  final List<Map<String, dynamic>>? details;

  ApiError({
    required this.code,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

