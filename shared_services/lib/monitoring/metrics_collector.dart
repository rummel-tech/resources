import 'dart:collection';
import 'dart:math';
import 'package:logging/logging.dart';
import 'metrics.dart';
import 'monitoring_config.dart';

/// Collects and aggregates metrics
class MetricsCollector {
  static final MetricsCollector _instance = MetricsCollector._internal();
  factory MetricsCollector() => _instance;
  MetricsCollector._internal();

  final _logger = Logger('MetricsCollector');
  final _metrics = Queue<Metric>();
  final _observers = <MetricsObserver>[];

  MonitoringConfig _config = MonitoringConfig();

  int _maxMetricsInMemory = 1000;
  bool _enabled = true;

  /// Configure the metrics collector
  void configure(MonitoringConfig config) {
    _config = config;
    _enabled = config.enabled;
    _maxMetricsInMemory = config.maxMetricsInMemory;

    if (config.enableConsoleOutput) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        if (config.enableConsoleOutput) {
          print('[${record.level.name}] ${record.time}: ${record.message}');
        }
      });
    }
  }

  /// Add a metrics observer (e.g., Firebase, Sentry, custom backend)
  void addObserver(MetricsObserver observer) {
    _observers.add(observer);
    _logger.info('Added metrics observer: ${observer.name}');
  }

  /// Remove a metrics observer
  void removeObserver(MetricsObserver observer) {
    _observers.remove(observer);
  }

  /// Record a metric
  void record(Metric metric) {
    if (!_enabled) return;

    // Apply sample rate (probabilistic sampling)
    if (_config.sampleRate < 1.0) {
      final random = Random().nextDouble();
      if (random > _config.sampleRate) {
        return; // Skip this metric based on sampling
      }
    }

    // Add to in-memory queue
    _metrics.add(metric);

    // Trim if exceeds max size
    while (_metrics.length > _maxMetricsInMemory) {
      _metrics.removeFirst();
    }

    // Log based on metric type
    _logMetric(metric);

    // Notify observers
    for (final observer in _observers) {
      try {
        observer.onMetric(metric);
      } catch (e) {
        _logger.warning('Observer ${observer.name} failed: $e');
      }
    }
  }

  /// Log metric to console
  void _logMetric(Metric metric) {
    if (!_config.enableConsoleOutput) return;

    if (metric is HttpRequestMetric) {
      final level = metric.success ? Level.INFO : Level.WARNING;
      _logger.log(
        level,
        'HTTP ${metric.method} ${metric.endpoint} -> ${metric.statusCode} (${metric.duration.inMilliseconds}ms)',
      );
    } else if (metric is AuthEventMetric) {
      final level = metric.success ? Level.INFO : Level.WARNING;
      _logger.log(
        level,
        'Auth: ${metric.eventType} - ${metric.success ? 'success' : 'failed: ${metric.errorReason}'}',
      );
    } else if (metric is ErrorMetric) {
      _logger.severe('Error [${metric.errorType}]: ${metric.message}');
    } else if (metric is PerformanceMetric) {
      _logger.info('${metric.operation}: ${metric.duration.inMilliseconds}ms');
    }
  }

  /// Get all metrics in memory
  List<Metric> getAllMetrics() => _metrics.toList();

  /// Get metrics of a specific type
  List<T> getMetrics<T extends Metric>() {
    return _metrics.whereType<T>().toList();
  }

  /// Get metrics within a time range
  List<Metric> getMetricsInRange(DateTime start, DateTime end) {
    return _metrics
        .where((m) => m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
        .toList();
  }

  /// Get aggregated statistics
  MetricsStats getStats() {
    final httpMetrics = getMetrics<HttpRequestMetric>();
    final authMetrics = getMetrics<AuthEventMetric>();
    final errorMetrics = getMetrics<ErrorMetric>();

    return MetricsStats(
      totalRequests: httpMetrics.length,
      successfulRequests: httpMetrics.where((m) => m.success).length,
      failedRequests: httpMetrics.where((m) => !m.success).length,
      averageResponseTime: httpMetrics.isEmpty
          ? Duration.zero
          : Duration(
              milliseconds: httpMetrics
                      .map((m) => m.duration.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  httpMetrics.length,
            ),
      totalAuthEvents: authMetrics.length,
      successfulLogins: authMetrics
          .where((m) => m.eventType == 'login' && m.success)
          .length,
      failedLogins: authMetrics
          .where((m) => m.eventType == 'login' && !m.success)
          .length,
      totalErrors: errorMetrics.length,
      errorsByType: _groupErrorsByType(errorMetrics),
      requestsByEndpoint: _groupRequestsByEndpoint(httpMetrics),
    );
  }

  Map<String, int> _groupErrorsByType(List<ErrorMetric> errors) {
    final grouped = <String, int>{};
    for (final error in errors) {
      grouped[error.errorType] = (grouped[error.errorType] ?? 0) + 1;
    }
    return grouped;
  }

  Map<String, int> _groupRequestsByEndpoint(List<HttpRequestMetric> requests) {
    final grouped = <String, int>{};
    for (final request in requests) {
      grouped[request.endpoint] = (grouped[request.endpoint] ?? 0) + 1;
    }
    return grouped;
  }

  /// Clear all metrics from memory
  void clear() {
    _metrics.clear();
    _logger.info('Cleared all metrics');
  }

  /// Export metrics as JSON
  List<Map<String, dynamic>> exportToJson() {
    return _metrics.map((m) => m.toJson()).toList();
  }
}

/// Observer interface for custom metric handling
abstract class MetricsObserver {
  String get name;
  void onMetric(Metric metric);
}

/// Statistics summary
class MetricsStats {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final Duration averageResponseTime;
  final int totalAuthEvents;
  final int successfulLogins;
  final int failedLogins;
  final int totalErrors;
  final Map<String, int> errorsByType;
  final Map<String, int> requestsByEndpoint;

  MetricsStats({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.totalAuthEvents,
    required this.successfulLogins,
    required this.failedLogins,
    required this.totalErrors,
    required this.errorsByType,
    required this.requestsByEndpoint,
  });

  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;

  @override
  String toString() {
    return '''
MetricsStats:
  HTTP Requests: $totalRequests (Success: $successfulRequests, Failed: $failedRequests)
  Success Rate: ${(successRate * 100).toStringAsFixed(1)}%
  Avg Response Time: ${averageResponseTime.inMilliseconds}ms
  Auth Events: $totalAuthEvents (Logins: $successfulLogins success, $failedLogins failed)
  Total Errors: $totalErrors
  Errors by Type: $errorsByType
  Top Endpoints: $requestsByEndpoint
''';
  }
}
