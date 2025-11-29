import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/network_exception.dart';
import '../monitoring/metrics.dart';
import '../monitoring/metrics_collector.dart';
import 'api_config.dart';

/// Base HTTP client with timeout, retry, and error handling
class BaseApiClient {
  final ApiConfig config;
  final http.Client _httpClient;
  final Logger _logger;

  /// Optional token provider for authenticated requests
  Future<String?> Function()? tokenProvider;

  /// Metrics collector for monitoring
  final MetricsCollector _metrics = MetricsCollector();

  BaseApiClient({
    required this.config,
    http.Client? httpClient,
    this.tokenProvider,
  })  : _httpClient = httpClient ?? http.Client(),
        _logger = Logger('BaseApiClient') {
    if (config.enableDebugLogs) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
    }
  }

  /// GET request
  Future<T> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    _logger.info('GET $uri');

    final stopwatch = Stopwatch()..start();
    bool success = true;
    int? statusCode;
    String? errorType;

    try {
      final response = await _executeWithRetry(() async {
        return await _httpClient
            .get(uri, headers: await _buildHeaders(headers))
            .timeout(config.timeout);
      });

      statusCode = response.statusCode;
      final result = _handleResponse(response, fromJson);
      return result;
    } catch (e) {
      success = false;
      errorType = e.runtimeType.toString();
      rethrow;
    } finally {
      stopwatch.stop();
      _recordHttpMetric('GET', endpoint, stopwatch.elapsed, success, statusCode, errorType);
    }
  }

  /// POST request
  Future<T> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final uri = _buildUri(endpoint);
    _logger.info('POST $uri');

    final stopwatch = Stopwatch()..start();
    bool success = true;
    int? statusCode;
    String? errorType;

    try {
      final response = await _executeWithRetry(() async {
        return await _httpClient
            .post(
              uri,
              headers: await _buildHeaders(headers),
              body: body != null ? json.encode(body) : null,
            )
            .timeout(config.timeout);
      });

      statusCode = response.statusCode;
      final result = _handleResponse(response, fromJson);
      return result;
    } catch (e) {
      success = false;
      errorType = e.runtimeType.toString();
      rethrow;
    } finally {
      stopwatch.stop();
      _recordHttpMetric('POST', endpoint, stopwatch.elapsed, success, statusCode, errorType);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final uri = _buildUri(endpoint);
    _logger.info('PUT $uri');

    final stopwatch = Stopwatch()..start();
    bool success = true;
    int? statusCode;
    String? errorType;

    try {
      final response = await _executeWithRetry(() async {
        return await _httpClient
            .put(
              uri,
              headers: await _buildHeaders(headers),
              body: body != null ? json.encode(body) : null,
            )
            .timeout(config.timeout);
      });

      statusCode = response.statusCode;
      final result = _handleResponse(response, fromJson);
      return result;
    } catch (e) {
      success = false;
      errorType = e.runtimeType.toString();
      rethrow;
    } finally {
      stopwatch.stop();
      _recordHttpMetric('PUT', endpoint, stopwatch.elapsed, success, statusCode, errorType);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final uri = _buildUri(endpoint);
    _logger.info('DELETE $uri');

    final stopwatch = Stopwatch()..start();
    bool success = true;
    int? statusCode;
    String? errorType;

    try {
      final response = await _executeWithRetry(() async {
        return await _httpClient
            .delete(uri, headers: await _buildHeaders(headers))
            .timeout(config.timeout);
      });

      statusCode = response.statusCode;
      final result = _handleResponse(response, fromJson);
      return result;
    } catch (e) {
      success = false;
      errorType = e.runtimeType.toString();
      rethrow;
    } finally {
      stopwatch.stop();
      _recordHttpMetric('DELETE', endpoint, stopwatch.elapsed, success, statusCode, errorType);
    }
  }

  /// DELETE request without response body
  Future<void> deleteNoResponse(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint);
    _logger.info('DELETE $uri');

    final stopwatch = Stopwatch()..start();
    bool success = true;
    int? statusCode;
    String? errorType;

    try {
      final response = await _executeWithRetry(() async {
        return await _httpClient
            .delete(uri, headers: await _buildHeaders(headers))
            .timeout(config.timeout);
      });

      statusCode = response.statusCode;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        success = false;
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      success = false;
      errorType = e.runtimeType.toString();
      rethrow;
    } finally {
      stopwatch.stop();
      _recordHttpMetric('DELETE', endpoint, stopwatch.elapsed, success, statusCode, errorType);
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final url = endpoint.startsWith('http')
        ? endpoint
        : '${config.baseUrl}$endpoint';

    final uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      });
    }

    return uri;
  }

  /// Build headers with authentication and content type
  Future<Map<String, String>> _buildHeaders(
      Map<String, String>? customHeaders) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authentication token if available
    if (tokenProvider != null) {
      final token = await tokenProvider!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // Merge custom headers
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Execute request with retry logic
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 500);

    while (true) {
      attempts++;

      try {
        final response = await request();

        // Don't retry on successful responses or client errors (4xx)
        if (response.statusCode < 500) {
          return response;
        }

        // Retry on server errors if we haven't exceeded max retries
        if (attempts >= config.maxRetries) {
          return response;
        }

        _logger.warning(
            'Server error ${response.statusCode}, retrying (attempt $attempts/${config.maxRetries})...');
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff

      } on SocketException catch (e) {
        _logger.severe('Network error: $e');

        if (attempts >= config.maxRetries) {
          throw NetworkException.connectionFailed();
        }

        _logger.warning('Retrying after network error (attempt $attempts/${config.maxRetries})...');
        await Future.delayed(delay);
        delay *= 2;

      } on TimeoutException catch (e) {
        _logger.severe('Request timeout: $e');

        if (attempts >= config.maxRetries) {
          throw NetworkException.timeout();
        }

        _logger.warning('Retrying after timeout (attempt $attempts/${config.maxRetries})...');
        await Future.delayed(delay);
        delay *= 2;

      } on http.ClientException catch (e) {
        _logger.severe('HTTP client error: $e');

        if (e.message.contains('Failed host lookup')) {
          throw NetworkException.hostLookupFailed();
        }

        if (attempts >= config.maxRetries) {
          throw NetworkException(e.message);
        }

        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  /// Handle HTTP response and convert to typed result
  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    _logger.fine('Response status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return fromJson(jsonData);
      } catch (e) {
        _logger.severe('Failed to decode response: $e');
        throw ApiException(
          message: 'Failed to parse response',
          code: 'PARSE_ERROR',
          statusCode: response.statusCode,
        );
      }
    }

    // Handle error responses
    throw ApiException.fromResponse(response);
  }

  /// Record HTTP request metric
  void _recordHttpMetric(
    String method,
    String endpoint,
    Duration duration,
    bool success,
    int? statusCode,
    String? errorType,
  ) {
    _metrics.record(HttpRequestMetric(
      method: method,
      endpoint: endpoint,
      duration: duration,
      statusCode: statusCode,
      success: success,
      errorType: errorType,
    ));
  }

  /// Close the HTTP client
  void dispose() {
    _httpClient.close();
  }
}
