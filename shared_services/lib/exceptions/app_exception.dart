/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  /// Human-readable error message
  String get message;

  /// Error code for programmatic handling
  String get code;

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}
