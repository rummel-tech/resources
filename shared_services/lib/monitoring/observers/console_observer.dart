import '../metrics.dart';
import '../metrics_collector.dart';

/// Observer that outputs metrics to console
class ConsoleObserver implements MetricsObserver {
  final bool verbose;

  ConsoleObserver({this.verbose = false});

  @override
  String get name => 'ConsoleObserver';

  @override
  void onMetric(Metric metric) {
    if (metric is HttpRequestMetric) {
      _logHttpRequest(metric);
    } else if (metric is AuthEventMetric) {
      _logAuthEvent(metric);
    } else if (metric is ErrorMetric) {
      _logError(metric);
    } else if (metric is PerformanceMetric) {
      _logPerformance(metric);
    } else if (verbose) {
      print('[Metric] ${metric.name}: ${metric.toJson()}');
    }
  }

  void _logHttpRequest(HttpRequestMetric metric) {
    final status = metric.success ? '✓' : '✗';
    final time = '${metric.duration.inMilliseconds}ms';
    print('$status HTTP ${metric.method} ${metric.endpoint} ${metric.statusCode} ($time)');

    if (verbose && !metric.success) {
      print('  Error: ${metric.errorType}');
    }
  }

  void _logAuthEvent(AuthEventMetric metric) {
    final status = metric.success ? '✓' : '✗';
    print('$status Auth: ${metric.eventType}${!metric.success ? ' - ${metric.errorReason}' : ''}');
  }

  void _logError(ErrorMetric metric) {
    print('✗ Error [${metric.errorType}]: ${metric.message}');
    if (verbose && metric.stackTrace != null) {
      print('  Stack: ${metric.stackTrace}');
    }
  }

  void _logPerformance(PerformanceMetric metric) {
    print('⏱ ${metric.operation}: ${metric.duration.inMilliseconds}ms');
  }
}
