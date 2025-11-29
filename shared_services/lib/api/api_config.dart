import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuration for API endpoints and settings
class ApiConfig {
  /// Base URL for the API
  final String baseUrl;

  /// Timeout duration for API requests
  final Duration timeout;

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Environment (development, staging, production)
  final String environment;

  /// Whether to enable debug logging
  final bool enableDebugLogs;

  const ApiConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.environment = 'development',
    this.enableDebugLogs = false,
  });

  /// Create configuration from environment variables
  factory ApiConfig.fromEnvironment({String? defaultBaseUrl}) {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    const envTimeout = int.fromEnvironment('API_TIMEOUT', defaultValue: 30);
    const envRetries = int.fromEnvironment('API_MAX_RETRIES', defaultValue: 3);
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    const debugLogs = bool.fromEnvironment('DEBUG_LOGS', defaultValue: false);

    return ApiConfig(
      baseUrl: envUrl.isNotEmpty ? envUrl : (defaultBaseUrl ?? _getDefaultBaseUrl()),
      timeout: Duration(seconds: envTimeout),
      maxRetries: envRetries,
      environment: environment,
      enableDebugLogs: debugLogs,
    );
  }

  /// Get platform-specific default base URL
  static String _getDefaultBaseUrl() {
    if (kIsWeb) {
      // For web, use the same host as the app
      return '/api';
    } else {
      // For mobile, connect to localhost
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine
        return 'http://10.0.2.2:8000';
      } else {
        // iOS simulator and desktop use localhost
        return 'http://localhost:8000';
      }
    }
  }

  /// Create a copy with modified fields
  ApiConfig copyWith({
    String? baseUrl,
    Duration? timeout,
    int? maxRetries,
    String? environment,
    bool? enableDebugLogs,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      environment: environment ?? this.environment,
      enableDebugLogs: enableDebugLogs ?? this.enableDebugLogs,
    );
  }
}

/// Predefined configurations for different apps
class AppConfigs {
  /// Workout Planner API configuration
  static ApiConfig workoutPlanner({String? environment}) {
    return ApiConfig(
      baseUrl: _getBaseUrlForApp('workout', environment),
      timeout: const Duration(seconds: 30),
      maxRetries: 3,
      environment: environment ?? 'development',
    );
  }

  /// Meal Planner API configuration
  static ApiConfig mealPlanner({String? environment}) {
    return ApiConfig(
      baseUrl: _getBaseUrlForApp('meal', environment),
      timeout: const Duration(seconds: 30),
      maxRetries: 3,
      environment: environment ?? 'development',
    );
  }

  /// Home Manager API configuration
  static ApiConfig homeManager({String? environment}) {
    return ApiConfig(
      baseUrl: _getBaseUrlForApp('home', environment),
      timeout: const Duration(seconds: 30),
      maxRetries: 3,
      environment: environment ?? 'development',
    );
  }

  /// Vehicle Manager API configuration
  static ApiConfig vehicleManager({String? environment}) {
    return ApiConfig(
      baseUrl: _getBaseUrlForApp('vehicle', environment),
      timeout: const Duration(seconds: 30),
      maxRetries: 3,
      environment: environment ?? 'development',
    );
  }

  /// Auth Service API configuration (uses workout planner backend)
  static ApiConfig auth({String? environment}) {
    return workoutPlanner(environment: environment);
  }

  static String _getBaseUrlForApp(String app, String? environment) {
    final env = environment ?? 'development';

    // Production URLs (GitHub Pages + AWS)
    if (env == 'production') {
      switch (app) {
        case 'workout':
          return 'https://api.rummel.app/workout';
        case 'meal':
          return 'https://api.rummel.app/meal';
        case 'home':
          return 'https://api.rummel.app/home';
        case 'vehicle':
          return 'https://api.rummel.app/vehicle';
        default:
          return 'https://api.rummel.app';
      }
    }

    // Development URLs (local)
    if (kIsWeb) {
      // Web apps use reverse proxy
      switch (app) {
        case 'workout':
          return 'http://localhost:8000';
        case 'meal':
          return 'http://localhost:8010';
        case 'home':
          return 'http://localhost:8020';
        case 'vehicle':
          return 'http://localhost:8030';
        default:
          return 'http://localhost:8000';
      }
    } else {
      // Mobile apps connect directly
      final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
      switch (app) {
        case 'workout':
          return 'http://$host:8000';
        case 'meal':
          return 'http://$host:8010';
        case 'home':
          return 'http://$host:8020';
        case 'vehicle':
          return 'http://$host:8030';
        default:
          return 'http://$host:8000';
      }
    }
  }
}
