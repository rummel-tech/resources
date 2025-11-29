import 'app_exception.dart';

/// Exception for network-related errors (connectivity, timeout, etc.)
class NetworkException extends AppException {
  @override
  final String message;

  @override
  final String code;

  NetworkException(this.message, {this.code = 'NETWORK_ERROR'});

  /// Factory for connection errors
  factory NetworkException.connectionFailed() => NetworkException(
    'Unable to connect to server. Please check your internet connection.',
    code: 'CONNECTION_FAILED',
  );

  /// Factory for timeout errors
  factory NetworkException.timeout() => NetworkException(
    'Request timed out. Please try again.',
    code: 'TIMEOUT',
  );

  /// Factory for DNS errors
  factory NetworkException.hostLookupFailed() => NetworkException(
    'Unable to resolve server address.',
    code: 'HOST_LOOKUP_FAILED',
  );
}
