import 'package:flutter/foundation.dart';

/// Base class for all metrics
abstract class Metric {
  final DateTime timestamp;
  final String name;
  final Map<String, dynamic> tags;

  Metric({
    required this.name,
    Map<String, dynamic>? tags,
    DateTime? timestamp,
  })  : tags = tags ?? {},
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson();
}

/// HTTP request metric
class HttpRequestMetric extends Metric {
  final String method;
  final String endpoint;
  final int? statusCode;
  final Duration duration;
  final bool success;
  final String? errorType;
  final int? requestSize;
  final int? responseSize;

  HttpRequestMetric({
    required this.method,
    required this.endpoint,
    required this.duration,
    this.statusCode,
    this.success = true,
    this.errorType,
    this.requestSize,
    this.responseSize,
    Map<String, dynamic>? tags,
  }) : super(name: 'http_request', tags: tags);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'method': method,
      'endpoint': endpoint,
      'status_code': statusCode,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      'error_type': errorType,
      'request_size_bytes': requestSize,
      'response_size_bytes': responseSize,
      'tags': tags,
    };
  }
}

/// Authentication event metric
class AuthEventMetric extends Metric {
  final String eventType; // login, logout, register, refresh, failure
  final bool success;
  final String? errorReason;
  final String? userId;

  AuthEventMetric({
    required this.eventType,
    this.success = true,
    this.errorReason,
    this.userId,
    Map<String, dynamic>? tags,
  }) : super(name: 'auth_event', tags: tags);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType,
      'success': success,
      'error_reason': errorReason,
      'user_id': userId,
      'tags': tags,
    };
  }
}

/// Error occurrence metric
class ErrorMetric extends Metric {
  final String errorType;
  final String message;
  final String? stackTrace;
  final String? context; // Where the error occurred
  final Map<String, dynamic>? metadata;

  ErrorMetric({
    required this.errorType,
    required this.message,
    this.stackTrace,
    this.context,
    this.metadata,
    Map<String, dynamic>? tags,
  }) : super(name: 'error', tags: tags);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'error_type': errorType,
      'message': message,
      'stack_trace': stackTrace,
      'context': context,
      'metadata': metadata,
      'tags': tags,
    };
  }
}

/// Performance metric for custom tracking
class PerformanceMetric extends Metric {
  final String operation;
  final Duration duration;
  final bool success;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.operation,
    required this.duration,
    this.success = true,
    this.metadata,
    Map<String, dynamic>? tags,
  }) : super(name: 'performance', tags: tags);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      'metadata': metadata,
      'tags': tags,
    };
  }
}

/// User interaction metric
class UserEventMetric extends Metric {
  final String eventName;
  final String? screen;
  final Map<String, dynamic>? properties;

  UserEventMetric({
    required this.eventName,
    this.screen,
    this.properties,
    Map<String, dynamic>? tags,
  }) : super(name: 'user_event', tags: tags);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'event_name': eventName,
      'screen': screen,
      'properties': properties,
      'tags': tags,
    };
  }
}

/// Network connectivity metric
class NetworkEventMetric extends Metric {
  final String eventType; // online, offline, slow
  final String? connectionType; // wifi, cellular, none
  final int? latencyMs;

  NetworkEventMetric({
    required this.eventType,
    this.connectionType,
    this.latencyMs,
    Map<String, dynamic>? tags,
  }) : super(name: 'network_event', tags: tags);

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType,
      'connection_type': connectionType,
      'latency_ms': latencyMs,
      'tags': tags,
    };
  }
}
