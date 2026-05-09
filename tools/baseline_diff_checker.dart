import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

const String _reportsDir = 'release/_reports';
const String _snapshotsDir = 'release/_snapshots';
const String _summaryTextPath = '$_reportsDir/baseline_diff_summary.txt';
const String _summaryJsonPath = '$_reportsDir/baseline_diff_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThresholdPercent = 10.0;
const double _failThresholdPercent = 20.0;

Future<void> main(List<String> args) async {
  final checker = BaselineDiffChecker();
  final ok = await checker.run();
  if (!ok) {
    exitCode = 2;
  }
}

class BaselineDiffChecker {
  Future<bool> run() async {
    final snapshot = await _findLatestSnapshot();
    if (snapshot == null) {
      stderr.writeln('No regression snapshot found in $_snapshotsDir.');
      return false;
    }

    final currentMetrics = await _collectCurrentMetrics();
    final baselineMetrics = await _collectBaselineMetrics(snapshot);

    final results = <_MetricDelta>[];
    bool hasFail = false;

    for (final entry in currentMetrics.entries) {
      final filePath = entry.key;
      final current = entry.value;
      final baseline = baselineMetrics[filePath];
      if (baseline == null) {
        results.add(
          _MetricDelta(
            file: filePath,
            metric: '<missing>',
            baseline: null,
            current: null,
            deltaPercent: null,
            status: _DeltaStatus.warn,
            notes: 'Missing in snapshot',
          ),
        );
        continue;
      }
      final metricKeys = <String>{...current.keys, ...baseline.keys};
      for (final metric in metricKeys) {
        final baselineValue = baseline[metric];
        final currentValue = current[metric];
        if (baselineValue == null || currentValue == null) {
          results.add(
            _MetricDelta(
              file: filePath,
              metric: metric,
              baseline: baselineValue,
              current: currentValue,
              deltaPercent: null,
              status: _DeltaStatus.warn,
              notes: baselineValue == null ? 'New metric' : 'Metric removed',
            ),
          );
          continue;
        }
        final deltaPercent = _percentageChange(baselineValue, currentValue);
        final status = _classify(deltaPercent);
        if (status == _DeltaStatus.fail) {
          hasFail = true;
        }
        results.add(
          _MetricDelta(
            file: filePath,
            metric: metric,
            baseline: baselineValue,
            current: currentValue,
            deltaPercent: deltaPercent,
            status: status,
            notes: '',
          ),
        );
      }
    }

    final summaryText = _buildTextSummary(results, snapshot.path);
    final summaryJson = _buildJsonSummary(results, snapshot.path);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        snapshot: snapshot.path,
        results: results,
        hasFail: hasFail,
      );
    });

    if (hasFail) {
      stderr.writeln('Baseline diff checker detected FAIL deviations.');
    }
    return !hasFail;
  }

  Future<File?> _findLatestSnapshot() async {
    final dir = Directory(_snapshotsDir);
    if (!await dir.exists()) {
      return null;
    }
    final files = await dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.zip'))
        .cast<File>()
        .toList();
    if (files.isEmpty) {
      return null;
    }
    files.sort((a, b) => a.path.compareTo(b.path));
    return files.last;
  }

  Future<Map<String, Map<String, double>>> _collectCurrentMetrics() async {
    final dir = Directory(_reportsDir);
    final result = <String, Map<String, double>>{};
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final relative = p.relative(entity.path, from: _reportsDir);
      final metrics = await _readJsonMetrics(await entity.readAsString());
      result[relative] = metrics;
    }
    return result;
  }

  Future<Map<String, Map<String, double>>> _collectBaselineMetrics(
    File snapshot,
  ) async {
    final bytes = await snapshot.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final result = <String, Map<String, double>>{};
    for (final file in archive.files) {
      if (!file.isFile || !file.name.endsWith('.json')) continue;
      final normalized = p.normalize(file.name);
      final content = utf8.decode(file.content as List<int>);
      result[normalized] = await _readJsonMetrics(content);
    }
    return result;
  }

  Future<Map<String, double>> _readJsonMetrics(String data) async {
    final decoded = json.decode(data);
    final result = <String, double>{};
    _flattenJson(decoded, '', result);
    return result;
  }

  String _buildTextSummary(List<_MetricDelta> deltas, String snapshotPath) {
    final total = deltas.length;
    final pass = deltas.where((d) => d.status == _DeltaStatus.pass).length;
    final warn = deltas.where((d) => d.status == _DeltaStatus.warn).length;
    final fail = deltas.where((d) => d.status == _DeltaStatus.fail).length;
    final buffer = StringBuffer()
      ..writeln('BASELINE DIFF SUMMARY')
      ..writeln('Snapshot: $snapshotPath')
      ..writeln('Totals: PASS=$pass WARN=$warn FAIL=$fail (metrics: $total)')
      ..writeln()
      ..writeln('File | Metric | Baseline | Current | Delta% | Status | Notes');
    for (final delta in deltas) {
      buffer.writeln(
        '${delta.file} | ${delta.metric} | '
        '${_fmt(delta.baseline)} | ${_fmt(delta.current)} | '
        '${delta.deltaPercent == null ? 'n/a' : delta.deltaPercent!.toStringAsFixed(2)} | '
        '${delta.status.name.toUpperCase()} | ${delta.notes}',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    List<_MetricDelta> deltas,
    String snapshotPath,
  ) {
    return {
      'snapshot': snapshotPath,
      'generated_at': DateTime.now().toIso8601String(),
      'counts': {
        'total': deltas.length,
        'pass': deltas.where((d) => d.status == _DeltaStatus.pass).length,
        'warn': deltas.where((d) => d.status == _DeltaStatus.warn).length,
        'fail': deltas.where((d) => d.status == _DeltaStatus.fail).length,
      },
      'thresholds': {
        'warn_percent': _warnThresholdPercent,
        'fail_percent': _failThresholdPercent,
      },
      'deltas': deltas.map((d) => d.toJson()).toList(),
    };
  }

  Future<void> _appendTelemetry({
    required String snapshot,
    required List<_MetricDelta> results,
    required bool hasFail,
  }) async {
    final payload = <String, Object?>{
      'event': 'baseline_diff_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'snapshot': snapshot,
      'counts': {
        'pass': results.where((d) => d.status == _DeltaStatus.pass).length,
        'warn': results.where((d) => d.status == _DeltaStatus.warn).length,
        'fail': results.where((d) => d.status == _DeltaStatus.fail).length,
      },
      'verdict': hasFail ? 'FAIL' : 'PASS',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

void _flattenJson(Object? value, String prefix, Map<String, double> out) {
  if (value is num) {
    out[prefix.isEmpty ? '<root>' : prefix] = value.toDouble();
  } else if (value is Map) {
    value.forEach((key, child) {
      final nextPrefix = prefix.isEmpty ? key : '$prefix.$key';
      _flattenJson(child, nextPrefix, out);
    });
  } else if (value is List) {
    for (var i = 0; i < value.length; i++) {
      final nextPrefix = '$prefix[$i]';
      _flattenJson(value[i], nextPrefix, out);
    }
  }
}

double _percentageChange(double baseline, double current) {
  if (baseline == 0) {
    return current == 0 ? 0.0 : 100.0;
  }
  return ((current - baseline) / baseline) * 100.0;
}

_DeltaStatus _classify(double? deltaPercent) {
  if (deltaPercent == null) return _DeltaStatus.warn;
  final absDelta = deltaPercent.abs();
  if (absDelta > _failThresholdPercent) {
    return _DeltaStatus.fail;
  }
  if (absDelta > _warnThresholdPercent) {
    return _DeltaStatus.warn;
  }
  return _DeltaStatus.pass;
}

String _fmt(double? value) {
  if (value == null) return 'n/a';
  return value.toStringAsFixed(4);
}

class _MetricDelta {
  _MetricDelta({
    required this.file,
    required this.metric,
    required this.baseline,
    required this.current,
    required this.deltaPercent,
    required this.status,
    required this.notes,
  });

  final String file;
  final String metric;
  final double? baseline;
  final double? current;
  final double? deltaPercent;
  final _DeltaStatus status;
  final String notes;

  Map<String, Object?> toJson() {
    return {
      'file': file,
      'metric': metric,
      'baseline': baseline,
      'current': current,
      'delta_percent': deltaPercent,
      'status': status.name,
      'notes': notes,
    };
  }
}

enum _DeltaStatus { pass, warn, fail }

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
      // ignore
    }
  }
}
