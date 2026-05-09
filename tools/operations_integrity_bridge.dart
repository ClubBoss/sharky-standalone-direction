import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _ltvPath = '$_reportsDir/ltv_forecast_summary.json';
const String _systemSnapshotPath =
    '$_reportsDir/system_snapshot_v3_summary.json';
const String _certificationPath =
    '$_reportsDir/final_release_certification_summary.json';
const String _summaryTextPath = '$_reportsDir/operations_integrity_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/operations_integrity_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const Duration _maxDelta = Duration(hours: 24);
const double _threshold = 0.9;

Future<void> main(List<String> args) async {
  final bridge = OperationsIntegrityBridge();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class OperationsIntegrityBridge {
  Future<bool> run() async {
    final ltv = await _readReport(_ltvPath, ['ltv_forecast_index']);
    final system = await _readReport(_systemSnapshotPath, [
      'system_snapshot_v3_score',
    ]);
    final cert = await _readReport(_certificationPath, ['certification_score']);
    if (ltv == null || system == null || cert == null) {
      stderr.writeln('Missing required operations integrity inputs.');
      return false;
    }

    if (!ltv.pass || !system.pass || !cert.pass) {
      stderr.writeln('One or more reports did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (ltv.timestamp != null) ltv.timestamp!,
      if (system.timestamp != null) system.timestamp!,
      if (cert.timestamp != null) cert.timestamp!,
    ];
    if (!_timestampsAligned(timestamps)) {
      stderr.writeln('Report timestamps span more than ${_maxDelta.inHours}h.');
      return false;
    }

    final ltvScore = _normalizeValue(ltv.score);
    final systemScore = _normalizeValue(system.score);
    final certScore = _normalizeValue(cert.score);

    if (ltvScore == null || systemScore == null || certScore == null) {
      stderr.writeln('Unable to extract scores.');
      return false;
    }

    final index = ((systemScore * 0.4) + (ltvScore * 0.35) + (certScore * 0.25))
        .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final summaryText = _buildText(
      ltvScore,
      systemScore,
      certScore,
      index,
      pass,
    );
    final summaryJson = _buildJson(
      ltvScore,
      systemScore,
      certScore,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(ltvScore, systemScore, certScore, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Operations Integrity Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Report?> _readReport(String path, List<String> scoreKeys) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final jsonMap = json.decode(await file.readAsString());
      if (jsonMap is! Map<String, Object?>) return null;
      final verdict = ((jsonMap['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          (jsonMap['generated_at'] as String?) ??
          (jsonMap['generated'] as String?) ??
          (jsonMap['timestamp'] as String?);
      DateTime? parsedTimestamp;
      if (timestamp != null) {
        parsedTimestamp = DateTime.tryParse(timestamp);
      }
      final score = _extractScore(jsonMap, scoreKeys);
      return _Report(
        path: path,
        verdict: verdict,
        pass: verdict == 'PASS',
        timestamp: parsedTimestamp,
        score: score,
      );
    } catch (_) {
      return null;
    }
  }

  bool _timestampsAligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _maxDelta;
  }

  double? _normalizeValue(double? value) {
    if (value == null) return null;
    final adjusted = value > 1 ? value / 100 : value;
    return adjusted.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double? _extractScore(Map<String, Object?> jsonMap, List<String> keys) {
    for (final key in keys) {
      if (!jsonMap.containsKey(key)) continue;
      final value = _toDouble(jsonMap[key]);
      if (value != null) return value;
    }
    return null;
  }

  String _buildText(
    double ltv,
    double system,
    double cert,
    double index,
    bool pass,
  ) {
    String pct(double v) => '${(v * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('OPERATIONS INTEGRITY SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('System snapshot score: ${pct(system)}')
      ..writeln('LTV forecast index: ${pct(ltv)}')
      ..writeln('Certification score: ${pct(cert)}')
      ..writeln('Operations Integrity Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double ltv,
    double system,
    double cert,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'system_snapshot_score': system,
    'ltv_forecast_index': ltv,
    'certification_score': cert,
    'operations_integrity_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double ltv,
    double system,
    double cert,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'operations_integrity_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'system_snapshot_score': system,
      'ltv_forecast_index': ltv,
      'certification_score': cert,
      'operations_integrity_index': index,
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
    required this.verdict,
    required this.pass,
    required this.timestamp,
    required this.score,
  });

  final String path;
  final String verdict;
  final bool pass;
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
