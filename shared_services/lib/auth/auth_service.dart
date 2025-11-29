import 'dart:async';
import 'package:logging/logging.dart';
import '../api/base_api_client.dart';
import '../api/api_config.dart';
import '../exceptions/auth_exception.dart';
import '../exceptions/api_exception.dart';
import '../models/user.dart';
import '../storage/token_storage.dart';
import '../monitoring/metrics.dart';
import '../monitoring/metrics_collector.dart';

/// Authentication service for managing user sessions and tokens
class AuthService {
  final BaseApiClient _client;
  final TokenStorage _storage;
  final Logger _logger;
  final MetricsCollector _metrics = MetricsCollector();

  User? _currentUser;

  AuthService({
    required ApiConfig config,
    TokenStorage? storage,
    BaseApiClient? client,
  })  : _storage = storage ?? TokenStorage(),
        _client = client ?? BaseApiClient(config: config),
        _logger = Logger('AuthService') {
    // Set token provider for BaseApiClient
    _client.tokenProvider = () => _storage.getAccessToken();
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _logger.info('Registering user: $email');

      final response = await _client.post<Map<String, dynamic>>(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          if (fullName != null) 'full_name': fullName,
        },
        fromJson: (json) => json,
      );

      // Parse auth response
      final authResponse = AuthResponse.fromJson(response);

      // Save tokens
      await _storage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Save user info
      await _storage.saveUserInfo(
        userId: authResponse.user.id,
        email: authResponse.user.email,
      );

      _currentUser = authResponse.user;
      _logger.info('Registration successful for: $email');

      _metrics.record(AuthEventMetric(
        eventType: 'register',
        success: true,
        userId: authResponse.user.id,
      ));

      return authResponse;
    } on ApiException catch (e) {
      _metrics.record(AuthEventMetric(
        eventType: 'register',
        success: false,
        errorReason: e.message,
      ));
      if (e.statusCode == 400) {
        // Extract specific error from response
        final detail = e.responseData?['detail'] ?? e.message;
        throw AuthException.registrationFailed(detail);
      }
      rethrow;
    } catch (e) {
      _metrics.record(AuthEventMetric(
        eventType: 'register',
        success: false,
        errorReason: e.toString(),
      ));
      rethrow;
    }
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Logging in user: $email');

      final response = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => json,
      );

      // Parse auth response
      final authResponse = AuthResponse.fromJson(response);

      // Save tokens
      await _storage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      // Save user info
      await _storage.saveUserInfo(
        userId: authResponse.user.id,
        email: authResponse.user.email,
      );

      _currentUser = authResponse.user;
      _logger.info('Login successful for: $email');

      _metrics.record(AuthEventMetric(
        eventType: 'login',
        success: true,
        userId: authResponse.user.id,
      ));

      return authResponse;
    } on ApiException catch (e) {
      _metrics.record(AuthEventMetric(
        eventType: 'login',
        success: false,
        errorReason: e.message,
      ));
      if (e.statusCode == 401 || e.statusCode == 400) {
        throw AuthException.invalidCredentials();
      }
      rethrow;
    } catch (e) {
      _metrics.record(AuthEventMetric(
        eventType: 'login',
        success: false,
        errorReason: e.toString(),
      ));
      rethrow;
    }
  }

  /// Get current user information
  Future<User> getCurrentUser() async {
    // Return cached user if available
    if (_currentUser != null) {
      return _currentUser!;
    }

    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException.unauthorized();
    }

    try {
      _logger.info('Fetching current user info');

      final response = await _client.get<Map<String, dynamic>>(
        '/auth/me',
        fromJson: (json) => json,
      );

      final user = User.fromJson(response);

      // Update cached info
      await _storage.saveUserInfo(
        userId: user.id,
        email: user.email,
      );

      _currentUser = user;
      return user;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // Try to refresh token
        try {
          await refreshAccessToken();
          return getCurrentUser(); // Retry
        } catch (_) {
          throw AuthException.tokenExpired();
        }
      }
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw AuthException.tokenExpired();
    }

    try {
      _logger.info('Refreshing access token');

      // Temporarily disable token provider to avoid using expired token
      final originalProvider = _client.tokenProvider;
      _client.tokenProvider = null;

      final response = await _client.post<Map<String, dynamic>>(
        '/auth/refresh',
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
        fromJson: (json) => json,
      );

      // Restore token provider
      _client.tokenProvider = originalProvider;

      // Save new tokens
      await _storage.saveTokens(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
      );

      _logger.info('Token refresh successful');

      _metrics.record(AuthEventMetric(
        eventType: 'refresh',
        success: true,
      ));
    } on ApiException catch (e) {
      _metrics.record(AuthEventMetric(
        eventType: 'refresh',
        success: false,
        errorReason: e.message,
      ));
      if (e.statusCode == 401) {
        // Refresh failed, clear tokens
        await logout();
        throw AuthException.tokenExpired();
      }
      rethrow;
    } catch (e) {
      _metrics.record(AuthEventMetric(
        eventType: 'refresh',
        success: false,
        errorReason: e.toString(),
      ));
      await logout();
      rethrow;
    }
  }

  /// Logout and clear tokens
  Future<void> logout() async {
    final userId = _currentUser?.id ?? await _storage.getUserId();
    _logger.info('Logging out user');
    await _storage.clear();
    _currentUser = null;

    _metrics.record(AuthEventMetric(
      eventType: 'logout',
      success: true,
      userId: userId,
    ));
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storage.hasTokens();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.getAccessToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.getRefreshToken();
  }

  /// Get cached user ID
  Future<String?> getUserId() async {
    return await _storage.getUserId();
  }

  /// Get cached email
  Future<String?> getEmail() async {
    return await _storage.getEmail();
  }

  /// Dispose resources
  void dispose() {
    _client.dispose();
  }
}
