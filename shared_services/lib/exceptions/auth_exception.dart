import 'app_exception.dart';

/// Exception for authentication and authorization errors
class AuthException extends AppException {
  @override
  final String message;

  @override
  final String code;

  AuthException(this.message, {this.code = 'AUTH_ERROR'});

  /// Factory for invalid credentials
  factory AuthException.invalidCredentials() => AuthException(
    'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );

  /// Factory for expired token
  factory AuthException.tokenExpired() => AuthException(
    'Session expired. Please log in again.',
    code: 'TOKEN_EXPIRED',
  );

  /// Factory for missing token
  factory AuthException.unauthorized() => AuthException(
    'You must be logged in to access this resource',
    code: 'UNAUTHORIZED',
  );

  /// Factory for insufficient permissions
  factory AuthException.forbidden() => AuthException(
    'You do not have permission to access this resource',
    code: 'FORBIDDEN',
  );

  /// Factory for registration errors
  factory AuthException.registrationFailed(String reason) => AuthException(
    'Registration failed: $reason',
    code: 'REGISTRATION_FAILED',
  );
}
