import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_exception.dart';

/// Exception for API-related errors (4xx, 5xx responses)
class ApiException extends AppException {
  @override
  final String message;

  @override
  final String code;

  /// HTTP status code
  final int? statusCode;

  /// Response body for debugging
  final Map<String, dynamic>? responseData;

  ApiException({
    required this.message,
    required this.code,
    this.statusCode,
    this.responseData,
  });

  /// Factory to create from HTTP response
  factory ApiException.fromResponse(http.Response response) {
    Map<String, dynamic>? data;
    String message = 'API Error';

    try {
      data = json.decode(response.body) as Map<String, dynamic>;
      message = data['detail'] ?? data['message'] ?? data['error'] ?? message;
    } catch (e) {
      // If response body is not JSON, use status text
      message = 'HTTP ${response.statusCode}: ${response.reasonPhrase ?? "Unknown error"}';
    }

    return ApiException(
      message: message,
      code: 'API_${response.statusCode}',
      statusCode: response.statusCode,
      responseData: data,
    );
  }

  /// Factory for 400 Bad Request
  factory ApiException.badRequest([String? message]) => ApiException(
    message: message ?? 'Invalid request parameters',
    code: 'BAD_REQUEST',
    statusCode: 400,
  );

  /// Factory for 404 Not Found
  factory ApiException.notFound([String? message]) => ApiException(
    message: message ?? 'Resource not found',
    code: 'NOT_FOUND',
    statusCode: 404,
  );

  /// Factory for 500 Internal Server Error
  factory ApiException.serverError([String? message]) => ApiException(
    message: message ?? 'Server error occurred',
    code: 'SERVER_ERROR',
    statusCode: 500,
  );

  /// Check if this is a client error (4xx)
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if this is a server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;
}
