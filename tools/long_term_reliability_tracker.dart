import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _recoveryPath =
    '$_reportsDir/system_recovery_sentinel_summary.json';
const String _stabilityPath = '$_reportsDir/stability_regression_summary.json';
const String _operationsPath = '$_reportsDir/operations_integrity_summary.json';
const String _summaryTextPath =
    '$_reportsDir/long_term_reliability_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/long_term_reliability_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(days: 7);

Future<void> main(List<String> args) async {
  final tracker = LongTermReliabilityTracker();
  final ok = await tracker.run();
  if (!ok) {
    exitCode = 2;
  }
}

class LongTermReliabilityTracker {
  Future<bool> run() async {
    final recovery = await _readSummary(_recoveryPath);
    final stability = await _readSummary(_stabilityPath);
    final operations = await _readSummary(_operationsPath);

    if (recovery == null || stability == null || operations == null) {
      stderr.writeln('Missing reliability summaries.');
      return false;
    }

    if (!recovery.pass || !stability.pass || !operations.pass) {
      stderr.writeln('One or more summaries did not pass.');
      return false;
    }

    final timestamps = [
      if (recovery.timestamp != null) recovery.timestamp!,
      if (stability.timestamp != null) stability.timestamp!,
      if (operations.timestamp != null) operations.timestamp!,
    ];
    if (!_withinWindow(timestamps)) {
      stderr.writeln('Report timestamps exceed $_timeWindow.');
      return false;
    }

    final recoveryScore = _normalize(recovery.score);
    final stabilityScore = _normalize(stability.score);
    final operationsScore = _normalize(operations.score);
    if (recoveryScore == null ||
        stabilityScore == null ||
        operationsScore == null) {
      stderr.writeln('Unable to extract all scores.');
      return false;
    }

    final reliabilityScore =
        ((recoveryScore * 0.4) +
                (stabilityScore * 0.35) +
                (operationsScore * 0.25))
            .clamp(0.0, 1.0);

    final previousAvg = await _computeHistoricalAverage();
    final trendDelta = previousAvg == null
        ? 0.0
        : reliabilityScore - previousAvg;
    final pass = reliabilityScore >= _threshold;

    final summaryText = _buildTextSummary(
      recoveryScore,
      stabilityScore,
      operationsScore,
      reliabilityScore,
      trendDelta,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      recoveryScore,
      stabilityScore,
      operationsScore,
      reliabilityScore,
      trendDelta,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        recoveryScore,
        stabilityScore,
        operationsScore,
        reliabilityScore,
        trendDelta,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Reliability Trend Score ${(reliabilityScore * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _readSummary(String path) async {
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
      DateTime? parsed;
      if (timestamp != null) {
        parsed = DateTime.tryParse(timestamp);
      }
      final score = _extractScore(decoded);
      return _Summary(pass: verdict == 'PASS', score: score, timestamp: parsed);
    } catch (_) {
      return null;
    }
  }

  bool _withinWindow(List<DateTime> timestamps) {
    if (timestamps.isEmpty) return true;
    final earliest = timestamps.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = timestamps.reduce((a, b) => a.isAfter(b) ? a : b);
    return latest.difference(earliest) <= _timeWindow;
  }

  double? _extractScore(Map<String, Object?> data) {
    const keys = <String>[
      'recovery_integrity_index',
      'stability_regression_score',
      'operations_integrity_index',
      'system_snapshot_v3_score',
      'recovery_integrity_score',
    ];
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final parsed = _toDouble(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  Future<double?> _computeHistoricalAverage() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    final now = DateTime.now();
    final recent = <double>[];
    await for (final line
        in file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line) as Map<String, Object?>;
        if (decoded['event'] != 'long_term_reliability_completed') continue;
        final timestamp = decoded['timestamp'] as String?;
        if (timestamp == null) continue;
        final parsed = DateTime.tryParse(timestamp);
        if (parsed == null) continue;
        if (now.difference(parsed) > _timeWindow) continue;
        final score = _normalize(_toDouble(decoded['reliability_trend_score']));
        if (score != null) recent.add(score);
      } catch (_) {
        continue;
      }
    }
    if (recent.isEmpty) return null;
    return recent.reduce((a, b) => a + b) / recent.length;
  }

  String _buildTextSummary(
    double recovery,
    double stability,
    double operations,
    double score,
    double trendDelta,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('LONG TERM RELIABILITY SUMMARY')
      ..writeln('===============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Recovery integrity: ${pct(recovery)}')
      ..writeln('Stability regression: ${pct(stability)}')
      ..writeln('Operations integrity: ${pct(operations)}')
      ..writeln('Reliability trend score: ${pct(score)}')
      ..writeln('Delta vs 7d avg: ${pct(trendDelta)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double recovery,
    double stability,
    double operations,
    double score,
    double trendDelta,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'recovery_integrity': recovery,
    'stability_regression_score': stability,
    'operations_integrity_index': operations,
    'reliability_trend_score': score,
    'trend_delta': trendDelta,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double recovery,
    double stability,
    double operations,
    double score,
    double trendDelta,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'long_term_reliability_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'recovery_integrity': recovery,
      'stability_regression_score': stability,
      'operations_integrity_index': operations,
      'reliability_trend_score': score,
      'trend_delta': trendDelta,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  const _Summary({
    required this.pass,
    required this.score,
    required this.timestamp,
  });

  final bool pass;
  final double? score;
  final DateTime? timestamp;
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
