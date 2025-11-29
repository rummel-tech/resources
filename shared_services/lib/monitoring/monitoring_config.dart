/// Configuration for monitoring and metrics
class MonitoringConfig {
  /// Whether monitoring is enabled
  final bool enabled;

  /// Whether to output metrics to console
  final bool enableConsoleOutput;

  /// Maximum number of metrics to keep in memory
  final int maxMetricsInMemory;

  /// Whether to track HTTP requests
  final bool trackHttpRequests;

  /// Whether to track authentication events
  final bool trackAuthEvents;

  /// Whether to track errors
  final bool trackErrors;

  /// Whether to track performance metrics
  final bool trackPerformance;

  /// Whether to track user events
  final bool trackUserEvents;

  /// Minimum duration to log slow requests (null = log all)
  final Duration? slowRequestThreshold;

  /// Sample rate for metrics (1.0 = 100%, 0.5 = 50%, etc.)
  final double sampleRate;

  /// Environment name (development, staging, production)
  final String environment;

  /// Application name
  final String appName;

  /// Additional tags to add to all metrics
  final Map<String, dynamic> globalTags;

  const MonitoringConfig({
    this.enabled = true,
    this.enableConsoleOutput = true,
    this.maxMetricsInMemory = 1000,
    this.trackHttpRequests = true,
    this.trackAuthEvents = true,
    this.trackErrors = true,
    this.trackPerformance = true,
    this.trackUserEvents = false,
    this.slowRequestThreshold,
    this.sampleRate = 1.0,
    this.environment = 'development',
    this.appName = 'rummel_app',
    this.globalTags = const {},
  });

  /// Development configuration
  factory MonitoringConfig.development({String? appName}) {
    return MonitoringConfig(
      enabled: true,
      enableConsoleOutput: true,
      environment: 'development',
      appName: appName ?? 'rummel_app',
      slowRequestThreshold: const Duration(seconds: 2),
    );
  }

  /// Production configuration
  factory MonitoringConfig.production({
    required String appName,
    double sampleRate = 0.1,
  }) {
    return MonitoringConfig(
      enabled: true,
      enableConsoleOutput: false,
      environment: 'production',
      appName: appName,
      sampleRate: sampleRate,
      slowRequestThreshold: const Duration(seconds: 5),
    );
  }

  /// Disabled configuration
  factory MonitoringConfig.disabled() {
    return const MonitoringConfig(enabled: false);
  }

  MonitoringConfig copyWith({
    bool? enabled,
    bool? enableConsoleOutput,
    int? maxMetricsInMemory,
    bool? trackHttpRequests,
    bool? trackAuthEvents,
    bool? trackErrors,
    bool? trackPerformance,
    bool? trackUserEvents,
    Duration? slowRequestThreshold,
    double? sampleRate,
    String? environment,
    String? appName,
    Map<String, dynamic>? globalTags,
  }) {
    return MonitoringConfig(
      enabled: enabled ?? this.enabled,
      enableConsoleOutput: enableConsoleOutput ?? this.enableConsoleOutput,
      maxMetricsInMemory: maxMetricsInMemory ?? this.maxMetricsInMemory,
      trackHttpRequests: trackHttpRequests ?? this.trackHttpRequests,
      trackAuthEvents: trackAuthEvents ?? this.trackAuthEvents,
      trackErrors: trackErrors ?? this.trackErrors,
      trackPerformance: trackPerformance ?? this.trackPerformance,
      trackUserEvents: trackUserEvents ?? this.trackUserEvents,
      slowRequestThreshold: slowRequestThreshold ?? this.slowRequestThreshold,
      sampleRate: sampleRate ?? this.sampleRate,
      environment: environment ?? this.environment,
      appName: appName ?? this.appName,
      globalTags: globalTags ?? this.globalTags,
    );
  }
}
