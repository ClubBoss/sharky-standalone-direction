import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

const String _reportsDir = 'release/_reports';
const String _analyticsDir = 'release/_analytics';
const String _summaryTextPath = '$_reportsDir/long_term_analytics_summary.txt';
const String _summaryJsonPath = '$_reportsDir/long_term_analytics_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final archive = LongTermAnalyticsArchive();
  final ok = await archive.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LongTermAnalyticsArchive {
  Future<bool> run() async {
    final jsonFiles = await _collectJsonFiles();
    if (jsonFiles.isEmpty) {
      stderr.writeln('No JSON reports found in $_reportsDir.');
      return false;
    }

    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final archivePath = '$_analyticsDir/long_term_metrics_$timestamp.zip';

    try {
      await _withReportsWritable(() async {
        await Directory(_analyticsDir).create(recursive: true);
        final archive = Archive();
        final basePath = Directory(_reportsDir).absolute.path;
        for (final file in jsonFiles) {
          final relative = p.relative(file.path, from: basePath);
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(relative, bytes.length, bytes));
        }
        final encoded = ZipEncoder().encode(archive);
        await File(archivePath).writeAsBytes(encoded, flush: true);

        final trends = await _computeTrends();
        final summaryText = _buildTextSummary(
          archivePath: archivePath,
          fileCount: jsonFiles.length,
          trends: trends,
        );
        final summaryJson = _buildJsonSummary(
          archivePath: archivePath,
          fileCount: jsonFiles.length,
          trends: trends,
        );
        await File(_summaryTextPath).writeAsString(summaryText);
        await File(_summaryJsonPath).writeAsString(
          const JsonEncoder.withIndent('  ').convert(summaryJson),
        );
        await _appendTelemetry(archivePath, trends);
      });
    } catch (error, stack) {
      stderr.writeln('Analytics archive failed: $error');
      stderr.writeln(stack);
      return false;
    }

    return true;
  }

  Future<List<File>> _collectJsonFiles() async {
    final dir = Directory(_reportsDir);
    if (!await dir.exists()) return <File>[];
    final files = <File>[];
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.json')) {
        files.add(entity);
      }
    }
    return files;
  }

  Future<_TrendMetrics> _computeTrends() async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 7));
    final stabilityValues = <double>[];
    final rsiValues = <double>[];
    final monetizationValues = <double>[];
    final cohesionValues = <double>[];

    final file = File(_telemetryPath);
    if (await file.exists()) {
      final lines = await file.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        Map<String, Object?>? payload;
        try {
          payload = json.decode(line) as Map<String, Object?>?;
        } catch (_) {
          continue;
        }
        if (payload == null) continue;
        final event = payload['event'] as String?;
        if (event == null) continue;
        final timestampStr = payload['timestamp'] as String?;
        if (timestampStr == null) continue;
        DateTime timestamp;
        try {
          timestamp = DateTime.parse(timestampStr).toUtc();
        } catch (_) {
          continue;
        }
        if (timestamp.isBefore(cutoff)) continue;
        final metricValue = _extractMetric(event, payload);
        if (metricValue != null) {
          switch (event) {
            case 'stability_dashboard_completed':
              stabilityValues.add(metricValue);
              break;
            case 'regression_stability_completed':
              rsiValues.add(metricValue);
              break;
            case 'release_qa_consolidation_completed':
              monetizationValues.add(metricValue);
              final cohesionValue = _asDouble(
                payload['visual_ux_polish_index'],
              );
              if (cohesionValue != null) {
                cohesionValues.add(cohesionValue);
              }
              break;
          }
        }
      }
    }

    double avg(List<double> list) =>
        list.isEmpty ? double.nan : list.reduce((a, b) => a + b) / list.length;

    return _TrendMetrics(
      stability: avg(stabilityValues),
      rsi: avg(rsiValues),
      monetization: avg(monetizationValues),
      cohesion: avg(cohesionValues),
      counts: {
        'stability': stabilityValues.length,
        'rsi': rsiValues.length,
        'monetization': monetizationValues.length,
        'cohesion': cohesionValues.length,
      },
    );
  }

  double? _extractMetric(String event, Map<String, Object?> payload) {
    switch (event) {
      case 'stability_dashboard_completed':
        return _asDouble(payload['health_score']);
      case 'regression_stability_completed':
        return _asDouble(payload['health_score']);
      case 'release_qa_consolidation_completed':
        return _asDouble(
          payload['global_monetization_index'] ??
              payload['visual_ux_polish_index'],
        );
      default:
        return null;
    }
  }

  String _buildTextSummary({
    required String archivePath,
    required int fileCount,
    required _TrendMetrics trends,
  }) {
    final buffer = StringBuffer()
      ..writeln('LONG-TERM ANALYTICS SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Archive: $archivePath')
      ..writeln('Archived JSON files: $fileCount')
      ..writeln()
      ..writeln('7-day averages:')
      ..writeln(
        'Stability health: ${_fmt(trends.stability)} '
        '(${trends.counts['stability']} samples)',
      )
      ..writeln(
        'RSI health: ${_fmt(trends.rsi)} '
        '(${trends.counts['rsi']} samples)',
      )
      ..writeln(
        'Monetization index: ${_fmt(trends.monetization)} '
        '(${trends.counts['monetization']} samples)',
      )
      ..writeln(
        'Cohesion index: ${_fmt(trends.cohesion)} '
        '(${trends.counts['cohesion']} samples)',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required String archivePath,
    required int fileCount,
    required _TrendMetrics trends,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'archive_path': archivePath,
      'file_count': fileCount,
      'trends': {
        'stability': trends.toJson('stability'),
        'rsi': trends.toJson('rsi'),
        'monetization': trends.toJson('monetization'),
        'cohesion': trends.toJson('cohesion'),
      },
    };
  }

  Future<void> _appendTelemetry(
    String archivePath,
    _TrendMetrics trends,
  ) async {
    final payload = <String, Object?>{
      'event': 'long_term_analytics_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'archive_path': archivePath,
      'trends': trends.toJsonMap(),
      'verdict': trends.isComplete ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _TrendMetrics {
  _TrendMetrics({
    required this.stability,
    required this.rsi,
    required this.monetization,
    required this.cohesion,
    required this.counts,
  });

  final double stability;
  final double rsi;
  final double monetization;
  final double cohesion;
  final Map<String, int> counts;

  bool get isComplete =>
      !stability.isNaN && !rsi.isNaN && !monetization.isNaN && !cohesion.isNaN;

  Map<String, Object?> toJson(String key) {
    final value = {
      'average': _valueForKey(key),
      'sample_count': counts[key] ?? 0,
    };
    return value;
  }

  Map<String, Object?> toJsonMap() => {
    'stability': toJson('stability'),
    'rsi': toJson('rsi'),
    'monetization': toJson('monetization'),
    'cohesion': toJson('cohesion'),
  };

  double? _valueForKey(String key) {
    switch (key) {
      case 'stability':
        return stability;
      case 'rsi':
        return rsi;
      case 'monetization':
        return monetization;
      case 'cohesion':
        return cohesion;
      default:
        return null;
    }
  }
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

String _fmt(double value) => value.isNaN ? 'n/a' : value.toStringAsFixed(4);

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore permission issues
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore cleanup
    }
  }
}
