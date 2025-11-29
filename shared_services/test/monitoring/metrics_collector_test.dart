import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  late MetricsCollector collector;

  setUp(() {
    collector = MetricsCollector();
    // Clear any previous state
    collector.clear();
    // Reset configuration before each test (disable console output for tests)
    collector.configure(MonitoringConfig(
      enabled: true,
      enableConsoleOutput: false, // Disable console output during tests
      appName: 'test',
      sampleRate: 1.0, // 100% sampling by default
    ));
  });

  tearDown(() {
    collector.clear();
  });

  group('Configuration', () {
    test('should apply development configuration', () {
      // Act
      collector.configure(MonitoringConfig.development(appName: 'test_app'));

      // Assert
      final metric = HttpRequestMetric(
        method: 'GET',
        endpoint: '/test',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      );

      collector.record(metric);
      final metrics = collector.getAllMetrics();

      expect(metrics, hasLength(1));
      expect(metrics.first, isA<HttpRequestMetric>());
    });

    test('should apply production configuration', () {
      // Act
      collector.configure(
        MonitoringConfig.production(appName: 'prod_app', sampleRate: 1.0),
      );

      // Assert
      final metric = HttpRequestMetric(
        method: 'POST',
        endpoint: '/api/data',
        duration: const Duration(milliseconds: 200),
        statusCode: 201,
        success: true,
      );

      collector.record(metric);
      final metrics = collector.getAllMetrics();

      expect(metrics, hasLength(1));
    });

    test('should disable collection when enabled is false', () {
      // Arrange
      collector.clear();
      collector.configure(MonitoringConfig(
        enabled: false,
        enableConsoleOutput: false,
        appName: 'disabled_app',
      ));

      // Act
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/test',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      ));

      // Assert
      expect(collector.getAllMetrics(), isEmpty);
    });

    test('should respect sample rate', () {
      // Clear before reconfiguring
      collector.clear();

      // Configure with 0% sample rate
      collector.configure(MonitoringConfig(
        enabled: true,
        enableConsoleOutput: false,
        sampleRate: 0.0, // Never sample
        appName: 'sample_test',
      ));

      // Clear again after configure to ensure clean state
      collector.clear();

      // Act - record multiple metrics
      for (var i = 0; i < 100; i++) {
        collector.record(HttpRequestMetric(
          method: 'GET',
          endpoint: '/test',
          duration: const Duration(milliseconds: 100),
          statusCode: 200,
          success: true,
        ));
      }

      // Assert - should have recorded nothing due to 0% sample rate
      expect(collector.getAllMetrics(), isEmpty);
    });

    test('should respect maxMetricsInMemory limit', () {
      // Arrange
      collector.clear();
      collector.configure(MonitoringConfig(
        enabled: true,
        enableConsoleOutput: false,
        maxMetricsInMemory: 5,
        appName: 'limit_test',
      ));

      // Act - record more than limit
      for (var i = 0; i < 10; i++) {
        collector.record(HttpRequestMetric(
          method: 'GET',
          endpoint: '/test$i',
          duration: const Duration(milliseconds: 100),
          statusCode: 200,
          success: true,
        ));
      }

      // Assert - should only keep last 5
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(5));
      expect((metrics.last as HttpRequestMetric).endpoint, equals('/test9'));
    });
  });

  group('Recording metrics', () {
    test('should record HttpRequestMetric', () {
      // Arrange
      final metric = HttpRequestMetric(
        method: 'GET',
        endpoint: '/users/123',
        duration: const Duration(milliseconds: 234),
        statusCode: 200,
        success: true,
      );

      // Act
      collector.record(metric);

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(1));
      expect(metrics.first, isA<HttpRequestMetric>());

      final recorded = metrics.first as HttpRequestMetric;
      expect(recorded.method, equals('GET'));
      expect(recorded.endpoint, equals('/users/123'));
      expect(recorded.duration.inMilliseconds, equals(234));
      expect(recorded.statusCode, equals(200));
      expect(recorded.success, isTrue);
    });

    test('should record AuthEventMetric', () {
      // Arrange
      final metric = AuthEventMetric(
        eventType: 'login',
        success: true,
        userId: 'user-456',
      );

      // Act
      collector.record(metric);

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(1));
      expect(metrics.first, isA<AuthEventMetric>());

      final recorded = metrics.first as AuthEventMetric;
      expect(recorded.eventType, equals('login'));
      expect(recorded.success, isTrue);
      expect(recorded.userId, equals('user-456'));
    });

    test('should record ErrorMetric', () {
      // Arrange
      final metric = ErrorMetric(
        errorType: 'NetworkException',
        message: 'Connection failed',
        stackTrace: 'Stack trace here',
        context: 'user_login',
      );

      // Act
      collector.record(metric);

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(1));
      expect(metrics.first, isA<ErrorMetric>());

      final recorded = metrics.first as ErrorMetric;
      expect(recorded.errorType, equals('NetworkException'));
      expect(recorded.message, equals('Connection failed'));
      expect(recorded.context, equals('user_login'));
    });

    test('should record PerformanceMetric', () {
      // Arrange
      final metric = PerformanceMetric(
        operation: 'database_query',
        duration: const Duration(milliseconds: 450),
        success: true,
        metadata: {'query': 'SELECT * FROM users'},
      );

      // Act
      collector.record(metric);

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(1));
      expect(metrics.first, isA<PerformanceMetric>());

      final recorded = metrics.first as PerformanceMetric;
      expect(recorded.operation, equals('database_query'));
      expect(recorded.duration.inMilliseconds, equals(450));
    });

    test('should record UserEventMetric', () {
      // Arrange
      final metric = UserEventMetric(
        eventName: 'button_clicked',
        screen: 'home_screen',
        properties: {'button_id': 'submit'},
      );

      // Act
      collector.record(metric);

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(1));
      expect(metrics.first, isA<UserEventMetric>());

      final recorded = metrics.first as UserEventMetric;
      expect(recorded.eventName, equals('button_clicked'));
      expect(recorded.screen, equals('home_screen'));
    });

    test('should record NetworkEventMetric', () {
      // Arrange
      final metric = NetworkEventMetric(
        eventType: 'connectivity_changed',
        connectionType: 'wifi',
      );

      // Act
      collector.record(metric);

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(1));
      expect(metrics.first, isA<NetworkEventMetric>());

      final recorded = metrics.first as NetworkEventMetric;
      expect(recorded.eventType, equals('connectivity_changed'));
      expect(recorded.connectionType, equals('wifi'));
    });

    test('should record multiple metrics in order', () {
      // Arrange & Act
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/first',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      ));

      collector.record(AuthEventMetric(
        eventType: 'login',
        success: true,
      ));

      collector.record(HttpRequestMetric(
        method: 'POST',
        endpoint: '/second',
        duration: const Duration(milliseconds: 200),
        statusCode: 201,
        success: true,
      ));

      // Assert
      final metrics = collector.getAllMetrics();
      expect(metrics, hasLength(3));
      expect(metrics[0], isA<HttpRequestMetric>());
      expect(metrics[1], isA<AuthEventMetric>());
      expect(metrics[2], isA<HttpRequestMetric>());
    });
  });

  group('Querying metrics', () {
    setUp(() {
      // Add sample data
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/users',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      ));

      collector.record(AuthEventMetric(
        eventType: 'login',
        success: true,
        userId: 'user-1',
      ));

      collector.record(HttpRequestMetric(
        method: 'POST',
        endpoint: '/users',
        duration: const Duration(milliseconds: 500),
        statusCode: 500,
        success: false,
        errorType: 'ServerError',
      ));

      collector.record(ErrorMetric(
        errorType: 'ValidationError',
        message: 'Invalid input',
        context: 'form_submission',
      ));
    });

    test('should get all metrics', () {
      // Act
      final metrics = collector.getAllMetrics();

      // Assert
      expect(metrics, hasLength(4));
    });

    test('should filter metrics by type', () {
      // Act
      final httpMetrics = collector.getMetrics<HttpRequestMetric>();
      final authMetrics = collector.getMetrics<AuthEventMetric>();
      final errorMetrics = collector.getMetrics<ErrorMetric>();

      // Assert
      expect(httpMetrics, hasLength(2));
      expect(authMetrics, hasLength(1));
      expect(errorMetrics, hasLength(1));
    });

    test('should get metrics in time range', () {
      // Arrange
      final now = DateTime.now();
      final oneSecondAgo = now.subtract(const Duration(seconds: 1));
      final future = now.add(const Duration(seconds: 1));

      // Act
      final metricsInRange = collector.getMetricsInRange(oneSecondAgo, future);

      // Assert
      expect(metricsInRange, hasLength(4));
    });

    test('should get empty list for future time range', () {
      // Arrange
      final future = DateTime.now().add(const Duration(hours: 1));
      final moreFuture = future.add(const Duration(hours: 1));

      // Act
      final metricsInRange = collector.getMetricsInRange(future, moreFuture);

      // Assert
      expect(metricsInRange, isEmpty);
    });
  });

  group('Statistics', () {
    setUp(() {
      // Add comprehensive test data
      for (var i = 0; i < 10; i++) {
        collector.record(HttpRequestMetric(
          method: 'GET',
          endpoint: '/api/users',
          duration: Duration(milliseconds: 100 + i * 10),
          statusCode: 200,
          success: true,
        ));
      }

      for (var i = 0; i < 3; i++) {
        collector.record(HttpRequestMetric(
          method: 'POST',
          endpoint: '/api/users',
          duration: const Duration(milliseconds: 200),
          statusCode: 500,
          success: false,
          errorType: 'ServerError',
        ));
      }

      collector.record(AuthEventMetric(
        eventType: 'login',
        success: true,
        userId: 'user-1',
      ));

      collector.record(AuthEventMetric(
        eventType: 'login',
        success: false,
        errorReason: 'Invalid password',
      ));

      // Record 3 ServerError metrics (one for each failed request)
      for (var i = 0; i < 3; i++) {
        collector.record(ErrorMetric(
          errorType: 'ServerError',
          message: 'Internal server error',
          context: 'api_call',
        ));
      }

      collector.record(ErrorMetric(
        errorType: 'NetworkException',
        message: 'Connection failed',
        context: 'api_call',
      ));

      collector.record(ErrorMetric(
        errorType: 'ValidationException',
        message: 'Invalid data',
        context: 'form',
      ));
    });

    test('should calculate total requests', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.totalRequests, equals(13));
    });

    test('should calculate successful requests', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.successfulRequests, equals(10));
    });

    test('should calculate success rate', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.successRate, closeTo(0.769, 0.001)); // 10/13
    });

    test('should calculate average response time', () {
      // Act
      final stats = collector.getStats();

      // Assert
      // Average of: 100,110,120,130,140,150,160,170,180,190,200,200,200
      expect(stats.averageResponseTime.inMilliseconds, closeTo(158, 1));
    });

    test('should count errors by type', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.errorsByType, hasLength(3));
      expect(stats.errorsByType['ServerError'], equals(3));
      expect(stats.errorsByType['NetworkException'], equals(1));
      expect(stats.errorsByType['ValidationException'], equals(1));
    });

    test('should count requests by endpoint', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.requestsByEndpoint, hasLength(1));
      expect(stats.requestsByEndpoint['/api/users'], equals(13));
    });

    test('should count auth events', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.totalAuthEvents, equals(2));
    });

    test('should count successful logins', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.successfulLogins, equals(1));
    });

    test('should count failed logins', () {
      // Act
      final stats = collector.getStats();

      // Assert
      expect(stats.failedLogins, equals(1));
    });
  });

  group('Observers', () {
    test('should notify observers when metric is recorded', () {
      // Arrange
      final receivedMetrics = <Metric>[];
      final observer = TestObserver((metric) {
        receivedMetrics.add(metric);
      });

      collector.addObserver(observer);

      final metric = HttpRequestMetric(
        method: 'GET',
        endpoint: '/test',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      );

      // Act
      collector.record(metric);

      // Assert
      expect(receivedMetrics, hasLength(1));
      expect(receivedMetrics.first, equals(metric));
    });

    test('should notify multiple observers', () {
      // Arrange
      final receivedMetrics1 = <Metric>[];
      final receivedMetrics2 = <Metric>[];

      collector.addObserver(TestObserver((m) => receivedMetrics1.add(m)));
      collector.addObserver(TestObserver((m) => receivedMetrics2.add(m)));

      final metric = AuthEventMetric(
        eventType: 'logout',
        success: true,
      );

      // Act
      collector.record(metric);

      // Assert
      expect(receivedMetrics1, hasLength(1));
      expect(receivedMetrics2, hasLength(1));
    });

    test('should remove observer', () {
      // Arrange
      final receivedMetrics = <Metric>[];
      final observer = TestObserver((m) => receivedMetrics.add(m));

      collector.addObserver(observer);
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/test1',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      ));

      // Act
      collector.removeObserver(observer);
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/test2',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      ));

      // Assert
      expect(receivedMetrics, hasLength(1));
    });
  });

  group('Export', () {
    setUp(() {
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/test',
        duration: const Duration(milliseconds: 123),
        statusCode: 200,
        success: true,
      ));

      collector.record(AuthEventMetric(
        eventType: 'login',
        success: true,
        userId: 'user-123',
      ));
    });

    test('should export metrics to JSON', () {
      // Act
      final json = collector.exportToJson();

      // Assert
      expect(json, isA<List>());
      expect(json, hasLength(2));

      final firstMetric = json[0] as Map<String, dynamic>;
      expect(firstMetric['name'], equals('http_request'));
      expect(firstMetric['method'], equals('GET'));
      expect(firstMetric['endpoint'], equals('/test'));

      final secondMetric = json[1] as Map<String, dynamic>;
      expect(secondMetric['name'], equals('auth_event'));
      expect(secondMetric['event_type'], equals('login'));
    });
  });

  group('Clear', () {
    test('should clear all metrics', () {
      // Arrange
      collector.record(HttpRequestMetric(
        method: 'GET',
        endpoint: '/test',
        duration: const Duration(milliseconds: 100),
        statusCode: 200,
        success: true,
      ));

      expect(collector.getAllMetrics(), hasLength(1));

      // Act
      collector.clear();

      // Assert
      expect(collector.getAllMetrics(), isEmpty);
    });
  });
}

// Test observer implementation
class TestObserver implements MetricsObserver {
  final void Function(Metric) callback;

  TestObserver(this.callback);

  @override
  String get name => 'test_observer';

  @override
  void onMetric(Metric metric) {
    callback(metric);
  }
}
