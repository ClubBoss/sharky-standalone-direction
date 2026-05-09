import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _operationsPath = '$_reportsDir/operations_integrity_summary.json';
const String _stabilityPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.json';
const String _systemPath = '$_reportsDir/system_snapshot_v3_summary.json';
const String _summaryTextPath =
    '$_reportsDir/stability_regression_monitor_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/stability_regression_monitor_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final monitor = StabilityRegressionMonitor();
  final ok = await monitor.run();
  if (!ok) {
    exitCode = 2;
  }
}

class StabilityRegressionMonitor {
  Future<bool> run() async {
    final operations = await _readReport(_operationsPath);
    final stability = await _readReport(_stabilityPath);
    final system = await _readReport(_systemPath);

    if (operations == null || stability == null || system == null) {
      stderr.writeln('Missing one or more stability inputs.');
      return false;
    }

    if (!operations.pass || !stability.pass || !system.pass) {
      stderr.writeln('One or more reports failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (operations.timestamp != null) operations.timestamp!,
      if (stability.timestamp != null) stability.timestamp!,
      if (system.timestamp != null) system.timestamp!,
    ];
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Input timestamps span more than ${_maxDelta.inHours}h.');
      return false;
    }

    final operationsScore = _normalize(operations.score);
    final stabilityScore = _normalize(stability.score);
    final systemScore = _normalize(system.score);

    final score =
        ((stabilityScore * 0.4) +
                (systemScore * 0.35) +
                (operationsScore * 0.25))
            .clamp(0.0, 1.0);

    final pass = score >= _threshold;

    final textSummary = _buildText(
      stabilityScore,
      systemScore,
      operationsScore,
      score,
      pass,
    );
    final jsonSummary = _buildJson(
      stabilityScore,
      systemScore,
      operationsScore,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(textSummary);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(jsonSummary));
      await _appendTelemetry(
        stabilityScore,
        systemScore,
        operationsScore,
        score,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Stability Regression Score ${(score * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Report?> _readReport(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      DateTime? parsedTimestamp;
      if (timestamp != null) {
        parsedTimestamp = DateTime.tryParse(timestamp);
      }
      final score = _extractScore(decoded);
      return _Report(
        path: path,
        pass: verdict == 'PASS',
        verdict: verdict,
        timestamp: parsedTimestamp,
        score: score,
      );
    } catch (_) {
      return null;
    }
  }

  double? _extractScore(Map<String, Object?> data) {
    const keys = <String>[
      'stability_integrity_score',
      'system_snapshot_v3_score',
      'operations_integrity_index',
    ];
    for (final key in keys) {
      if (!data.containsKey(key)) continue;
      final value = _toDouble(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  bool _timestampsAligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _maxDelta;
  }

  double _normalize(double? value) {
    final raw = value ?? 0;
    final normalized = raw > 1 ? raw / 100 : raw;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double stability,
    double system,
    double operations,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('STABILITY REGRESSION MONITOR')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Stability integrity: ${pct(stability)}')
      ..writeln('System snapshot score: ${pct(system)}')
      ..writeln('Operations integrity: ${pct(operations)}')
      ..writeln('Stability Regression Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double stability,
    double system,
    double operations,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'stability_integrity_score': stability,
    'system_snapshot_score': system,
    'operations_integrity_index': operations,
    'stability_regression_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double stability,
    double system,
    double operations,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'stability_regression_monitor_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stability_integrity_score': stability,
      'system_snapshot_score': system,
      'operations_integrity_index': operations,
      'stability_regression_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Report {
  _Report({
    required this.path,
    required this.pass,
    required this.verdict,
    required this.timestamp,
    required this.score,
  });

  final String path;
  final bool pass;
  final String verdict;
  final DateTime? timestamp;
  final double? score;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
