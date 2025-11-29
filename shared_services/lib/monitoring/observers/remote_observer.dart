import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../metrics.dart';
import '../metrics_collector.dart';

/// Observer that sends metrics to a remote endpoint
class RemoteObserver implements MetricsObserver {
  final String endpoint;
  final Duration batchInterval;
  final int batchSize;
  final Map<String, String> headers;

  final _queue = Queue<Metric>();
  Timer? _batchTimer;
  bool _sending = false;

  RemoteObserver({
    required this.endpoint,
    this.batchInterval = const Duration(seconds: 30),
    this.batchSize = 50,
    Map<String, String>? headers,
  }) : headers = headers ?? {'Content-Type': 'application/json'} {
    _startBatchTimer();
  }

  @override
  String get name => 'RemoteObserver';

  void _startBatchTimer() {
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(batchInterval, (_) => _sendBatch());
  }

  @override
  void onMetric(Metric metric) {
    _queue.add(metric);

    // Send immediately if batch size reached
    if (_queue.length >= batchSize) {
      _sendBatch();
    }
  }

  Future<void> _sendBatch() async {
    if (_sending || _queue.isEmpty) return;

    _sending = true;
    final batch = <Metric>[];

    // Collect up to batchSize metrics
    while (_queue.isNotEmpty && batch.length < batchSize) {
      batch.add(_queue.removeFirst());
    }

    try {
      final payload = {
        'metrics': batch.map((m) => m.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('RemoteObserver: Sent ${batch.length} metrics successfully');
      } else {
        print('RemoteObserver: Failed to send metrics: ${response.statusCode}');
        // Re-queue failed metrics
        for (final metric in batch.reversed) {
          _queue.addFirst(metric);
        }
      }
    } catch (e) {
      print('RemoteObserver: Error sending metrics: $e');
      // Re-queue failed metrics
      for (final metric in batch.reversed) {
        _queue.addFirst(metric);
      }
    } finally {
      _sending = false;
    }
  }

  /// Manually flush all queued metrics
  Future<void> flush() async {
    while (_queue.isNotEmpty) {
      await _sendBatch();
    }
  }

  /// Clean up resources
  void dispose() {
    _batchTimer?.cancel();
    _queue.clear();
  }
}
