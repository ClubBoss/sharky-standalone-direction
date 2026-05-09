import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _stabilityPath = '$_reportsDir/stability_regression_summary.json';
const String _recoveryPath = '$_reportsDir/automated_recovery_summary.json';
const String _maintenancePath =
    '$_reportsDir/post_release_maintenance_summary.json';
const String _summaryTextPath =
    '$_reportsDir/system_recovery_sentinel_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/system_recovery_sentinel_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _maxDelta = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final sentinel = SystemRecoverySentinel();
  final ok = await sentinel.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SystemRecoverySentinel {
  Future<bool> run() async {
    final stability = await _readReport(_stabilityPath);
    final recovery = await _readReport(_recoveryPath);
    final maintenance = await _readReport(_maintenancePath);

    if (stability == null || recovery == null || maintenance == null) {
      stderr.writeln('Missing system recovery inputs.');
      return false;
    }

    if (!stability.pass || !recovery.pass || !maintenance.pass) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (stability.timestamp != null) stability.timestamp!,
      if (recovery.timestamp != null) recovery.timestamp!,
      if (maintenance.timestamp != null) maintenance.timestamp!,
    ];

    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Input timestamps span more than ${_maxDelta.inHours}h.');
      return false;
    }

    final stabilityScore = _normalize(stability.score);
    final recoveryScore = _normalize(recovery.score);
    final maintenanceScore = _normalize(maintenance.score);

    if (stabilityScore == null ||
        recoveryScore == null ||
        maintenanceScore == null) {
      stderr.writeln('Unable to extract scores.');
      return false;
    }

    final index =
        ((stabilityScore * 0.4) +
                (maintenanceScore * 0.35) +
                (recoveryScore * 0.25))
            .clamp(0.0, 1.0);

    final pass = index >= _threshold;

    final textSummary = _buildText(
      stabilityScore,
      recoveryScore,
      maintenanceScore,
      index,
      pass,
    );
    final jsonSummary = _buildJson(
      stabilityScore,
      recoveryScore,
      maintenanceScore,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(textSummary);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(jsonSummary));
      await _appendTelemetry(
        stabilityScore,
        recoveryScore,
        maintenanceScore,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Recovery Integrity Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
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
      final parsedTimestamp = timestamp != null
          ? DateTime.tryParse(timestamp)
          : null;
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
      'stability_score',
      'stability_integrity_score',
      'recovery_score',
      'maintenance_score',
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

  double? _normalize(double? value) {
    if (value == null) return null;
    final adjusted = value > 1 ? value / 100 : value;
    return adjusted.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double stability,
    double recovery,
    double maintenance,
    double index,
    bool pass,
  ) {
    String pct(double v) => '${(v * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SYSTEM RECOVERY SENTINEL')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Stability score: ${pct(stability)}')
      ..writeln('Recovery score: ${pct(recovery)}')
      ..writeln('Maintenance score: ${pct(maintenance)}')
      ..writeln('Recovery Integrity Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double stability,
    double recovery,
    double maintenance,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'stability_score': stability,
    'recovery_score': recovery,
    'maintenance_score': maintenance,
    'recovery_integrity_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double stability,
    double recovery,
    double maintenance,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'system_recovery_sentinel_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stability_score': stability,
      'recovery_score': recovery,
      'maintenance_score': maintenance,
      'recovery_integrity_index': index,
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
