import 'dart:convert';
import 'dart:io';
import '../metrics.dart';
import '../metrics_collector.dart';

/// Observer that writes metrics to a file
class FileObserver implements MetricsObserver {
  final String filePath;
  final bool prettyPrint;
  IOSink? _sink;

  FileObserver({
    required this.filePath,
    this.prettyPrint = true,
  }) {
    _initFile();
  }

  void _initFile() {
    try {
      final file = File(filePath);
      _sink = file.openWrite(mode: FileMode.append);
    } catch (e) {
      print('FileObserver: Failed to open file $filePath: $e');
    }
  }

  @override
  String get name => 'FileObserver';

  @override
  void onMetric(Metric metric) {
    if (_sink == null) return;

    try {
      final json = metric.toJson();
      final output = prettyPrint
          ? const JsonEncoder.withIndent('  ').convert(json)
          : jsonEncode(json);
      _sink!.writeln(output);
    } catch (e) {
      print('FileObserver: Failed to write metric: $e');
    }
  }

  /// Flush buffered metrics to disk
  Future<void> flush() async {
    await _sink?.flush();
  }

  /// Close the file
  Future<void> close() async {
    await _sink?.close();
    _sink = null;
  }
}
